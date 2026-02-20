# Stereo Matching Algorithms

Optimized (very fast) stereo matching algorithms in MATLAB and Python. It includes implementations of Block Matching, Dynamic Programming, Semi-Global Matching, Semi-Global Block Matching and Belief Propagation.

## Features

### Multiple stereo matching algorithms

- **Block Matching (BM)**
- **Dynamic Programming (DP)**
- **Semi-Global Matching (SGM)**
- **Semi-Global Block Matching (SGBM)**
- **Belief Propagation (BP)**

### Two different versions of Dynamic Programming

- DP with Left–Right Axes DSI
- DP with Left–Disparity Axes DSI

### Three different versions of Belief Propagation

- BP with accelerated message update schedule
- BP with synchronous message update schedule
- BP with synchronous message update schedule (alternative approach)

The algorithms are implemented in both MATLAB and Python.

All algorithms are optimized for performance using matrix operations and other techniques.

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

![Tsukuba Stereo Image](matlab/left.png) ![Tsukuba Stereo Image](matlab/right.png)

### Block Matching

![Block Matching Disparity Map](results/disparity0.png)

### Dynamic Programming (Left-Right)

![Dynamic Programming (Left-Right) Disparity Map](results/disparity1.png)

### Dynamic Programming (Left-Disparity)

![Dynamic Programming (Left-Disparity) Disparity Map](results/disparity2.png)

### Semi-Global Matching

![Semi-Global Matching Disparity Map](results/disparity3.png)

### Semi-Global Block Matching

![Semi-Global Block Matching Disparity Map](results/disparity4.png)

### Belief Propagation (Accelerated)

![Belief Propagation Accelerated Disparity Map](results/disparity5.png)

### Belief Propagation (Synchronous)

![Belief Propagation Synchronous Disparity Map](results/disparity6.png)

The two different approaches to Belief Propagation with Synchronous message update schedule produce same results.

## Useful Links

- Project homepage: -
- Project repository: https://github.com/aposb/stereo-matching-algorithms

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
