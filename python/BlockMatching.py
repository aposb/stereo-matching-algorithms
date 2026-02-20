# Stereo Matching using Block Matching
# Computes a disparity map from a rectified stereo pair using Block Matching

import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt

# Set parameters
dispLevels = 16 #disparity range: 0 to dispLevels-1
windowSize = 5

# Define data cost computation
dataCostComputation = lambda differences: np.absolute(differences) #absolute differences
#dataCostComputation = lambda differences: differences**2 #square differences

# Load left and right images in grayscale
leftImg = cv.imread("left.png",cv.IMREAD_GRAYSCALE)
rightImg = cv.imread("right.png",cv.IMREAD_GRAYSCALE)

# Apply a Gaussian filter
leftImg = cv.GaussianBlur(leftImg,(5,5),0.6)
rightImg = cv.GaussianBlur(rightImg,(5,5),0.6)

# Get the size
(rows,cols) = leftImg.shape

# Compute pixel-based matching cost (data cost)
rightImgShifted = np.zeros((rows,cols,dispLevels),dtype=np.int32)
for d in range(dispLevels):
    rightImgShifted[:,d:,d] = rightImg[:,:cols-d]
dataCost = dataCostComputation(leftImg[:,:,np.newaxis]-rightImgShifted)

# Aggregate the matching cost
dataCost = cv.boxFilter(dataCost,-1,(windowSize,windowSize),normalize=False)

# Compute the disparity map
dispMap = np.argmin(dataCost,axis=2)

# Normalize the disparity map for display
scaleFactor = 256/dispLevels
dispImg = (dispMap*scaleFactor).astype(np.uint8)

# Show disparity map
plt.imshow(dispImg,cmap="gray")
plt.show(block=False)
plt.pause(0.01)

# Save disparity map
cv.imwrite("disparity.png",dispImg)

plt.show()
