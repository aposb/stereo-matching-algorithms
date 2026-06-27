% Stereo Matching using Iterated Conditional Modes
% Computes a disparity map from a rectified stereo pair using Iterated Conditional Modes

% Set parameters
dispLevels = 16; %disparity range: 0 to dispLevels-1
iterations = 60;
lambda = 5; %weight of smoothness cost
trunc = 2; %truncation of smoothness cost

% Define data cost computation
dataCostComputation = @(left,right) abs(left-right); %absolute differences
%dataCostComputation = @(left,right) (left-right).^2; %square differences

% Define smoothness cost computation
smoothnessCostComputation = @(differences) lambda*min(abs(differences),trunc);

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
    rightImgShifted = shiftRight(rightImg,d,0);
    dataCost(:,:,d+1) = dataCostComputation(leftImg,rightImgShifted);
end

% Initialize the disparity map
[~,ind] = min(dataCost,[],3);
dispMap = int32(ind-1);

figure
energy = zeros(iterations,1);
d = int32(permute(0:dispLevels-1,[1 3 2]));

% Start iterations
for it = 1:iterations

    % Compute local energy
    localEnergy = dataCost + ...
    smoothnessCostComputation(shiftUp(dispMap,1,0)-d) + ...
    smoothnessCostComputation(shiftLeft(dispMap,1,0)-d) + ...
    smoothnessCostComputation(shiftDown(dispMap,1,0)-d) + ...
    smoothnessCostComputation(shiftRight(dispMap,1,0)-d);

    % Compute the disparity map
    [~,ind] = min(localEnergy,[],3);
    dispMap = int32(ind-1);
    
    % Compute energy
    [row,col] = ndgrid(1:size(ind,1),1:size(ind,2));
    linInd = sub2ind(size(dataCost),row,col,ind);
    dataEnergy = sum(sum(dataCost(linInd)));
    smoothnessEnergyHorizontal = sum(sum(smoothnessCostComputation(diff(dispMap,1,2))));
    smoothnessEnergyVertical = sum(sum(smoothnessCostComputation(diff(dispMap,1,1))));
    energy(it) = dataEnergy+smoothnessEnergyHorizontal+smoothnessEnergyVertical;
    
    % Normalize the disparity map for display
    scaleFactor = 256/dispLevels;
    dispImg = uint8(dispMap*scaleFactor);

    % Show disparity map
    imshow(dispImg)
    
    % Show energy and iteration
    fprintf('iteration: %d/%d, energy: %d\n',it,iterations,energy(it))
end

% Show convergence graph
figure
plot(1:iterations,energy,'bo-')
xlabel('Iterations')
ylabel('Energy')

% Save disparity map
imwrite(dispImg,'disparityICM.png')

% Stop timer and display running time
elapsedTime = toc(timerVal);
fprintf('Running time: %.2f seconds\n',elapsedTime)
