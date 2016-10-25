# DRA
Code for the paper deep relative attributes (http://yangxs.cc/publications/DRA.pdf)

The code has been tested on 64bit ubuntu 12.04. The GPU is Titan Black Z with CUDA 7.0.

###1. Make revised caffe_20160725:

sudo make all [-j8]

###2. Download the pretrained caffe model and place it to the Model directory:

http://dl.caffe.berkeleyvision.org/bvlc_reference_caffenet.caffemodel

###3. Download the image dataset and revise the dataset directory in the run_ReNet.m

https://filebox.ece.vt.edu/~parikh/relative_attributes/relative_attributes_v2.zip

###4. Run run_ReNet.m

The prospective average result on osr: 0.9770 and on pubfig: 0.9057.

Note that increase n_tr_pairs will improve the performance.


