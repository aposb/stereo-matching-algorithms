% Stereo Matching using Block Matching (Census Transformation)
% Computes a disparity map from a rectified stereo pair using Block Matching

% Set parameters
dispLevels = 16; %disparity range: 0 to dispLevels-1
windowSize = 25;

% Load left and right images in grayscale
leftImg = rgb2gray(imread('left.png'));
rightImg = rgb2gray(imread('right.png'));

% Apply a Gaussian filter
leftImg = imgaussfilt(leftImg,0.6,'FilterSize',5);
rightImg = imgaussfilt(rightImg,0.6,'FilterSize',5);

% Get the size
[rows,cols] = size(leftImg);

% Expand images
r = floor(windowSize/2);
leftExpanded = zeros(rows+windowSize-1,cols+windowSize-1,'uint8');
leftExpanded(1+r:rows+r,1+r:cols+r) = leftImg;
rightExpanded = zeros(rows+windowSize-1,cols+windowSize-1,'uint8');
rightExpanded(1+r:rows+r,1+r:cols+r) = rightImg;

% Census transformation
leftCensus = zeros(rows,cols,windowSize^2,'logical');
rightCensus = zeros(rows,cols,windowSize^2,'logical');
for dy = 0:windowSize-1
    leftExpandedX = leftExpanded(1+dy:rows+dy,:);
    rightExpandedX = rightExpanded(1+dy:rows+dy,:);
    for dx = 0:windowSize-1
        i = dy*windowSize+dx+1;
        leftCensus(:,:,i) = leftExpandedX(:,1+dx:cols+dx)>=leftImg;
        rightCensus(:,:,i) = rightExpandedX(:,1+dx:cols+dx)>=rightImg;
    end
end

% Compute window-based matching cost (data cost)
rightCensusExpanded = zeros(rows,cols+dispLevels-1,windowSize^2,'logical');
rightCensusExpanded(:,dispLevels:end,:) = rightCensus;
dataCost = zeros(rows,cols,dispLevels,'int32');
for d = 0:dispLevels-1
    rightCensusShifted = rightCensusExpanded(:,dispLevels-d:cols+dispLevels-1-d,:);
    dataCost(:,:,d+1) = sum(leftCensus~=rightCensusShifted,3); %Hamming distances
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
imwrite(dispImg,'disparity.png')
