dispLevels = 16;
Pocc = 10; % Occlusion penalty

% Read stereo image
left = rgb2gray(imread('Left.png'));
right = rgb2gray(imread('Right.png'));

% Use gaussian filter
left = imgaussfilt(left,0.6,'FilterSize',5);
right = imgaussfilt(right,0.6,'FilterSize',5);

% Get image size
[rows,cols] = size(left);

% Compute matching cost
C = zeros(rows,cols,dispLevels);
for x = 0:dispLevels-1
    rightShifted = [zeros(rows,x),right(:,1:end-x)];
    C(:,:,x+1) = abs(double(left)-double(rightShifted));
end

% Compute smoothness cost
d = 0:dispLevels-1;
smoothnessCost = Pocc*abs(d-d');
%smoothnessCost = Pocc*min(abs(d-d'),2);
smoothnessCost3d(1,:,:) = smoothnessCost(:,:);

D = zeros(rows,cols,dispLevels); % Minimum costs
T = zeros(rows,cols,dispLevels); % Transitions
dispMap = zeros(rows,cols);

% Forward step
for x = 2:cols
    cost = C(:,x-1,:)+D(:,x-1,:);
    [cost,ind] = min(cost+smoothnessCost3d,[],3);
    D(:,x,:) = cost;
    T(:,x,:) = ind;
end

% Backtracking
d = ones(rows,1);
for x = cols:-1:1
    dispMap(:,x) = d-1;
    linInd = sub2ind(size(T),(1:rows)',x*ones(rows,1),d);
    d = T(linInd);
end

% Convert disparity map to image
scaleFactor = 256/dispLevels;
dispImage = uint8(dispMap*scaleFactor);

% Show disparity image
imshow(dispImage)

% Save disparity image
imwrite(dispImage,'Disparity.png')

