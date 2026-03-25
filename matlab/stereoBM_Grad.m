% Stereo Matching using Block Matching (Image Gradients)
% Computes a disparity map from a rectified stereo pair using Block Matching

% Set parameters
dispLevels = 16; %disparity range: 0 to dispLevels-1
windowSize = 5;

% Define data cost computation
dataCostComputation = @(left,right) sum(abs(left-right),3); %magnitude

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

% Compute image gradients
leftGrad = zeros(rows,cols,2,'double');
[leftGrad(:,:,1),leftGrad(:,:,2)] = imgradientxy(leftImg,'sobel');
rightGrad = zeros(rows,cols,2,'double');
[rightGrad(:,:,1),rightGrad(:,:,2)] = imgradientxy(rightImg,'sobel');

% Compute pixel-based matching cost (data cost)
dataCost = zeros(rows,cols,dispLevels,'double');
for d = 0:dispLevels-1
    %rightGradShifted = shiftArray(rightGrad,[0,d,0]);
    rightGradShifted = circshift(rightGrad,d,2); %less accurate, better performances
    dataCost(:,:,d+1) = dataCostComputation(leftGrad,rightGradShifted);
end

% Aggregate the matching cost
dataCost = int32(convn(dataCost,ones(windowSize,windowSize,1),'same'));

% Compute the disparity map
[~,ind] = min(dataCost,[],3);
dispMap = ind-1;

% Normalize the disparity map for display
scaleFactor = 256/dispLevels;
dispImg = uint8(dispMap*scaleFactor);

% Show disparity map
figure; imshow(dispImg)

% Save disparity map
imwrite(dispImg,'disparityBM_Grad.png')

% Stop timer and display running time
elapsedTime = toc(timerVal);
fprintf('Running time: %.2f seconds\n',elapsedTime)
