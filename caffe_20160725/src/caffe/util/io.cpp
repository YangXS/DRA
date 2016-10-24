#include <fcntl.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/io/zero_copy_stream_impl.h>
#include <google/protobuf/text_format.h>
#ifdef USE_OPENCV
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/highgui/highgui_c.h>
#include <opencv2/imgproc/imgproc.hpp>
#endif  // USE_OPENCV
#include <stdint.h>

#include <algorithm>
#include <fstream>  // NOLINT(readability/streams)
#include <string>
#include <vector>

#include "caffe/common.hpp"
#include "caffe/proto/caffe.pb.h"
#include "caffe/util/io.hpp"

const int kProtoReadBytesLimit = INT_MAX;  // Max size of 2 GB minus 1 byte.

namespace caffe {

using google::protobuf::io::FileInputStream;
using google::protobuf::io::FileOutputStream;
using google::protobuf::io::ZeroCopyInputStream;
using google::protobuf::io::CodedInputStream;
using google::protobuf::io::ZeroCopyOutputStream;
using google::protobuf::io::CodedOutputStream;
using google::protobuf::Message;

bool ReadProtoFromTextFile(const char* filename, Message* proto) {
  int fd = open(filename, O_RDONLY);
  CHECK_NE(fd, -1) << "File not found: " << filename;
  FileInputStream* input = new FileInputStream(fd);
  bool success = google::protobuf::TextFormat::Parse(input, proto);
  delete input;
  close(fd);
  return success;
}

void WriteProtoToTextFile(const Message& proto, const char* filename) {
  int fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);
  FileOutputStream* output = new FileOutputStream(fd);
  CHECK(google::protobuf::TextFormat::Print(proto, output));
  delete output;
  close(fd);
}

bool ReadProtoFromBinaryFile(const char* filename, Message* proto) {
  int fd = open(filename, O_RDONLY);
  CHECK_NE(fd, -1) << "File not found: " << filename;
  ZeroCopyInputStream* raw_input = new FileInputStream(fd);
  CodedInputStream* coded_input = new CodedInputStream(raw_input);
  coded_input->SetTotalBytesLimit(kProtoReadBytesLimit, 536870912);

  bool success = proto->ParseFromCodedStream(coded_input);

  delete coded_input;
  delete raw_input;
  close(fd);
  return success;
}

void WriteProtoToBinaryFile(const Message& proto, const char* filename) {
  fstream output(filename, ios::out | ios::trunc | ios::binary);
  CHECK(proto.SerializeToOstream(&output));
}

#ifdef USE_OPENCV
cv::Mat ReadImageToCVMat(const string& filename,
    const int height, const int width, const bool is_color) {
  cv::Mat cv_img;
  int cv_read_flag = (is_color ? CV_LOAD_IMAGE_COLOR :
    CV_LOAD_IMAGE_GRAYSCALE);
  cv::Mat cv_img_origin = cv::imread(filename, cv_read_flag);
  if (!cv_img_origin.data) {
    LOG(ERROR) << "Could not open or find file " << filename;
    return cv_img_origin;
  }
  if (height > 0 && width > 0) {
    cv::resize(cv_img_origin, cv_img, cv::Size(width, height));
  } else {
    cv_img = cv_img_origin;
  }
  return cv_img;
}

cv::Mat ReadImageToCVMat(const string& filename,
    const int height, const int width) {
  return ReadImageToCVMat(filename, height, width, true);
}

cv::Mat ReadImageToCVMat(const string& filename,
    const bool is_color) {
  return ReadImageToCVMat(filename, 0, 0, is_color);
}

cv::Mat ReadImageToCVMat(const string& filename) {
  return ReadImageToCVMat(filename, 0, 0, true);
}

// Do the file extension and encoding match?
static bool matchExt(const std::string & fn,
                     std::string en) {
  size_t p = fn.rfind('.');
  std::string ext = p != fn.npos ? fn.substr(p) : fn;
  std::transform(ext.begin(), ext.end(), ext.begin(), ::tolower);
  std::transform(en.begin(), en.end(), en.begin(), ::tolower);
  if ( ext == en )
    return true;
  if ( en == "jpg" && ext == "jpeg" )
    return true;
  return false;
}

