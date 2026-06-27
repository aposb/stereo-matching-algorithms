function B = shiftForward(A,n,fillValue)
%shiftForward Shift an array FORWARD with specific padding.

    B = circshift(A,n,3);
    B(:,:,1:min(n,end)) = fillValue;
end