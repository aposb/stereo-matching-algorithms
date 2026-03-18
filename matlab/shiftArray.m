function outputArray = shiftArray(inputArray,shift)
%shiftArray Shift an array with zero padding (like circshift but no wrap).
%    Parameters:
%        inputArray: Input array (any dimension).
%        shift: vector specifying shift for each dimension (Positive -> shift forward, Negative -> shift backward).
%    Returns:
%        Shifted array with zeros.
%    Example:
%        A = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]
%        B = shiftArray(A,[-2 1]) % shifts first dimension values up by 2 and second dimension right by 1

    sz = size(inputArray);
    nd = ndims(inputArray);
    outputArray = zeros(sz,class(inputArray));
    src = cell(1,nd);
    dst = cell(1,nd);
    for i = 1:nd
        src{i} = max(1,1-shift(i)):min(sz(i),sz(i)-shift(i));
        dst{i} = max(1,1+shift(i)):min(sz(i),sz(i)+shift(i));
    end
    outputArray(dst{:}) = inputArray(src{:});
end