bool ReadImageToDatum(const string& filename, const int label,
    const int height, const int width, const bool is_color,
    const std::string & encoding, Datum* datum) {
  cv::Mat cv_img = ReadImageToCVMat(filename, height, width, is_color);
  if (cv_img.data) {
    if (encoding.size()) {
      if ( (cv_img.channels() == 3) == is_color && !height && !width &&
          matchExt(filename, encoding) )
        return ReadFileToDatum(filename, label, datum);
      std::vector<uchar> buf;
      cv::imencode("."+encoding, cv_img, buf);
      datum->set_data(std::string(reinterpret_cast<char*>(&buf[0]),
                      buf.size()));
      datum->set_label(label);
      datum->set_encoded(true);
      return true;
    }
    CVMatToDatum(cv_img, datum);
    datum->set_label(label);
    return true;
  } else {
    return false;
  }
}

// added by YangXS for processing image pairs
bool ReadImagePairToDatum(const string& filename, const int label,
    const string& filename_, const int label_,
    const int height, const int width, const bool is_color,
    const std::string & encoding, Datum* datum) {

  // assume: label >= label2,
  // if not, swap them
  string filename1;
  string filename2;
  int label1;
  int label2;
  if(label >= label_){
	filename1 = filename;
	filename2 = filename_;
	label1 = label;
	label2 = label_;
  }
  else{
	filename2 = filename;
	filename1 = filename_;
	label2 = label;
	label1 = label_;
  }

  // assign the label of the pair
  int label_pair;
  if (label1  > label2) {
     label_pair = 0;
   }
  else if(label1  == label2){
     label_pair = 1;
  }
  else{
	LOG(ERROR) << "wrong labels of the input image pairs";
	return false;
  }

  cv::Mat cv_img1 = ReadImageToCVMat(filename1, height, width, is_color);
  cv::Mat cv_img2 = ReadImageToCVMat(filename2, height, width, is_color);
  if (cv_img1.data && cv_img2.data) {
    if (encoding.size()) {
      if ( (cv_img1.channels() == 3) == is_color &&
         (cv_img2.channels() == 3) == is_color && !height && !width &&
          matchExt(filename1, encoding) && matchExt(filename2, encoding) )
        return ReadFilePairToDatum(filename1, label1, filename2, label2, datum);
      std::vector<uchar> buf;
      cv::imencode("."+encoding, cv_img1, buf);
      std::vector<uchar> buf_;
      cv::imencode("."+encoding, cv_img2, buf_);
      // combine two vector
      buf.insert(buf.end(), buf_.begin(), buf_.end() );
      datum->set_data(std::string(reinterpret_cast<char*>(&buf[0]),
                      buf.size()));
      datum->set_label(label_pair);
      datum->set_encoded(true);
      return true;
    }
    CVMatPairToDatum(cv_img1, cv_img2, datum);
    datum->set_label(label_pair);
    return true;
  } else {
    return false;
  }
}

#endif  // USE_OPENCV

bool ReadFileToDatum(const string& filename, const int label,
    Datum* datum) {
  std::streampos size;

  fstream file(filename.c_str(), ios::in|ios::binary|ios::ate);
  if (file.is_open()) {
    size = file.tellg();
    std::string buffer(size, ' ');
    file.seekg(0, ios::beg);
    file.read(&buffer[0], size);
    file.close();
    datum->set_data(buffer);
    datum->set_label(label);
    datum->set_encoded(true);
    return true;
  } else {
    return false;
  }
}

// added by YangXS, read files of image pair to Datum
bool ReadFilePairToDatum(const string& filename, const int label,
    const string& filename_, const int label_,
    Datum* datum) {
  std::streampos size, size_;
  fstream file(filename.c_str(), ios::in|ios::binary|ios::ate);
  fstream file_(filename_.c_str(), ios::in|ios::binary|ios::ate);
  if (file.is_open() && file_.is_open()) {
    size = file.tellg();
    size_ = file_.tellg();
    std::string buffer(size+size_, ' ');
    // read first file
    file.seekg(0, ios::beg);
    file.read(&buffer[0], size);
    file.close();
    // read the second file
    file_.seekg(0, ios::beg);
    file_.read(&buffer[size], size_);
    file_.close();
    // save buffer into datum
    datum->set_data(buffer);
    // assign the label of the pair
    if (label  > label_) {
      datum->set_label(0);
    }
    else if(label  == label_){
      datum->set_label(1);
    }
    else{
	  LOG(ERROR) << "wrong labels of the input image pairs";
	  return false;
    }
    datum->set_encoded(true);
    return true;
  } else {
    return false;
  }
}

