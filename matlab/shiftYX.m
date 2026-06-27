function B = shiftYX(A,y,x,fillValue)
%shiftYX Shift an array by dimensions Y and X with specific padding.

    B = circshift(A,[y x]);
    if y > 0
        B(1:min(y,end),:,:) = fillValue;
    elseif y < 0
        B(max(end+y+1,1):end,:,:) = fillValue;
    end
    if x > 0
        B(:,1:min(x,end),:) = fillValue;
    elseif x < 0
        B(:,max(end+x+1,1):end,:) = fillValue;
    end
end