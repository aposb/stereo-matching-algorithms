import numpy as np

def shiftArray(inputArray,shift):
    """shiftArray Shift an array with zero padding (like np.roll but no wrap).
    Parameters:
        inputArray: Input array (any dimension).
        shift: vector specifying shift for each dimension (Positive -> shift forward, Negative -> shift backward).
    Returns:
        Shifted array with zeros.
    Example:
        A = np.array([[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]])
        B = shiftArray(A,[-2,1]) # shifts first dimension values up by 2 and second dimension right by 1"""

    sz = inputArray.shape
    nd = inputArray.ndim
    outputArray = np.zeros_like(inputArray)
    src = []
    dst = []
    for i in range(0,nd):
        src.append(slice(max(0,0-shift[i]),min(sz[i],sz[i]-shift[i])))
        dst.append(slice(max(0,0+shift[i]),min(sz[i],sz[i]+shift[i])))
    outputArray[tuple(dst)] = inputArray[tuple(src)]
    return outputArray
