% Stereo Matching using Semi-Global Matching (SGM)
% Computes a disparity map from a rectified stereo pair using Semi-Global Matching

% Set parameters
dispLevels = 16; %disparity range: 0 to dispLevels-1
p1 = 5; %occlusion penalty 1
p2 = 10; %occlusion penalty 2

% Define data cost computation
dataCostComputation = @(differences) abs(differences); %absolute differences
%dataCostComputation = @(differences) differences.^2; %square differences

% Define smoothness cost computation
smoothnessCostComputation = @(differences) (abs(differences)==1)*p1+(abs(differences)>=2)*p2;

% Load left and right images in grayscale
leftImg = rgb2gray(imread('left.png'));
rightImg = rgb2gray(imread('right.png'));

% Apply a Gaussian filter
leftImg = imgaussfilt(leftImg,0.6,'FilterSize',5);
rightImg = imgaussfilt(rightImg,0.6,'FilterSize',5);

% Get the size
[rows,cols] = size(leftImg);

% Compute pixel-based matching cost (data cost)
rightImgShifted = zeros(rows,cols,dispLevels,'int32');
for d = 0:dispLevels-1
    rightImgShifted(:,d+1:end,d+1) = rightImg(:,1:end-d);
end
dataCost = dataCostComputation(int32(leftImg)-rightImgShifted);

% Compute smoothness cost
d = 0:dispLevels-1;
smoothnessCost = smoothnessCostComputation(d-d.');
smoothnessCost3d = zeros(1,dispLevels,dispLevels,'int32');
smoothnessCost3d(1,:,:) = smoothnessCost;

% Initialize path tables for the 8 directions
L1 = zeros(rows,cols,dispLevels,'int32');
L2 = zeros(rows,cols,dispLevels,'int32');
L3 = zeros(cols,rows,dispLevels,'int32');
L4 = zeros(cols,rows,dispLevels,'int32');
L5 = zeros(rows,cols,dispLevels,'int32');
L6 = zeros(rows,cols,dispLevels,'int32');
L7 = zeros(rows,cols,dispLevels,'int32');
L8 = zeros(rows,cols,dispLevels,'int32');

% Compute paths for left to right direction
for x = 2:cols
    cost = dataCost(:,x-1,:)+L1(:,x-1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L1(:,x,:) = cost-min(cost,[],2);
end

% Compute paths for right to left direction
for x = cols-1:-1:1
    cost = dataCost(:,x+1,:)+L2(:,x+1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L2(:,x,:) = cost-min(cost,[],2);
end

% Rotate dataCost for vertical directions
dataCostRotated = permute(dataCost,[2 1 3]);

% Compute paths for up to down direction
for x = 2:rows
    cost = dataCostRotated(:,x-1,:)+L3(:,x-1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L3(:,x,:) = cost-min(cost,[],2);
end
L3 = permute(L3,[2 1 3]);

% Compute paths for down to up direction
for x = rows-1:-1:1
    cost = dataCostRotated(:,x+1,:)+L4(:,x+1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L4(:,x,:) = cost-min(cost,[],2);
end
L4 = permute(L4,[2 1 3]);

% Edit dataCost for diagonal directions
dataCostEdited1 = zeros(rows+cols-1,cols,dispLevels,'int32');
dataCostEdited2 = zeros(rows+cols-1,cols,dispLevels,'int32');
for i = 1:cols
    dataCostEdited1(cols-i+1:rows+cols-i,i,:) = dataCost(:,i,:);
    dataCostEdited2(i:rows+i-1,i,:) = dataCost(:,i,:);
end

% Initialize temporary tables for diagonal directions
L5a = zeros(rows+cols-1,cols,dispLevels,'int32');
L6a = zeros(rows+cols-1,cols,dispLevels,'int32');
L7a = zeros(rows+cols-1,cols,dispLevels,'int32');
L8a = zeros(rows+cols-1,cols,dispLevels,'int32');

% Compute paths for left/up to right/down direction
for x = 2:cols
    cost = dataCostEdited1(:,x-1,:)+L5a(:,x-1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L5a(:,x,:) = cost-min(cost,[],2);
end

% Compute paths for right/down to left/up direction
for x = cols-1:-1:1
    cost = dataCostEdited1(:,x+1,:)+L6a(:,x+1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L6a(:,x,:) = cost-min(cost,[],2);
end

% Compute paths for left/down to right/up direction
for x = 2:cols
    cost = dataCostEdited2(:,x-1,:)+L7a(:,x-1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L7a(:,x,:) = cost-min(cost,[],2);
end

% Compute paths for right/up to left/down direction
for x = cols-1:-1:1
    cost = dataCostEdited2(:,x+1,:)+L8a(:,x+1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L8a(:,x,:) = cost-min(cost,[],2);
end

% Fill path tables using temporary tables
for i = 1:cols
    L5(:,i,:) = L5a(cols-i+1:rows+cols-i,i,:);
    L6(:,i,:) = L6a(cols-i+1:rows+cols-i,i,:);
    L7(:,i,:) = L7a(i:rows+i-1,i,:);
    L8(:,i,:) = L8a(i:rows+i-1,i,:);
end

% Compute total cost
%S = dataCost*8 + L1 + L2 + L3 + L4 + L5 + L6 + L7 + L8; %standard total cost computation
S = L1 + L2 + L3 + L4 + L5 + L6 + L7 + L8; %without dataCost*8 (better results)

% Compute the disparity map
[~,ind] = min(S,[],3);
dispMap = ind-1;

% Normalize the disparity map for display
scaleFactor = 256/dispLevels;
dispImg = uint8(dispMap*scaleFactor);

% Show disparity map
figure; imshow(dispImg)

% Save disparity map
imwrite(dispImg,'disparity.png')