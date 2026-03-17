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

## Structure

### MATLAB Implementations

> Inside `matlab` folder

| Filename | Description |
| --- | --- |
| **[`stereoBM_SAD.m`](./matlab/stereoBM_SAD.m)** | Block Matching using Sum of Absolute Differences |
| **[`stereoBM_Census.m`](./matlab/stereoBM_Census.m)** | Block Matching using Census Transformation and Hamming Distance |
| **[`stereoDP_LR.m`](./matlab/stereoDP_LR.m)** | Dynamic Programming with Left–Right Axes DSI |
| **[`stereoDP_LD.m`](./matlab/stereoDP_LD.m)** | Dynamic Programming with Left–Disparity Axes DSI |
| **[`stereoSGM.m`](./matlab/stereoSGM.m)** | Semi-Global Matching |
| **[`stereoSGBM.m`](./matlab/stereoSGBM.m)** | Semi-Global Block Matching |
| **[`stereoBP_Accel.m`](./matlab/stereoBP_Accel.m)** | Belief Propagation with *Accelerated* Message Update Schedule |
| **[`stereoBP_Synch.m`](./matlab/stereoBP_Synch.m)** | Belief Propagation with *Synchronous* Message Update Schedule |
| **[`stereoBP_Synch2.m`](./matlab/stereoBP_Synch2.m)** | Belief Propagation with *Synchronous* Message Update Schedule (different approach) |

### Python Implementations

> Inside `python` folder

| Filename | Description |
| --- | --- |
| **[`stereoBM_SAD.py`](./python/stereoBM_SAD.py)** | Block Matching using Sum of Absolute Differences |
| **[`stereoBM_Census.py`](./python/stereoBM_Census.py)** | Block Matching using Census Transformation and Hamming Distance |
| **[`stereoDP_LR.py`](./python/stereoDP_LR.py)** | Dynamic Programming with Left–Right Axes DSI |
| **[`stereoDP_LD.py`](./python/stereoDP_LD.py)** | Dynamic Programming with Left–Disparity Axes DSI |
| **[`stereoSGM.py`](./python/stereoSGM.py)** | Semi-Global Matching |
| **[`stereoSGBM.py`](./python/stereoSGBM.py)** | Semi-Global Block Matching |
| **[`stereoBP_Accel.py`](./python/stereoBP_Accel.py)** | Belief Propagation with *Accelerated* Message Update Schedule |
| **[`stereoBP_Synch.py`](./python/stereoBP_Synch.py)** | Belief Propagation with *Synchronous* Message Update Schedule |
| **[`stereoBP_Synch2.py`](./python/stereoBP_Synch2.py)** | Belief Propagation with *Synchronous* Message Update Schedule (different approach) |

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

## Useful Links

- Project repository: https://github.com/aposb/stereo-matching-algorithms

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
