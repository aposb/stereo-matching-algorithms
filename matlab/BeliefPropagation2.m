% Stereo Matching using Belief Propagation (with Synchronous message update schedule)
% Computes a disparity map from a rectified stereo pair using Belief Propagation

% Set parameters
dispLevels = 16; %disparity range: 0 to dispLevels-1
iterations = 60;
lambda = 5; %weight of smoothness cost
trunc = 2; %truncation of smoothness cost

% Define data cost computation
dataCostComputation = @(differences) abs(differences); %absolute differences
%dataCostComputation = @(differences) differences.^2; %square differences

% Define smoothness cost computation
smoothnessCostComputation = @(differences) lambda*min(abs(differences),trunc);

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
smoothnessCost4d = zeros(1,1,dispLevels,dispLevels,'int32');
smoothnessCost4d(1,1,:,:) = smoothnessCost;

% Initialize messages
msgFromUp = zeros(rows,cols,dispLevels,'int32');
msgFromDown = zeros(rows,cols,dispLevels,'int32');
msgFromRight = zeros(rows,cols,dispLevels,'int32');
msgFromLeft = zeros(rows,cols,dispLevels,'int32');

figure
energy = zeros(iterations,1);

% Start iterations
for it = 1:iterations

    % Create messages to up
    msgToUp = dataCost + msgFromDown + msgFromRight + msgFromLeft;
    msgToUp = squeeze(min(msgToUp+smoothnessCost4d,[],3));
    msgToUp = msgToUp-min(msgToUp,[],3); %normalize message
    
    % Create messages to down
    msgToDown = dataCost + msgFromUp + msgFromRight + msgFromLeft;
    msgToDown = squeeze(min(msgToDown+smoothnessCost4d,[],3));
    msgToDown = msgToDown-min(msgToDown,[],3); %normalize message
    
    % Create messages to right
    msgToRight = dataCost + msgFromUp + msgFromDown + msgFromLeft;
    msgToRight = squeeze(min(msgToRight+smoothnessCost4d,[],3));
    msgToRight = msgToRight-min(msgToRight,[],3); %normalize message
    
    % Create messages to left
    msgToLeft = dataCost + msgFromUp + msgFromDown + msgFromRight;
    msgToLeft = squeeze(min(msgToLeft+smoothnessCost4d,[],3));
    msgToLeft = msgToLeft-min(msgToLeft,[],3); %normalize message

    % Send messages
    msgFromDown(1:end-1,:,:) = msgToUp(2:end,:,:); %shift up
    msgFromUp(2:end,:,:) = msgToDown(1:end-1,:,:); %shift down
    msgFromLeft(:,2:end,:) = msgToRight(:,1:end-1,:); %shift right
    msgFromRight(:,1:end-1,:) = msgToLeft(:,2:end,:); %shift left

    % Compute belief
    %belief = dataCost + msgFromUp + msgFromDown + msgFromRight + msgFromLeft; %standard belief computation
    belief = msgFromUp + msgFromDown + msgFromRight + msgFromLeft; %without dataCost (larger energy but better results)
    
    % Compute the disparity map
    [~,ind] = min(belief,[],3);
    dispMap = ind-1;
    
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
imwrite(dispImg,'disparity.png')