#ifdef USE_OPENCV
cv::Mat DecodeDatumToCVMatNative(const Datum& datum) {
  cv::Mat cv_img;
  CHECK(datum.encoded()) << "Datum not encoded";
  const string& data = datum.data();
  std::vector<char> vec_data(data.c_str(), data.c_str() + data.size());
  cv_img = cv::imdecode(vec_data, -1);
  if (!cv_img.data) {
    LOG(ERROR) << "Could not decode datum ";
  }
  return cv_img;
}
cv::Mat DecodeDatumToCVMat(const Datum& datum, bool is_color) {
  cv::Mat cv_img;
  CHECK(datum.encoded()) << "Datum not encoded";
  const string& data = datum.data();
  std::vector<char> vec_data(data.c_str(), data.c_str() + data.size());
  int cv_read_flag = (is_color ? CV_LOAD_IMAGE_COLOR :
    CV_LOAD_IMAGE_GRAYSCALE);
  cv_img = cv::imdecode(vec_data, cv_read_flag);
  if (!cv_img.data) {
    LOG(ERROR) << "Could not decode datum ";
  }
  return cv_img;
}

// If Datum is encoded will decoded using DecodeDatumToCVMat and CVMatToDatum
// If Datum is not encoded will do nothing
bool DecodeDatumNative(Datum* datum) {
  if (datum->encoded()) {
    cv::Mat cv_img = DecodeDatumToCVMatNative((*datum));
    CVMatToDatum(cv_img, datum);
    return true;
  } else {
    return false;
  }
}
bool DecodeDatum(Datum* datum, bool is_color) {
  if (datum->encoded()) {
    cv::Mat cv_img = DecodeDatumToCVMat((*datum), is_color);
    CVMatToDatum(cv_img, datum);
    return true;
  } else {
    return false;
  }
}

void CVMatToDatum(const cv::Mat& cv_img, Datum* datum) {
  CHECK(cv_img.depth() == CV_8U) << "Image data type must be unsigned byte";
  datum->set_channels(cv_img.channels());
  datum->set_height(cv_img.rows);
  datum->set_width(cv_img.cols);
  datum->clear_data();
  datum->clear_float_data();
  datum->set_encoded(false);
  int datum_channels = datum->channels();
  int datum_height = datum->height();
  int datum_width = datum->width();
  int datum_size = datum_channels * datum_height * datum_width;
  std::string buffer(datum_size, ' ');
  for (int h = 0; h < datum_height; ++h) {
    const uchar* ptr = cv_img.ptr<uchar>(h);
    int img_index = 0;
    for (int w = 0; w < datum_width; ++w) {
      for (int c = 0; c < datum_channels; ++c) {
        int datum_index = (c * datum_height + h) * datum_width + w;
        buffer[datum_index] = static_cast<char>(ptr[img_index++]);
      }
    }
  }
  datum->set_data(buffer);
}
// added by YangXS for mat pair
void CVMatPairToDatum(const cv::Mat& cv_img1, const cv::Mat& cv_img2, Datum* datum) {
  CHECK(cv_img1.depth() == CV_8U) << "Image data type must be unsigned byte";
  CHECK(cv_img2.depth() == CV_8U) << "Image data type must be unsigned byte";
  // added by YangXS
  int nc = cv_img1.channels();
  CHECK( nc == cv_img2.channels() ) << "number of channels of the two images must be same";
  datum->set_channels( 2*nc );
  datum->set_height(cv_img1.rows);
  datum->set_width(cv_img1.cols);
  datum->clear_data();
  datum->clear_float_data();
  datum->set_encoded(false);
  int datum_channels = datum->channels();
  int datum_height = datum->height();
  int datum_width = datum->width();
  int datum_size = datum_channels * datum_height * datum_width;
  // half of the datum_size
  int datum_size_hf = nc * datum_height * datum_width;
  std::string buffer(datum_size, ' ');
  for (int h = 0; h < datum_height; ++h) {
    const uchar* ptr1 = cv_img1.ptr<uchar>(h);
    const uchar* ptr2 = cv_img2.ptr<uchar>(h);
    int img_index = 0;
    for (int w = 0; w < datum_width; ++w) {
      for (int c = 0; c < nc; ++c) {
        int datum_index = (c * datum_height + h) * datum_width + w;
        // first image
        buffer[datum_index] = static_cast<char>(ptr1[img_index]);
        // second image
        buffer[datum_size_hf+datum_index] = static_cast<char>(ptr2[img_index]);
        img_index++;
      }
    }
  }
  datum->set_data(buffer);
}

#endif  // USE_OPENCV
}  // namespace caffe
