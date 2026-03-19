# Stereo Matching using Block Matching (Image Gradients)
# Computes a disparity map from a rectified stereo pair using Block Matching

import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt
from shiftArray import shiftArray

# Set parameters
dispLevels = 16 #disparity range: 0 to dispLevels-1
windowSize = 5

# Define data cost computation
dataCostComputation = lambda leftX,leftY,rightX,rightY: np.absolute(leftX-rightX)+np.absolute(leftY-rightY) #magnitude

# Load left and right images in grayscale
leftImg = cv.imread("left.png",cv.IMREAD_GRAYSCALE)
rightImg = cv.imread("right.png",cv.IMREAD_GRAYSCALE)

# Apply a Gaussian filter
leftImg = cv.GaussianBlur(leftImg,(5,5),0.6)
rightImg = cv.GaussianBlur(rightImg,(5,5),0.6)

# Get the size
(rows,cols) = leftImg.shape

# Compute image gradients
leftGradX = cv.Sobel(leftImg,cv.CV_64F,1,0,ksize=3)
leftGradY = cv.Sobel(leftImg,cv.CV_64F,0,1,ksize=3)
rightGradX = cv.Sobel(rightImg,cv.CV_64F,1,0,ksize=3)
rightGradY = cv.Sobel(rightImg,cv.CV_64F,0,1,ksize=3)

# Compute pixel-based matching cost (data cost)
dataCost = np.zeros((rows,cols,dispLevels),dtype=np.int32)
for d in range(dispLevels):
    rightGradXShifted = shiftArray(rightGradX,[0,d])
    rightGradYShifted = shiftArray(rightGradY,[0,d])
    #rightGradXShifted = np.roll(rightGradX,d,1) #less accurate, better performances
    #rightGradYShifted = np.roll(rightGradY,d,1) #less accurate, better performances
    dataCost[:,:,d] = dataCostComputation(leftGradX,leftGradY,rightGradXShifted,rightGradYShifted)

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
cv.imwrite("disparityBM_Grad.png",dispImg)

plt.show()
