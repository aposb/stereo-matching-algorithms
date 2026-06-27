function B = shiftBackward(A,n,fillValue)
%shiftBackward Shift an array BACKWARD with specific padding.

    B = circshift(A,-n,3);
    B(:,:,max(end-n+1,1):end) = fillValue;
end