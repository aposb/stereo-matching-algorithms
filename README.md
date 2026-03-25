# Stereo Matching Algorithms in MATLAB and Python

Optimized (very fast) stereo matching algorithms in MATLAB and Python. It includes implementations of Block Matching, Dynamic Programming, Semi-Global Matching, Semi-Global Block Matching and Belief Propagation.

## Features

- Stereo matching algorithms

  - **Block Matching (BM)**
  - **Dynamic Programming (DP)**
  - **Semi-Global Matching (SGM)**
  - **Semi-Global Block Matching (SGBM)**
  - **Belief Propagation (BP)**

- Multiple different versions of the algorithms

- All algorithms are implemented in both MATLAB and Python

- The algorithms are optimized for performance using matrix operations and other techniques

## Algorithms

| Filename | Description | Implementations |
| --- | --- | --- |
| **`stereoBM_SAD`** | Block Matching using Sum of Absolute Differences | [MATLAB](./matlab/stereoBM_SAD.m) / [Python](./python/stereoBM_SAD.py) |
| **`stereoBM_SAD2`** | Block Matching using Sum of Absolute Differences (different approach) | [MATLAB](./matlab/stereoBM_SAD2.m) / [Python](./python/stereoBM_SAD2.py) |
| **`stereoBM_Grad`** | Block Matching using Image Gradients | [MATLAB](./matlab/stereoBM_Grad.m) / [Python](./python/stereoBM_Grad.py) |
| **`stereoBM_NCC`** | Block Matching using Normalized Cross-Correlation | [MATLAB](./matlab/stereoBM_NCC.m) / [Python](./python/stereoBM_NCC.py) |
| **`stereoBM_Rank`** | Block Matching using Rank Transformation | [MATLAB](./matlab/stereoBM_Rank.m) / [Python](./python/stereoBM_Rank.py) |
| **`stereoBM_Census`** | Block Matching using Census Transformation and Hamming Distance | [MATLAB](./matlab/stereoBM_Census.m) / [Python](./python/stereoBM_Census.py) |
| **`stereoBM_ASW`** | Block Matching using Adaptive Window (Adaptive Support Weights) | [MATLAB](./matlab/stereoBM_ASW.m) / [Python](./python/stereoBM_ASW.py) |
| **`stereoDP_LR`** | Dynamic Programming with Left–Right Axes DSI | [MATLAB](./matlab/stereoDP_LR.m) / [Python](./python/stereoDP_LR.py) |
| **`stereoDP_LD`** | Dynamic Programming with Left–Disparity Axes DSI | [MATLAB](./matlab/stereoDP_LD.m) / [Python](./python/stereoDP_LD.py) |
| **`stereoSGM`** | Semi-Global Matching | [MATLAB](./matlab/stereoSGM.m) / [Python](./python/stereoSGM.py) |
| **`stereoSGBM`** | Semi-Global Block Matching | [MATLAB](./matlab/stereoSGBM.m) / [Python](./python/stereoSGBM.py) |
| **`stereoBP_Synch`** | Belief Propagation with *Synchronous* Message Update Schedule | [MATLAB](./matlab/stereoBP_Synch.m) / [Python](./python/stereoBP_Synch.py) |
| **`stereoBP_Synch2`** | Belief Propagation with *Synchronous* Message Update Schedule (different approach) | [MATLAB](./matlab/stereoBP_Synch2.m) / [Python](./python/stereoBP_Synch2.py) |
| **`stereoBP_Accel`** | Belief Propagation with *Accelerated* Message Update Schedule | [MATLAB](./matlab/stereoBP_Accel.m) / [Python](./python/stereoBP_Accel.py) |

## Installation

Download the project as ZIP file, unzip it, and run the scripts.

### Python Requirements

- NumPy
- Matplotlib
- OpenCV (`opencv-python`)

## Usage

A stereo matching algorithm works with stereo image pairs to produce disparity maps.
This project contains MATLAB and Python scripts, each implementing a stereo matching algorithm. The files `left.png` and `right.png` contain the stereo image pair used as input.
To use a different stereo pair, replace these two images with your own. In this case, you must also adjust the **disparity levels** parameter in the script you are running.
You may optionally modify other parameters as needed. If the input images contain little or no noise, it is recommended not to use the Gaussian filter.

- The results between MATLAB and Python implementation are similar.
- The different approaches produce same results.

## Performances

The following running times were measured on a Windows PC with a CPU AMD A10-7850K and 8GB of RAM.

| Filename | MATLAB (sec) | Python (sec) | Notes |
| --- | --- | --- | --- |
| **`stereoBM_SAD`** | 0.10 | 0.08 | image display disabled |
| **`stereoBM_SAD2`** | 0.48 | 0.81 | image display disabled |
| **`stereoBM_Grad`** | 0.17 | 0.19 | image display disabled |
| **`stereoBM_NCC`** | 1.52 | 1.84 | image display disabled |
| **`stereoBM_Rank`** | 0.77 | 3.70 | image display disabled |
| **`stereoBM_Census`** | 2.94 | 7.25 | image display disabled |
| **`stereoBM_ASW`** | 20.58 | 46.11 | image display disabled |
| **`stereoDP_LR`** | 0.32 | 5.60 | image display disabled |
| **`stereoDP_LD`** | 0.14 | 0.28 | image display disabled |
| **`stereoSGM`** | 0.81 | 2.45 | image display disabled |
| **`stereoSGBM`** | 0.84 | 2.51 | image display disabled |
| **`stereoBP_Synch`** | 11.16 | 21.00 | image display disabled, 20 iterations |
| **`stereoBP_Synch2`** | 4.83 | 17.57 | image display disabled, 20 iterations |
| **`stereoBP_Accel`** | 9.11 | 15.18 | image display disabled, 20 iterations |

## Results

Below are the disparity maps produced from the **Tsukuba stereo pair**.

![Tsukuba Left](matlab/left.png) ![Tsukuba Right](matlab/right.png)

### Block Matching (SAD)

![Block Matching (SAD) Disparity Map](results/disparityBM_SAD.png)

### Block Matching (Gradient)

![Block Matching (Gradient) Disparity Map](results/disparityBM_Grad.png)

### Block Matching (NCC)

![Block Matching (NCC) Disparity Map](results/disparityBM_NCC.png)

### Block Matching (Rank)

![Block Matching (Rank) Disparity Map](results/disparityBM_Rank.png)

### Block Matching (Census)

![Block Matching (Census) Disparity Map](results/disparityBM_Census.png)

### Block Matching (ASW)

![Block Matching (ASW) Disparity Map](results/disparityBM_ASW.png)

### Dynamic Programming (Left-Right)

![Dynamic Programming (Left-Right) Disparity Map](results/disparityDP_LR.png)

### Dynamic Programming (Left-Disparity)

![Dynamic Programming (Left-Disparity) Disparity Map](results/disparityDP_LD.png)

### Semi-Global Matching

![Semi-Global Matching Disparity Map](results/disparitySGM.png)

### Semi-Global Block Matching

![Semi-Global Block Matching Disparity Map](results/disparitySGBM.png)

### Belief Propagation (Synchronous)

![Belief Propagation (Synchronous) Disparity Map](results/disparityBP_Synch.png)

### Belief Propagation (Accelerated)

![Belief Propagation (Accelerated) Disparity Map](results/disparityBP_Accel.png)

## Links

- Project repository: https://github.com/aposb/stereo-matching-algorithms

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
