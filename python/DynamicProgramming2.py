# Stereo Matching using Dynamic Programming (with Left-Disparity Axes DSI)
# Computes a disparity map from a rectified stereo pair using Dynamic Programming

import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt

# Set parameters
dispLevels = 16 #disparity range: 0 to dispLevels-1
Pocc = 5 #occlusion penalty

# Define data cost computation
dataCostComputation = lambda differences: np.absolute(differences) #absolute differences
#dataCostComputation = lambda differences: differences**2 #square differences

# Define smoothness cost computation
smoothnessCostComputation = lambda differences: Pocc*np.absolute(differences)
#smoothnessCostComputation = lambda differences: Pocc*np.minimum(np.absolute(differences),2) #alternative

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

# Compute smoothness cost
d = np.arange(dispLevels)
smoothnessCost = smoothnessCostComputation(d-d[np.newaxis,:].T)
smoothnessCost3d = smoothnessCost[np.newaxis,:,:].astype(np.int32)

D = np.zeros((rows,cols,dispLevels),dtype=np.int32) #minimum costs
T = np.zeros((rows,cols,dispLevels),dtype=np.int32) #transitions
dispMap = np.zeros((rows,cols))

# Compute DP table (forward pass)
for x in range(1,cols):
    cost = dataCost[:,x-1,:]+D[:,x-1,:]
    cost = cost[:,np.newaxis,:]+smoothnessCost3d
    D[:,x,:] = np.amin(cost,axis=2)
    T[:,x,:] = np.argmin(cost,axis=2)

# Compute disparity map (backtracking)
d = np.zeros(rows,dtype=np.int32)
for x in range(cols-1,-1,-1):
    dispMap[:,x] = d
    d = T[np.arange(rows),x,d]

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
