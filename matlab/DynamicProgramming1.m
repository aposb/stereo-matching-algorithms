occlusionCost = 10;
discontinuityCost = 3;
dispLevels = 16;

% Read stereo image
left = rgb2gray(imread('Left.png'));
right = rgb2gray(imread('Right.png'));

% Use gaussian filter
left = imgaussfilt(left,0.6,'FilterSize',5);
right = imgaussfilt(right,0.6,'FilterSize',5);

% Get image size
[height,width] = size(left);

C = ones(width,width) * Inf; % Minimal costs
T = zeros(width,width); % Optimal transitions
dispMap = zeros(height,width);

% For every scanline
for y=1:height

	% Compute matching cost
    leftSL = double(left(y,:));
    rightSL = double(right(y,:));
    matchingCost = abs(leftSL-rightSL');
	
    T0 = T;

	% Forward step
    if matchingCost(1,1) <= occlusionCost
        C(1,1) = matchingCost(1,1);
        T(1,1) = 1;
    else
        C(1,1) = occlusionCost;
        T(1,1) = 2;
    end
    C(1,2:dispLevels) = C(1,1) + (1:dispLevels-1) * occlusionCost;
    T(1,2:dispLevels) = 2;
    for x2 = 2:width
        for x1 = x2:min(x2+dispLevels-1,width)
			% Compute costs
            c1 = C(x2-1,x1-1) + matchingCost(x2,x1);
            c2 = C(x2,x1-1) + occlusionCost;
            c3 = C(x2-1,x1) + occlusionCost;

			% Add discontinuity cost
            if T0(x2,x1) == 1
                c2 = c2 + discontinuityCost;
                c3 = c3 + discontinuityCost;
            elseif T0(x2,x1) == 2
                c1 = c1 + discontinuityCost;
                c3 = c3 + discontinuityCost;
            elseif T0(x2,x1) == 3
                c1 = c1 + discontinuityCost;
                c2 = c2 + discontinuityCost;
            end

			% Find minimal cost
            if c1 <= c2 && c1 <= c3
                C(x2,x1) = c1;
                T(x2,x1) = 1; % Sequential
            elseif c2 <= c3
                C(x2,x1) = c2;
                T(x2,x1) = 2; % Occluded
            else
                C(x2,x1) = c3;
                T(x2,x1) = 3; % Disoccluded
            end
        end
    end

	% Backtracking
    x1 = width;
    x2 = width;
    while x1 >= 1
        if T(x2,x1) == 1
            dispMap(y,x1) = x1-x2;
            x1 = x1-1;
            x2 = x2-1;
        elseif T(x2,x1) == 2
            %dispMap(y,x1) = x1-x2; % Hide occluded pixels
            x1 = x1-1;
        elseif T(x2,x1) == 3
            x2 = x2-1;
        end
    end
end

% Convert disparity map to image
scaleFactor = 256/dispLevels;
dispImage = uint8(dispMap*scaleFactor);

% Show disparity image
imshow(dispImage)

% Save disparity image
imwrite(dispImage,'Disparity.png')
