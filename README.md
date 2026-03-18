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
| **`stereoBM_Census`** | Block Matching using Census Transformation and Hamming Distance | [MATLAB](./matlab/stereoBM_Census.m) / [Python](./python/stereoBM_Census.py) |
| **`stereoDP_LR`** | Dynamic Programming with Left–Right Axes DSI | [MATLAB](./matlab/stereoDP_LR.m) / [Python](./python/stereoDP_LR.py) |
| **`stereoDP_LD`** | Dynamic Programming with Left–Disparity Axes DSI | [MATLAB](./matlab/stereoDP_LD.m) / [Python](./python/stereoDP_LD.py) |
| **`stereoSGM`** | Semi-Global Matching | [MATLAB](./matlab/stereoSGM.m) / [Python](./python/stereoSGM.py) |
| **`stereoSGBM`** | Semi-Global Block Matching | [MATLAB](./matlab/stereoSGBM.m) / [Python](./python/stereoSGBM.py) |
| **`stereoBP_Accel`** | Belief Propagation with *Accelerated* Message Update Schedule | [MATLAB](./matlab/stereoBP_Accel.m) / [Python](./python/stereoBP_Accel.py) |
| **`stereoBP_Synch`** | Belief Propagation with *Synchronous* Message Update Schedule | [MATLAB](./matlab/stereoBP_Synch.m) / [Python](./python/stereoBP_Synch.py) |
| **`stereoBP_Synch2`** | Belief Propagation with *Synchronous* Message Update Schedule (different approach) | [MATLAB](./matlab/stereoBP_Synch2.m) / [Python](./python/stereoBP_Synch2.py) |

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

The results between MATLAB and Python implementation are similar.

## Results

Below are the disparity maps produced from the **Tsukuba stereo pair**.

![Tsukuba Left](matlab/left.png) ![Tsukuba Right](matlab/right.png)

### Block Matching (SAD)

![Block Matching (SAD) Disparity Map](results/disparityBM_SAD.png)

### Block Matching (Census)

![Block Matching (Census) Disparity Map](results/disparityBM_Census.png)

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

The two different approaches to Belief Propagation with Synchronous message update schedule produce same results.

## Links

- Project repository: https://github.com/aposb/stereo-matching-algorithms

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
