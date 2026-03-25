% Stereo Matching using Block Matching (Rank Transformation)
% Computes a disparity map from a rectified stereo pair using Block Matching

% Set parameters
dispLevels = 16; %disparity range: 0 to dispLevels-1
windowSize = 25;

% Define data cost computation
dataCostComputation = @(left,right) abs(left-right); %absolute differences
%dataCostComputation = @(left,right) (left-right).^2; %square differences

% Start timer
timerVal = tic();

% Load left and right images in grayscale
leftImg = rgb2gray(imread('left.png'));
rightImg = rgb2gray(imread('right.png'));

% Apply a Gaussian filter
leftImg = imgaussfilt(leftImg,0.6,'FilterSize',5);
rightImg = imgaussfilt(rightImg,0.6,'FilterSize',5);

% Get the size
[rows,cols] = size(leftImg);

% Create block vectors
leftBlocks = zeros(rows,cols,windowSize^2,'uint8');
rightBlocks = zeros(rows,cols,windowSize^2,'uint8');
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

% Rank transformation
leftRank = sum(leftBlocks>=leftImg,3);
rightRank = sum(rightBlocks>=rightImg,3);

% Compute window-based matching cost (data cost)
dataCost = zeros(rows,cols,dispLevels,'int32');
for d = 0:dispLevels-1
    %rightRankShifted = shiftArray(rightRank,[0,d]);
    rightRankShifted = circshift(rightRank,d,2); %less accurate, better performances
    dataCost(:,:,d+1) = dataCostComputation(leftRank,rightRankShifted);
end

% Compute the disparity map
[~,ind] = min(dataCost,[],3);
dispMap = ind-1;

% Normalize the disparity map for display
scaleFactor = 256/dispLevels;
dispImg = uint8(dispMap*scaleFactor);

% Show disparity map
figure; imshow(dispImg)

% Save disparity map
imwrite(dispImg,'disparityBM_Rank.png')

% Stop timer and display running time
elapsedTime = toc(timerVal);
fprintf('Running time: %.2f seconds\n',elapsedTime)
