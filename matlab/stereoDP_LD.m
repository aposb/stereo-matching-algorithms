% Stereo Matching using Dynamic Programming (with Left-Disparity Axes DSI)
% Computes a disparity map from a rectified stereo pair using Dynamic Programming

% Set parameters
dispLevels = 16; %disparity range: 0 to dispLevels-1
Pocc = 5; %occlusion penalty

% Define data cost computation
dataCostComputation = @(left,right) abs(left-right); %absolute differences
%dataCostComputation = @(left,right) (left-right).^2; %square differences

% Define smoothness cost computation
smoothnessCostComputation = @(differences) Pocc*abs(differences);
%smoothnessCostComputation = @(differences) Pocc*min(abs(differences),2); %alternative

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

% Convert to int32
leftImg = int32(leftImg);
rightImg = int32(rightImg);

% Compute pixel-based matching cost (data cost)
dataCost = zeros(rows,cols,dispLevels,'int32');
for d = 0:dispLevels-1
    rightImgShifted = shiftArray(rightImg,[0,d]);
    %rightImgShifted = circshift(rightImg,d,2); %less accurate, better performances
    dataCost(:,:,d+1) = dataCostComputation(leftImg,rightImgShifted);
end

% Compute smoothness cost
d = 0:dispLevels-1;
smoothnessCost = smoothnessCostComputation(d-d.');
smoothnessCost3d = zeros(1,dispLevels,dispLevels,'int32');
smoothnessCost3d(1,:,:) = smoothnessCost;

D = zeros(rows,cols,dispLevels,'int32'); %minimum costs
T = zeros(rows,cols,dispLevels,'int32'); %transitions
dispMap = zeros(rows,cols);

% Compute DP table (forward pass)
for x = 2:cols
    cost = dataCost(:,x-1,:)+D(:,x-1,:);
    [cost,ind] = min(cost+smoothnessCost3d,[],3);
    D(:,x,:) = cost;
    T(:,x,:) = ind;
end

% Compute disparity map (backtracking)
d = ones(rows,1);
for x = cols:-1:1
    dispMap(:,x) = d-1;
    linInd = sub2ind(size(T),(1:rows).',x*ones(rows,1),d);
    d = T(linInd);
end

% Normalize the disparity map for display
scaleFactor = 256/dispLevels;
dispImg = uint8(dispMap*scaleFactor);

% Show disparity map
figure; imshow(dispImg)

% Save disparity map
imwrite(dispImg,'disparityDP_LD.png')

% Compute and display elapsed time
elapsedTime = toc(timerVal);
fprintf('Elapsed time is %.2f\n',elapsedTime)
