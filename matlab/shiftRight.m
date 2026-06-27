function B = shiftRight(A,n,fillValue)
%shiftRight Shift an array RIGHT with specific padding.

    B = circshift(A,n,2);
    B(:,1:min(n,end),:) = fillValue;
end