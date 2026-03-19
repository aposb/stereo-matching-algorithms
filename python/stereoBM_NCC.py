# Stereo Matching using Block Matching (Normalized Cross-Correlation)
# Computes a disparity map from a rectified stereo pair using Block Matching

import math
import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt
from shiftArray import shiftArray

np.seterr(divide='ignore',invalid='ignore')

# Set parameters
dispLevels = 16 #disparity range: 0 to dispLevels-1
windowSize = 5

# Define data cost computation
dataCostComputation = lambda left,right: np.sum(left*right,axis=2)/np.sqrt(np.sum(left**2,axis=2)*np.sum(right**2,axis=2)) #NCC

# Load left and right images in grayscale
leftImg = cv.imread("left.png",cv.IMREAD_GRAYSCALE)
rightImg = cv.imread("right.png",cv.IMREAD_GRAYSCALE)

# Apply a Gaussian filter
leftImg = cv.GaussianBlur(leftImg,(5,5),0.6)
rightImg = cv.GaussianBlur(rightImg,(5,5),0.6)

# Get the size
(rows,cols) = leftImg.shape

# Create block vectors
leftBlocks = np.zeros((rows,cols,windowSize**2),dtype=np.float64)
rightBlocks = np.zeros((rows,cols,windowSize**2),dtype=np.float64)
b = -math.ceil(windowSize/2)+1
e = math.floor(windowSize/2)+1
i = 0
for dy in range(b,e):
    for dx in range(b,e):
        leftBlocks[:,:,i] = shiftArray(leftImg,[dy,dx])
        rightBlocks[:,:,i] = shiftArray(rightImg,[dy,dx])
        i = i+1 

# Compute window-based matching cost (data cost)
leftNormalized = leftBlocks-np.mean(leftBlocks,axis=2)[:,:,np.newaxis]
rightNormalized = rightBlocks-np.mean(rightBlocks,axis=2)[:,:,np.newaxis]
dataCost = np.zeros((rows,cols,dispLevels),dtype=np.float64)
for d in range(dispLevels):
    rightNormalizedShifted = shiftArray(rightNormalized,[0,d,0])
    #rightNormalizedShifted = np.roll(rightNormalized,d,1) #less accurate, better performances
    dataCost[:,:,d] = dataCostComputation(leftNormalized,rightNormalizedShifted)

# Compute the disparity map
dispMap = np.argmax(dataCost,axis=2)

# Normalize the disparity map for display
scaleFactor = 256/dispLevels
dispImg = (dispMap*scaleFactor).astype(np.uint8)

# Show disparity map
plt.imshow(dispImg,cmap="gray")
plt.show(block=False)
plt.pause(0.01)

# Save disparity map
cv.imwrite("disparityBM_NCC.png",dispImg)

plt.show()
