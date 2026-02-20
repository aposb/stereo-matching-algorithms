# Stereo Matching using Semi-Global Matching (SGM)
# Computes a disparity map from a rectified stereo pair using Semi-Global Matching

import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt

# Set parameters
dispLevels = 16 #disparity range: 0 to dispLevels-1
p1 = 5 #occlusion penalty 1
p2 = 10 #occlusion penalty 2

# Define data cost computation
dataCostComputation = lambda differences: np.absolute(differences) #absolute differences
#dataCostComputation = lambda differences: differences**2 #square differences

# Define smoothness cost computation
smoothnessCostComputation = lambda differences: (np.absolute(differences)==1)*p1+(np.absolute(differences)>=2)*p2

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

# Initialize path tables for the 8 directions
L1 = np.zeros((rows,cols,dispLevels),dtype=np.int32)
L2 = np.zeros((rows,cols,dispLevels),dtype=np.int32)
L3 = np.zeros((cols,rows,dispLevels),dtype=np.int32)
L4 = np.zeros((cols,rows,dispLevels),dtype=np.int32)
L5 = np.zeros((rows,cols,dispLevels),dtype=np.int32)
L6 = np.zeros((rows,cols,dispLevels),dtype=np.int32)
L7 = np.zeros((rows,cols,dispLevels),dtype=np.int32)
L8 = np.zeros((rows,cols,dispLevels),dtype=np.int32)

# Compute paths for left to right direction
for x in range(1,cols):
    cost = dataCost[:,x-1,:]+L1[:,x-1,:]
    cost = np.amin(cost[:,np.newaxis,:]+smoothnessCost3d,axis=2)
    L1[:,x,:] = cost-np.amin(cost,axis=1)[:,np.newaxis]

# Compute paths for right to left direction
for x in range(cols-2,-1,-1):
    cost = dataCost[:,x+1,:]+L2[:,x+1,:]
    cost = np.amin(cost[:,np.newaxis,:]+smoothnessCost3d,axis=2)
    L2[:,x,:] = cost-np.amin(cost,axis=1)[:,np.newaxis]

# Rotate dataCost for vertical directions
dataCostRotated = np.moveaxis(dataCost,0,1)

# Compute paths for up to down direction
for x in range(1,rows):
    cost = dataCostRotated[:,x-1,:]+L3[:,x-1,:]
    cost = np.amin(cost[:,np.newaxis,:]+smoothnessCost3d,axis=2)
    L3[:,x,:] = cost-np.amin(cost,axis=1)[:,np.newaxis]
L3 = np.moveaxis(L3,0,1)

# Compute paths for down to up direction
for x in range(rows-2,-1,-1):
    cost = dataCostRotated[:,x+1,:]+L4[:,x+1,:]
    cost = np.amin(cost[:,np.newaxis,:]+smoothnessCost3d,axis=2)
    L4[:,x,:] = cost-np.amin(cost,axis=1)[:,np.newaxis]
L4 = np.moveaxis(L4,0,1)

# Edit dataCost for diagonal directions
dataCostEdited1 = np.zeros((rows+cols-1,cols,dispLevels),dtype=np.int32)
dataCostEdited2 = np.zeros((rows+cols-1,cols,dispLevels),dtype=np.int32)
for i in range(cols):
    dataCostEdited1[cols-i-1:rows+cols-i-1,i,:] = dataCost[:,i,:]
    dataCostEdited2[i:rows+i,i,:] = dataCost[:,i,:]

# Initialize temporary tables for diagonal directions
L5a = np.zeros((rows+cols-1,cols,dispLevels),dtype=np.int32)
L6a = np.zeros((rows+cols-1,cols,dispLevels),dtype=np.int32)
L7a = np.zeros((rows+cols-1,cols,dispLevels),dtype=np.int32)
L8a = np.zeros((rows+cols-1,cols,dispLevels),dtype=np.int32)

# Compute paths for left/up to right/down direction
for x in range(1,cols):
    cost = dataCostEdited1[:,x-1,:]+L5a[:,x-1,:]
    cost = np.amin(cost[:,np.newaxis,:]+smoothnessCost3d,axis=2)
    L5a[:,x,:] = cost-np.amin(cost,axis=1)[:,np.newaxis]

# Compute paths for right/down to left/up direction
for x in range(cols-2,-1,-1):
    cost = dataCostEdited1[:,x+1,:]+L6a[:,x+1,:]
    cost = np.amin(cost[:,np.newaxis,:]+smoothnessCost3d,axis=2)
    L6a[:,x,:] = cost-np.amin(cost,axis=1)[:,np.newaxis]

# Compute paths for left/down to right/up direction
for x in range(1,cols):
    cost = dataCostEdited2[:,x-1,:]+L7a[:,x-1,:]
    cost = np.amin(cost[:,np.newaxis,:]+smoothnessCost3d,axis=2)
    L7a[:,x,:] = cost-np.amin(cost,axis=1)[:,np.newaxis]

# Compute paths for right/up to left/down direction
for x in range(cols-2,-1,-1):
    cost = dataCostEdited2[:,x+1,:]+L8a[:,x+1,:]
    cost = np.amin(cost[:,np.newaxis,:]+smoothnessCost3d,axis=2)
    L8a[:,x,:] = cost-np.amin(cost,axis=1)[:,np.newaxis]

# Fill path tables using temporary tables
for i in range(cols):
    L5[:,i,:] = L5a[cols-i-1:rows+cols-i-1,i,:]
    L6[:,i,:] = L6a[cols-i-1:rows+cols-i-1,i,:]
    L7[:,i,:] = L7a[i:rows+i,i,:]
    L8[:,i,:] = L8a[i:rows+i,i,:]

# Compute total cost
#S = dataCost*8 + L1 + L2 + L3 + L4 + L5 + L6 + L7 + L8 #standard total cost computation
S = L1 + L2 + L3 + L4 + L5 + L6 + L7 + L8 #without dataCost*8 (better results)

# Compute the disparity map
dispMap = np.argmin(S,axis=2)

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
