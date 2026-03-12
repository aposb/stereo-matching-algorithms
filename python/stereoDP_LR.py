# Stereo Matching using Dynamic Programming (with Left-Right Axes DSI)
# Computes a disparity map from a rectified stereo pair using Dynamic Programming

import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt

MAX_INT = 2147483647

# Set parameters
dispLevels = 16 #disparity range: 0 to dispLevels-1
Pocc = 5 #occlusion penalty
Pdisc = 1 #vertical discontinuity penalty

# Define data cost computation
dataCostComputation = lambda differences: np.absolute(differences) #absolute differences
#dataCostComputation = lambda differences: differences**2 #square differences

# Predefined smoothness cost computation: Pocc*np.absolute(differences)

# Load left and right images in grayscale
leftImg = cv.imread("left.png",cv.IMREAD_GRAYSCALE)
rightImg = cv.imread("right.png",cv.IMREAD_GRAYSCALE)

# Apply a Gaussian filter
leftImg = cv.GaussianBlur(leftImg,(5,5),0.6)
rightImg = cv.GaussianBlur(rightImg,(5,5),0.6)

# Convert to int32
leftImg = leftImg.astype(np.int32)
rightImg = rightImg.astype(np.int32)

# Get the size
(rows,cols) = leftImg.shape

D = MAX_INT*np.ones((cols+1,cols+1)) #minimum costs
T = np.zeros((cols+1,cols+1)) #transitions
dispMap = np.zeros((rows,cols))

# For each scanline
for y in range(rows):

    # Compute matching cost
    L = leftImg[y,:] #left scanline
    R = rightImg[y,:] #right scanline
    C = dataCostComputation(L-R[np.newaxis,:].T) #matching cost

    # Keep previous transitions
    T0 = T

    # Compute DP table (forward pass)
    D[0,0:dispLevels] = np.arange(dispLevels)*Pocc
    T[0,1:dispLevels] = 2
    for j in range(1,cols+1):
        for i in range(j,np.minimum(j+dispLevels,cols+1)):
            # Compute cost for match and costs for occlusions
            c1 = D[j-1,i-1] + C[j-1,i-1]
            c2 = D[j,i-1] + Pocc
            c3 = D[j-1,i] + Pocc

            # Add discontinuity cost
            if T0[j,i] == 1:
                c2 = c2 + Pdisc
                c3 = c3 + Pdisc
            elif T0[j,i] == 2:
                c1 = c1 + Pdisc
                c3 = c3 + Pdisc
            elif T0[j,i] == 3:
                c1 = c1 + Pdisc
                c2 = c2 + Pdisc

            # Find minimum cost
            if c1 <= c2 and c1 <= c3:
                D[j,i] = c1
                T[j,i] = 1 #match
            elif c2 <= c3:
                D[j,i] = c2
                T[j,i] = 2 #left occlusion
            else:
                D[j,i] = c3
                T[j,i] = 3 #right occlusion

    # Compute disparity map (backtracking)
    i = cols
    j = cols
    while i > 0:
        if T[j,i] == 1:
            dispMap[y,i-1] = i-j
            i = i-1
            j = j-1
        elif T[j,i] == 2:
            dispMap[y,i-1] = i-j #comment this line for occlusion handling
            i = i-1
        elif T[j,i] == 3:
            j = j-1

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
