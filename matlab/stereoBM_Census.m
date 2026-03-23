% Stereo Matching using Block Matching (Census Transformation)
% Computes a disparity map from a rectified stereo pair using Block Matching

% Set parameters
dispLevels = 16; %disparity range: 0 to dispLevels-1
windowSize = 25;

% Define data cost computation
dataCostComputation = @(left,right) sum(left~=right,3); %Hamming distances

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

% Census transformation
leftCensus = leftBlocks>=leftImg;
rightCensus = rightBlocks>=rightImg;

% Compute window-based matching cost (data cost)
dataCost = zeros(rows,cols,dispLevels,'int32');
for d = 0:dispLevels-1
    rightCensusShifted = shiftArray(rightCensus,[0,d,0]);
    %rightCensusShifted = circshift(rightCensus,d,2); %less accurate, better performances
    dataCost(:,:,d+1) = dataCostComputation(leftCensus,rightCensusShifted);
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
imwrite(dispImg,'disparityBM_Census.png')

% Compute and display elapsed time
elapsedTime = toc(timerVal);
fprintf('Elapsed time is %.2f\n',elapsedTime)
