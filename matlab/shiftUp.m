function B = shiftUp(A,n,fillValue)
%shiftUp Shift an array UP with specific padding.

    B = circshift(A,-n,1);
    B(max(end-n+1,1):end,:,:) = fillValue;
end