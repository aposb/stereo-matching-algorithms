# Stereo Matching using Belief Propagation (with Synchronous message update schedule)
# Computes a disparity map from a rectified stereo pair using Belief Propagation

import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt

# Set parameters
dispLevels = 16 #disparity range: 0 to dispLevels-1
iterations = 60
lambda_ = 5 #weight of smoothness cost
trunc = 2 #truncation of smoothness cost

# Define data cost computation
dataCostComputation = lambda differences: np.absolute(differences) #absolute differences
#dataCostComputation = lambda differences: differences**2 #square differences

# Define smoothness cost computation
smoothnessCostComputation = lambda differences: lambda_*np.minimum(np.absolute(differences),trunc)

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
smoothnessCost4d = smoothnessCost[np.newaxis,np.newaxis,:,:].astype(np.int32)

# Initialize messages
msgFromUp = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgFromDown = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgFromRight = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgFromLeft = np.zeros((rows,cols,dispLevels),dtype=np.int32)

energy = np.zeros(iterations,dtype=np.int32)

# Start iterations
for it in range(iterations):

    # Create messages to up
    msgToUp = dataCost + msgFromDown + msgFromRight + msgFromLeft
    msgToUp = np.amin(msgToUp[:,:,:,np.newaxis]+smoothnessCost4d,axis=2)
    msgToUp = msgToUp-np.amin(msgToUp,axis=2)[:,:,np.newaxis] #normalize
    
    # Create messages to down
    msgToDown = dataCost + msgFromUp + msgFromRight + msgFromLeft
    msgToDown = np.amin(msgToDown[:,:,:,np.newaxis]+smoothnessCost4d,axis=2)
    msgToDown = msgToDown-np.amin(msgToDown,axis=2)[:,:,np.newaxis] #normalize
    
    # Create messages to right
    msgToRight = dataCost + msgFromUp + msgFromDown + msgFromLeft
    msgToRight = np.amin(msgToRight[:,:,:,np.newaxis]+smoothnessCost4d,axis=2)
    msgToRight = msgToRight-np.amin(msgToRight,axis=2)[:,:,np.newaxis] #normalize
    
    # Create messages to left
    msgToLeft = dataCost + msgFromUp + msgFromDown + msgFromRight
    msgToLeft = np.amin(msgToLeft[:,:,:,np.newaxis]+smoothnessCost4d,axis=2)
    msgToLeft = msgToLeft-np.amin(msgToLeft,axis=2)[:,:,np.newaxis] #normalize
    
    # Send messages
    msgFromDown[0:rows-1,:,:] = msgToUp[1:rows,:,:] #shift up
    msgFromUp[1:rows,:,:] = msgToDown[0:rows-1,:,:] #shift down
    msgFromLeft[:,1:cols,:] = msgToRight[:,0:cols-1,:] #shift right
    msgFromRight[:,0:cols-1,:] = msgToLeft[:,1:cols,:] #shift left

    # Compute belief
    #belief = dataCost + msgFromUp + msgFromDown + msgFromRight + msgFromLeft #standard belief computation
    belief = msgFromUp + msgFromDown + msgFromRight + msgFromLeft #without dataCost (larger energy but better results)
    
    # Compute the disparity map
    dispMap = np.argmin(belief,axis=2)
    
    # Compute energy
    dataEnergy = np.sum(dataCost[np.arange(rows)[:,np.newaxis],np.arange(cols)[np.newaxis,:],dispMap])
    smoothnessEnergyHorizontal = np.sum(smoothnessCostComputation(np.diff(dispMap,n=1,axis=1)))
    smoothnessEnergyVertical = np.sum(smoothnessCostComputation(np.diff(dispMap,n=1,axis=0)))
    energy[it] = dataEnergy+smoothnessEnergyHorizontal+smoothnessEnergyVertical

    # Normalize the disparity map for display
    scaleFactor = 256/dispLevels
    dispImg = (dispMap*scaleFactor).astype(np.uint8)

    # Show disparity map
    plt.cla()
    plt.imshow(dispImg,cmap="gray")
    plt.show(block=False)
    plt.pause(0.01)

    # Show energy and iteration
    print("iteration: {0}/{1}, energy: {2}".format(it+1,iterations,energy[it]))

# Show convergence graph
plt.figure()
plt.plot(np.arange(1,iterations+1),energy,marker="o")
plt.xlabel("Iterations")
plt.ylabel("Energy")
plt.show(block=False)
plt.pause(0.01)

# Save disparity map
cv.imwrite("disparity.png",dispImg)

plt.show()
