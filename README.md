# Stereo Matching Algorithms in MATLAB and Python

Optimized (very fast) stereo matching algorithms in MATLAB and Python. It includes implementations of Block Matching, Dynamic Programming, Semi-Global Matching, Semi-Global Block Matching, Belief Propagation and Iterated Conditional Modes.

## Features

- Stereo matching algorithms

  - **Block Matching**
  - **Dynamic Programming**
  - **Semi-Global Matching**
  - **Semi-Global Block Matching**
  - **Belief Propagation**
  - **Iterated Conditional Modes**

- Multiple different versions of the algorithms

- All algorithms are implemented in both MATLAB and Python

- The algorithms are optimized for performance using matrix operations and other techniques

## Algorithms

| Name | Description | MATLAB | Python |
| --- | --- | --- | --- |
| **Block Matching (SAD)** | Block Matching using Sum of Absolute Differences | **[`stereoBM_SAD.m`](./matlab/stereoBM_SAD.m)** | **[`stereoBM_SAD.py`](./python/stereoBM_SAD.py)** |
| **Block Matching (SAD)** | Block Matching using Sum of Absolute Differences (different approach) | **[`stereoBM_SAD2.m`](./matlab/stereoBM_SAD2.m)** | **[`stereoBM_SAD2.py`](./python/stereoBM_SAD2.py)** |
| **Block Matching (Gradient)** | Block Matching using Image Gradients | **[`stereoBM_Grad.m`](./matlab/stereoBM_Grad.m)** | **[`stereoBM_Grad.py`](./python/stereoBM_Grad.py)** |
| **Block Matching (NCC)** | Block Matching using Normalized Cross-Correlation | **[`stereoBM_NCC.m`](./matlab/stereoBM_NCC.m)** | **[`stereoBM_NCC.py`](./python/stereoBM_NCC.py)** |
| **Block Matching (Rank)** | Block Matching using Rank Transformation | **[`stereoBM_Rank.m`](./matlab/stereoBM_Rank.m)** | **[`stereoBM_Rank.py`](./python/stereoBM_Rank.py)** |
| **Block Matching (Census)** | Block Matching using Census Transformation and Hamming Distance | **[`stereoBM_Census.m`](./matlab/stereoBM_Census.m)** | **[`stereoBM_Census.py`](./python/stereoBM_Census.py)** |
| **Block Matching (Adaptive)** | Block Matching using Adaptive Window (Adaptive Support Weights) | **[`stereoBM_ASW.m`](./matlab/stereoBM_ASW.m)** | **[`stereoBM_ASW.py`](./python/stereoBM_ASW.py)** |
| **Dynamic Programming (Left-Right)** | Dynamic Programming with Left–Right Axes DSI | **[`stereoDP_LR.m`](./matlab/stereoDP_LR.m)** | **[`stereoDP_LR.py`](./python/stereoDP_LR.py)** |
| **Dynamic Programming (Left-Disparity)** | Dynamic Programming with Left–Disparity Axes DSI | **[`stereoDP_LD.m`](./matlab/stereoDP_LD.m)** | **[`stereoDP_LD.py`](./python/stereoDP_LD.py)** |
| **Semi-Global Matching** | Semi-Global Matching with 8-path cost aggregation | **[`stereoSGM.m`](./matlab/stereoSGM.m)** | **[`stereoSGM.py`](./python/stereoSGM.py)** |
| **Semi-Global Block Matching** | Semi-Global Block Matching with 8-path cost aggregation | **[`stereoSGBM.m`](./matlab/stereoSGBM.m)** | **[`stereoSGBM.py`](./python/stereoSGBM.py)** |
| **Belief Propagation (Accelerated)** | Belief Propagation with *Accelerated* (or *Directional*) Message Update Schedule | **[`stereoBP_Accel.m`](./matlab/stereoBP_Accel.m)** | **[`stereoBP_Accel.py`](./python/stereoBP_Accel.py)** |
| **Belief Propagation (Synchronous)** | Belief Propagation with *Synchronous* Message Update Schedule | **[`stereoBP_Synch.m`](./matlab/stereoBP_Synch.m)** | **[`stereoBP_Synch.py`](./python/stereoBP_Synch.py)** |
| **Belief Propagation (Synchronous)** | Belief Propagation with *Synchronous* Message Update Schedule (different approach) | **[`stereoBP_Synch2.m`](./matlab/stereoBP_Synch2.m)** | **[`stereoBP_Synch2.py`](./python/stereoBP_Synch2.py)** |
| **Belief Propagation (Bipartite)** | Belief Propagation with *Bipartite* Message Update Schedule | **[`stereoBP_Bipart.m`](./matlab/stereoBP_Bipart.m)** | **[`stereoBP_Bipart.py`](./python/stereoBP_Bipart.py)** |
| **Iterated Conditional Modes** | Iterated Conditional Modes with *Synchronous* Update Schedule | **[`stereoICM.m`](./matlab/stereoICM.m)** | **[`stereoICM.py`](./python/stereoICM.py)** |

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

The following running times are in seconds and were measured on a Windows PC with a CPU AMD A10-7850K and 8GB of RAM.

| Filename | Running Time MATLAB | Running Time Python | Notes |
| --- |:---:|:---:| --- |
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
| **`stereoBP_Accel`** | 9.11 | 15.18 | image display disabled, 20 iterations |
| **`stereoBP_Synch`** | 11.16 | 21.00 | image display disabled, 20 iterations |
| **`stereoBP_Synch2`** | 4.83 | 17.57 | image display disabled, 20 iterations |
| **`stereoBP_Bipart`** | 23.38 | 45.79 | image display disabled, 20 iterations |
| **`stereoICM`** | 1.95 | 5.90 | image display disabled, 20 iterations |

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

### Block Matching (Adaptive)

![Block Matching (Adaptive) Disparity Map](results/disparityBM_ASW.png)

### Dynamic Programming (Left-Right)

![Dynamic Programming (Left-Right) Disparity Map](results/disparityDP_LR.png)

### Dynamic Programming (Left-Disparity)

![Dynamic Programming (Left-Disparity) Disparity Map](results/disparityDP_LD.png)

### Semi-Global Matching

![Semi-Global Matching Disparity Map](results/disparitySGM.png)

### Semi-Global Block Matching

![Semi-Global Block Matching Disparity Map](results/disparitySGBM.png)

### Belief Propagation (Accelerated)

![Belief Propagation (Accelerated) Disparity Map](results/disparityBP_Accel.png)

### Belief Propagation (Synchronous)

![Belief Propagation (Synchronous) Disparity Map](results/disparityBP_Synch.png)

### Belief Propagation (Bipartite)

![Belief Propagation (Bipartite) Disparity Map](results/disparityBP_Bipart.png)

### Iterated Conditional Modes

![Iterated Conditional Modes Disparity Map](results/disparityICM.png)

## Links

### Project Repository

- [Stereo Matching Algorithms in MATLAB and Python](https://github.com/aposb/stereo-matching-algorithms)

### Related Projects

- [Basic Stereo Algorithms (Evolution)](https://github.com/aposb/stereo-algorithms-evolution)
- [Belief Propagation for Stereo Matching (Sum-Product, Max-Product, Min-Sum)](https://github.com/aposb/belief-propagation-for-stereo)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
