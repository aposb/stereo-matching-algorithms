function B = shiftDown(A,n,fillValue)
%shiftDown Shift an array DOWN with specific padding.

    B = circshift(A,n,1);
    B(1:min(n,end),:,:) = fillValue;
end