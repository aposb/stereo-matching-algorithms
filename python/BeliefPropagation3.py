# Stereo Matching using Belief Propagation (with Synchronous message update schedule) - a different aproach
# Computes a disparity map from a rectified stereo pair using Belief Propagation

import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt

MAX_INT = 2147483647

# Set parameters
dispLevels = 16 #disparity range: 0 to dispLevels-1
iterations = 60
lambda_ = 5 #weight of smoothness cost

# Define data cost computation
dataCostComputation = lambda differences: np.absolute(differences) #absolute differences
#dataCostComputation = lambda differences: differences**2 #square differences

# Predefined smoothness cost computation: lambda_*np.minimum(np.absolute(differences),2)

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

# Initialize messages
msgFromUp = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgFromDown = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgFromRight = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgFromLeft = np.zeros((rows,cols,dispLevels),dtype=np.int32)

msgToUp1 = MAX_INT*np.ones((rows,cols,dispLevels+2),dtype=np.int32)
msgToDown1 = MAX_INT*np.ones((rows,cols,dispLevels+2),dtype=np.int32)
msgToRight1 = MAX_INT*np.ones((rows,cols,dispLevels+2),dtype=np.int32)
msgToLeft1 = MAX_INT*np.ones((rows,cols,dispLevels+2),dtype=np.int32)

msgToUp2 = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgToDown2 = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgToRight2 = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgToLeft2 = np.zeros((rows,cols,dispLevels),dtype=np.int32)

costs = np.zeros((rows,cols,3),dtype=np.int32)
energy = np.zeros(iterations,dtype=np.int32)

# Start iterations
for it in range(iterations):

    # Compute messages - Step 1
    msgToUp1[:,:,1:dispLevels+1] = dataCost + msgFromDown + msgFromRight + msgFromLeft
    msgToDown1[:,:,1:dispLevels+1] = dataCost + msgFromUp + msgFromRight + msgFromLeft
    msgToRight1[:,:,1:dispLevels+1] = dataCost + msgFromUp + msgFromDown + msgFromLeft
    msgToLeft1[:,:,1:dispLevels+1] = dataCost + msgFromUp + msgFromDown + msgFromRight
    
    # Find minimum costs
    minMsgToUp = np.amin(msgToUp1,axis=2)
    minMsgToDown = np.amin(msgToDown1,axis=2)
    minMsgToRight = np.amin(msgToRight1,axis=2)
    minMsgToLeft = np.amin(msgToLeft1,axis=2)

    # Compute messages - Step 2
    for i in range(dispLevels):
        # Messages to up
        costs[:,:,0] = msgToUp1[:,:,i+1]
        costs[:,:,1] = np.minimum(msgToUp1[:,:,i],msgToUp1[:,:,i+2])+lambda_
        costs[:,:,2] = minMsgToUp+2*lambda_
        msgToUp2[:,:,i] = np.amin(costs,axis=2)-minMsgToUp
        
        # Messages to down
        costs[:,:,0] = msgToDown1[:,:,i+1]
        costs[:,:,1] = np.minimum(msgToDown1[:,:,i],msgToDown1[:,:,i+2])+lambda_
        costs[:,:,2] = minMsgToDown+2*lambda_
        msgToDown2[:,:,i] = np.amin(costs,axis=2)-minMsgToDown
        
        # Messages to right
        costs[:,:,0] = msgToRight1[:,:,i+1]
        costs[:,:,1] = np.minimum(msgToRight1[:,:,i],msgToRight1[:,:,i+2])+lambda_
        costs[:,:,2] = minMsgToRight+2*lambda_
        msgToRight2[:,:,i] = np.amin(costs,axis=2)-minMsgToRight
        
        # Messages to left
        costs[:,:,0] = msgToLeft1[:,:,i+1]
        costs[:,:,1] = np.minimum(msgToLeft1[:,:,i],msgToLeft1[:,:,i+2])+lambda_
        costs[:,:,2] = minMsgToLeft+2*lambda_
        msgToLeft2[:,:,i] = np.amin(costs,axis=2)-minMsgToLeft

    # Send messages
    msgFromDown[0:rows-1,:,:] = msgToUp2[1:rows,:,:] #shift up
    msgFromUp[1:rows,:,:] = msgToDown2[0:rows-1,:,:] #shift down
    msgFromLeft[:,1:cols,:] = msgToRight2[:,0:cols-1,:] #shift right
    msgFromRight[:,0:cols-1,:] = msgToLeft2[:,1:cols,:] #shift left

    # Compute belief
    #belief = dataCost + msgFromUp + msgFromDown + msgFromRight + msgFromLeft #standard belief computation
    belief = msgFromUp + msgFromDown + msgFromRight + msgFromLeft #without dataCost (larger energy but better results)
    
    # Compute the disparity map
    dispMap = np.argmin(belief,axis=2)
    
    # Compute energy
    dataEnergy = np.sum(dataCost[np.arange(rows)[:,np.newaxis],np.arange(cols)[np.newaxis,:],dispMap])
    smoothnessEnergyHorizontal = np.sum(lambda_*np.minimum(np.absolute(np.diff(dispMap,n=1,axis=1)),2))
    smoothnessEnergyVertical = np.sum(lambda_*np.minimum(np.absolute(np.diff(dispMap,n=1,axis=0)),2))
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
