#define ATTRIBUTES extern "C" __attribute__((visibility("default"))) __attribute__((used))
#include <opencv2/opencv.hpp>
#include <opencv2/core/mat.hpp>
#include <android_log.h>
#include <algorithm>
#define DEBUG_NATIVE true

using namespace cv;
using namespace std;

// decode 图片
ATTRIBUTES Mat *opencv_decodeImage(
    unsigned char *img,
    int32_t *imgLengthBytes)
{

    Mat *src = new Mat();
    std::vector<unsigned char> m;

    LOGD("opencv_decodeImage() ---  start imgLengthBytes:%d ",
         *imgLengthBytes);

    for (int32_t a = *imgLengthBytes; a >= 0; a--)
        m.push_back(*(img++));

    *src = imdecode(m, cv::IMREAD_COLOR);
    if (src->data == nullptr)
        return nullptr;

    // if (DEBUG_NATIVE)
    //     LOGD(
    //         "opencv_decodeImage() ---  len before:%d  len after:%d  width:%d  height:%d",
    //         *imgLengthBytes, src->step[0] * src->rows,
    //         src->cols, src->rows);

    *imgLengthBytes = src->step[0] * src->rows;
    return src;
}

//计算直方图
ATTRIBUTES
Mat *getHist(Mat* gray)
{
    Mat hist;
    const int channels[] = { 0 };
    int dims = 1;
    const int histSize[] = {256};//直方图没个维度划分的柱条的数目
    float prange[] = {0,255}; //取值区间
    const float* ranges[] = {prange};
    calcHist(gray, 1, channels, Mat(), hist, dims, histSize, ranges, true, false);

    double maxVal = 0;
    double minval = 0;
    Point maxloc;
    Mat hist_normalized;
    minMaxLoc(hist,&minval,&maxVal,0,&maxloc);
    hist_normalized = 100*(hist-minval)/(maxVal - minval);

    int scale = 2;
    int hist_height = 100;
    Mat* hist_img = new Mat(Mat::zeros(hist_height, 256*scale, CV_8UC3));
    for(int i=0; i < 255 ; i++){
        int val = cvRound(hist_normalized.at<float>(i));
        rectangle(*hist_img,Point(i*scale,hist_height-val),Point((i+1)*scale - 1,100),Scalar(255,255,255));
    }
    return hist_img;
}

ATTRIBUTES
unsigned char *opencv_gray(
    uint8_t *imgMat,
    int32_t *imgLengthBytes,
    uint8_t *hist,
    int32_t *histLengthBytes
    )
{
    // 1. decode 图片
    Mat *src = opencv_decodeImage(imgMat, imgLengthBytes);
    if (src == nullptr || src->data == nullptr)
        return nullptr;
    // if (DEBUG_NATIVE)
    // {
    //     LOGD(
    //         "opencv_gray() ---  width:%d   height:%d",
    //         src->cols, src->rows);

    //     LOGD(
    //         "opencv_gray() ---  len:%d ",
    //         src->step[0] * src->rows);
    // }

    // 2. 灰度化
    cvtColor(*src,*src,COLOR_BGR2GRAY);
    std::vector<uchar> buf(1); // imencode() will resize it
                               //    Encoding with b       mp : 20-40ms
                               //    Encoding with jpg : 50-70 ms
                               //    Encoding with png: 200-250ms                          
    // 3. encode 图片
    imencode(".jpg", *src, buf);
    
    // if (DEBUG_NATIVE)
    // {
    //     LOGD(
    //         "opencv_gray()  resulting image  length:%d %d x %d", buf.size(),
    //         src->cols, src->rows);
    // }

    *imgLengthBytes = buf.size();

    Mat * hist_img = getHist(src);
    std::vector<uchar> histbuf(1);
    imencode(".jpg", *hist_img, histbuf);
    *histLengthBytes = histbuf.size();
    copy(histbuf.begin(), histbuf.end(), hist);

    // the return value may be freed by GC before dart receive it??
    // Sometimes in Dart, ImgProc.computeSync() receives all zeros while here buf.data() is filled correctly
    // Returning a new allocated memory.
    // Note: remember to free() the Pointer<> in Dart!

    // 3. 返回data
    return buf.data();
}
