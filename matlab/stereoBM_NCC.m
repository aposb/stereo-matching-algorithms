% Stereo Matching using Block Matching (Normalized Cross-Correlation)
% Computes a disparity map from a rectified stereo pair using Block Matching

% Set parameters
dispLevels = 16; %disparity range: 0 to dispLevels-1
windowSize = 5;

% Define data cost computation
dataCostComputation = @(left,right) sum(left.*right,3)./sqrt(sum(left.^2,3).*sum(right.^2,3)); %NCC

% Load left and right images in grayscale
leftImg = rgb2gray(imread('left.png'));
rightImg = rgb2gray(imread('right.png'));

% Apply a Gaussian filter
leftImg = imgaussfilt(leftImg,0.6,'FilterSize',5);
rightImg = imgaussfilt(rightImg,0.6,'FilterSize',5);

% Get the size
[rows,cols] = size(leftImg);

% Create block vectors
leftBlocks = zeros(rows,cols,windowSize^2,'double');
rightBlocks = zeros(rows,cols,windowSize^2,'double');
b = -ceil(windowSize/2)+1;
e = floor(windowSize/2);
i = 1;
for dy = b:e
    for dx = b:e
        leftBlocks(:,:,i) = shiftArray(leftImg,[dy,dx]);
        rightBlocks(:,:,i) = shiftArray(rightImg,[dy,dx]);
        i = i+1;
    end
end

% Compute window-based matching cost (data cost)
leftNormalized = leftBlocks-mean(leftBlocks,3);
rightNormalized = rightBlocks-mean(rightBlocks,3);
dataCost = zeros(rows,cols,dispLevels,'double');
for d = 0:dispLevels-1
    rightNormalizedShifted = shiftArray(rightNormalized,[0,d,0]);
    %rightNormalizedShifted = circshift(rightNormalized,d,2); %less accurate, better performances
    dataCost(:,:,d+1) = dataCostComputation(leftNormalized,rightNormalizedShifted);
end

% Compute the disparity map
[~,ind] = max(dataCost,[],3);
dispMap = ind-1;

% Normalize the disparity map for display
scaleFactor = 256/dispLevels;
dispImg = uint8(dispMap*scaleFactor);

% Show disparity map
figure; imshow(dispImg)

% Save disparity map
imwrite(dispImg,'disparityBM_NCC.png')
