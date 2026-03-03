# Stereo Matching using Block Matching (Census Transformation)
# Computes a disparity map from a rectified stereo pair using Block Matching

import math
import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt

# Set parameters
dispLevels = 16 #disparity range: 0 to dispLevels-1
windowSize = 25

# Load left and right images in grayscale
leftImg = cv.imread("left.png",cv.IMREAD_GRAYSCALE)
rightImg = cv.imread("right.png",cv.IMREAD_GRAYSCALE)

# Apply a Gaussian filter
leftImg = cv.GaussianBlur(leftImg,(5,5),0.6)
rightImg = cv.GaussianBlur(rightImg,(5,5),0.6)

# Get the size
(rows,cols) = leftImg.shape

# Expand images
r = math.floor(windowSize/2)
leftExpanded = np.zeros((rows+windowSize-1,cols+windowSize-1),dtype=np.uint8)
leftExpanded[r:rows+r,r:cols+r] = leftImg
rightExpanded = np.zeros((rows+windowSize-1,cols+windowSize-1),dtype=np.uint8)
rightExpanded[r:rows+r,r:cols+r] = rightImg

# Census transformation
leftCensus = np.zeros((rows,cols,windowSize**2),dtype=np.bool_)
rightCensus = np.zeros((rows,cols,windowSize**2),dtype=np.bool_)
for dy in range(windowSize):
    leftExpandedX = leftExpanded[dy:rows+dy,:]
    rightExpandedX = rightExpanded[dy:rows+dy,:]
    for dx in range(windowSize):
        i = dy*windowSize+dx
        leftCensus[:,:,i] = leftExpandedX[:,dx:cols+dx]>=leftImg
        rightCensus[:,:,i] = rightExpandedX[:,dx:cols+dx]>=rightImg

# Compute window-based matching cost (data cost)
rightCensusExpanded = np.zeros((rows,cols+dispLevels-1,windowSize**2),dtype=np.bool_)
rightCensusExpanded[:,dispLevels-1:,:] = rightCensus
dataCost = np.zeros((rows,cols,dispLevels),dtype=np.int32)
for d in range(dispLevels):
    rightCensusShifted = rightCensusExpanded[:,dispLevels-1-d:cols+dispLevels-1-d,:]
    dataCost[:,:,d] = np.sum(leftCensus!=rightCensusShifted,axis=2) #Hamming distances

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
