function B = shiftLeft(A,n,fillValue)
%shiftLeft Shift an array LEFT with specific padding.

    B = circshift(A,-n,2);
    B(:,max(end-n+1,1):end,:) = fillValue;
end