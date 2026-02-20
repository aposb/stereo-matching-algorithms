dispLevels = 16;
windowSize = 3;
p1 = 5;
p2 = 10;

% Read the stereo images as grayscale
leftImg = rgb2gray(imread('left.png'));
rightImg = rgb2gray(imread('right.png'));

% Apply a Gaussian filter
leftImg = imgaussfilt(leftImg,0.68,'FilterSize',5);
rightImg = imgaussfilt(rightImg,0.68,'FilterSize',5);

% Get image size
[rows,cols] = size(leftImg);

% Compute data cost (matching cost)
dataCost = zeros(rows,cols,dispLevels);
leftImg = double(leftImg);
rightImg = double(rightImg);
for d = 0:dispLevels-1
    rightImgShifted = [zeros(rows,d),rightImg(:,1:end-d)];
    dataCost(:,:,d+1) = abs(leftImg-rightImgShifted);
end
h = fspecial('average',windowSize);
for i = 1:dispLevels
    dataCost(:,:,i) = conv2(dataCost(:,:,i),h,'same');
end

% Compute smoothness cost
d = 0:dispLevels-1;
diff = abs(d-d');
smoothnessCost = (diff==1)*p1+(diff>=2)*p2;
smoothnessCost3d(1,:,:) = smoothnessCost(:,:);

% Initialize tables with costs for the 8 directions
L1 = zeros(rows,cols,dispLevels);
L2 = zeros(rows,cols,dispLevels);
L3 = zeros(cols,rows,dispLevels);
L4 = zeros(cols,rows,dispLevels);
L5 = zeros(rows,cols,dispLevels);
L6 = zeros(rows,cols,dispLevels);
L7 = zeros(rows,cols,dispLevels);
L8 = zeros(rows,cols,dispLevels);

% left to right direction
for x = 2:cols
    cost = dataCost(:,x-1,:)+L1(:,x-1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L1(:,x,:) = cost-min(cost,[],2);
end

% right to left direction
for x = cols-1:-1:1
    cost = dataCost(:,x+1,:)+L2(:,x+1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L2(:,x,:) = cost-min(cost,[],2);
end

% Rotate dataCost
dataCostRotated = permute(dataCost,[2 1 3]);

% up to down direction
for x = 2:rows
    cost = dataCostRotated(:,x-1,:)+L3(:,x-1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L3(:,x,:) = cost-min(cost,[],2);
end
L3 = permute(L3,[2 1 3]);

% down to up direction
for x = rows-1:-1:1
    cost = dataCostRotated(:,x+1,:)+L4(:,x+1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L4(:,x,:) = cost-min(cost,[],2);
end
L4 = permute(L4,[2 1 3]);

% Edit dataCost
dataCostEdited1 = zeros(rows+cols-1,cols,dispLevels);
dataCostEdited2 = zeros(rows+cols-1,cols,dispLevels);
for i = 1:cols
    dataCostEdited1(:,i,:) = [zeros(cols-i,1,dispLevels);dataCost(:,i,:);zeros(i-1,1,dispLevels)];
    dataCostEdited2(:,i,:) = [zeros(i-1,1,dispLevels);dataCost(:,i,:);zeros(cols-i,1,dispLevels)];
end

% Initialize temporary tables for diagonal directions
L5a = zeros(rows+cols-1,cols,dispLevels);
L6a = zeros(rows+cols-1,cols,dispLevels);
L7a = zeros(rows+cols-1,cols,dispLevels);
L8a = zeros(rows+cols-1,cols,dispLevels);

% left/up to right/down direction
for x = 2:cols
    cost = dataCostEdited1(:,x-1,:)+L5a(:,x-1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L5a(:,x,:) = cost-min(cost,[],2);
end

% right/down to left/up direction
for x = cols-1:-1:1
    cost = dataCostEdited1(:,x+1,:)+L6a(:,x+1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L6a(:,x,:) = cost-min(cost,[],2);
end

% left/down to right/up direction
for x = 2:cols
    cost = dataCostEdited2(:,x-1,:)+L7a(:,x-1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L7a(:,x,:) = cost-min(cost,[],2);
end

% right/up to left/down direction
for x = cols-1:-1:1
    cost = dataCostEdited2(:,x+1,:)+L8a(:,x+1,:);
    cost = min(cost+smoothnessCost3d,[],3);
    L8a(:,x,:) = cost-min(cost,[],2);
end

% Fill tables for the diagonal directions
for i = 1:cols
    L5(:,i,:) = L5a(cols-i+1:rows+cols-i,i,:);
    L6(:,i,:) = L6a(cols-i+1:rows+cols-i,i,:);
    L7(:,i,:) = L7a(i:rows+i-1,i,:);
    L8(:,i,:) = L8a(i:rows+i-1,i,:);
end

% Compute total cost (aggregated cost)
S = L1 + L2 + L3 + L4 + L5 + L6 + L7 + L8;

% Update disparity map
[~,ind] = min(S,[],3);
disparityMap = ind-1;

% Update disparity image
scaleFactor = 256/dispLevels;
disparityImg = uint8(disparityMap*scaleFactor);

% Show disparity image
figure
imshow(disparityImg)

% Save disparity image
imwrite(disparityImg,'disparity.png')
