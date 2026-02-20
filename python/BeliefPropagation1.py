# Stereo Matching using Belief Propagation (with Accelerated message update schedule)
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
smoothnessCost3d_1 = smoothnessCost[np.newaxis,:,:].astype(np.int32)
smoothnessCost3d_2 = smoothnessCost[:,np.newaxis,:].astype(np.int32)

# Initialize messages
msgFromUp = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgFromDown = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgFromRight = np.zeros((rows,cols,dispLevels),dtype=np.int32)
msgFromLeft = np.zeros((rows,cols,dispLevels),dtype=np.int32)

energy = np.zeros(iterations,dtype=np.int32)

# Start iterations
for it in range(iterations):

    # Horizontal forward pass - Send messages right
    for x in range(cols-1):
        msg = dataCost[:,x,:]+msgFromUp[:,x,:]+msgFromDown[:,x,:]+msgFromLeft[:,x,:]
        msg = np.amin(msg[:,np.newaxis,:]+smoothnessCost3d_1,axis=2)
        msgFromLeft[:,x+1,:] = msg-np.amin(msg,axis=1)[:,np.newaxis] #normalize message
    
    # Horizontal backward pass - Send messages left
    for x in range(cols-1,0,-1):
        msg = dataCost[:,x,:]+msgFromUp[:,x,:]+msgFromDown[:,x,:]+msgFromRight[:,x,:]
        msg = np.amin(msg[:,np.newaxis,:]+smoothnessCost3d_1,axis=2)
        msgFromRight[:,x-1,:] = msg-np.amin(msg,axis=1)[:,np.newaxis] #normalize message
    
    # Vertical forward pass - Send messages down
    for y in range(rows-1):
        msg = dataCost[y,:,:]+msgFromUp[y,:,:]+msgFromRight[y,:,:]+msgFromLeft[y,:,:]
        msg = np.amin(msg[np.newaxis,:,:]+smoothnessCost3d_2,axis=2).T
        msgFromUp[y+1,:,:] = msg-np.amin(msg,axis=1)[:,np.newaxis] #normalize message
    
    # Vertical backward pass - Send messages up
    for y in range(rows-1,0,-1):
        msg = dataCost[y,:,:]+msgFromDown[y,:,:]+msgFromRight[y,:,:]+msgFromLeft[y,:,:]
        msg = np.amin(msg[np.newaxis,:,:]+smoothnessCost3d_2,axis=2).T
        msgFromDown[y-1,:,:] = msg-np.amin(msg,axis=1)[:,np.newaxis] #normalize message

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
