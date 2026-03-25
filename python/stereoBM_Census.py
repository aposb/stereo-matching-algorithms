# Stereo Matching using Block Matching (Census Transformation)
# Computes a disparity map from a rectified stereo pair using Block Matching

import math
import time
import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt
from shiftArray import shiftArray

# Set parameters
dispLevels = 16 #disparity range: 0 to dispLevels-1
windowSize = 25

# Define data cost computation
dataCostComputation = lambda left,right: np.sum(left!=right,axis=2) #Hamming distances

# Start timer
timerVal = time.time()

# Load left and right images in grayscale
leftImg = cv.imread("left.png",cv.IMREAD_GRAYSCALE)
rightImg = cv.imread("right.png",cv.IMREAD_GRAYSCALE)

# Apply a Gaussian filter
leftImg = cv.GaussianBlur(leftImg,(5,5),0.6)
rightImg = cv.GaussianBlur(rightImg,(5,5),0.6)

# Get the size
(rows,cols) = leftImg.shape

# Create block vectors
leftBlocks = np.zeros((rows,cols,windowSize**2),dtype=np.uint8)
rightBlocks = np.zeros((rows,cols,windowSize**2),dtype=np.uint8)
b = -math.ceil(windowSize/2)+1
e = math.floor(windowSize/2)+1
i = 0
for dy in range(b,e):
    for dx in range(b,e):
        leftBlocks[:,:,i] = shiftArray(leftImg,[dy,dx])
        rightBlocks[:,:,i] = shiftArray(rightImg,[dy,dx])
        i = i+1 

# Census transformation
leftCensus = leftBlocks>=leftImg[:,:,np.newaxis]
rightCensus = rightBlocks>=rightImg[:,:,np.newaxis]

# Compute window-based matching cost (data cost)
dataCost = np.zeros((rows,cols,dispLevels),dtype=np.int32)
for d in range(dispLevels):
    #rightCensusShifted = shiftArray(rightCensus,[0,d,0])
    rightCensusShifted = np.roll(rightCensus,d,1) #less accurate, better performances
    dataCost[:,:,d] = dataCostComputation(leftCensus,rightCensusShifted)

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
cv.imwrite("disparityBM_Census.png",dispImg)

# Stop timer and display running time
elapsedTime = time.time()-timerVal
print("Running time: {:.2f} seconds".format(elapsedTime))

plt.show()
