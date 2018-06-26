# GSR 
##### Group-based Sparse Representation for Image Restoration (Matlab Code)

 These MATLAB programs implement the image restoration algorithms via group-based sparse representation (GSR) modeling as described in paper:

Jian Zhang, Debin Zhao, Wen Gao, "Group-based Sparse Representation for Image Restoration", TIP 2014, [[pdf]](https://arxiv.org/abs/1405.3351) 

Specifically, this packages contains  the implementions for three applications: image inpainting, image deblurring and image compressive sensing recovery, which can be found in each directory. 

This code relies on 
[Wavelet Software package](http://eeweb.poly.edu/iselesni/WaveletSoftware/),
[Pascal Getreuer's Wavelet CDF 9/7 package](http://www.getreuer.info/home/waveletcdf97),
[FSIM-Feature Similarity Index](http://www4.comp.polyu.edu.hk/~cslzhang/IQA/FSIM/FSIM.htm),
[MH-BCS-SPL package](http://www.ece.msstate.edu/~fowler/BCSSPL/).

All will need to reside within the current MATLAB search path.

##### Requirements: Matlab 7.10.0(2010a) or later with installed:

## Introduction
Traditional patch-based sparse representation modeling of natural images usually suffer from two problems. First, it has to solve a large-scale optimization problem with high computational complexity in dictionary learning. Second, each patch is considered independently in dictionary learning and sparse coding, which ignores the relationship among patches, resulting in inaccurate sparse coding coefficients. In this paper, instead of using patch as the basic unit of sparse representation, we exploit the concept of group as the basic unit of sparse representation, which is composed of nonlocal patches with similar structures, and establish a novel sparse representation modeling of natural images, called group-based sparse representation (GSR). The proposed GSR is able to sparsely represent natural images in the domain of group, which enforces the intrinsic local sparsity and nonlocal self-similarity of images simultaneously in a unified framework. Moreover, an effective self-adaptive dictionary learning method for each group with low complexity is designed, rather than dictionary learning from natural images. To make GSR tractable and robust, a split Bregman based technique is developed to solve the proposed GSR-driven minimization problem for image restoration efficiently. Extensive experiments on image  inpainting, image deblurring and image compressive sensing recovery manifest that the proposed GSR modeling outperforms many current state-of-the-art schemes in both PSNR and visual perception.


## Citation
If you find our code helpful in your resarch or work, please cite our paper.
```
@article{zhang2014group,
  title={Group-based sparse representation for image restoration},
  author={Zhang, Jian and Zhao, Debin and Gao, Wen},
  journal={IEEE Transactions on Image Processing},
  volume={23},
  number={8},
  pages={3336--3351},
  year={2014},
  publisher={IEEE}
}
```
