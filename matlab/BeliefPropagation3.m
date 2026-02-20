% Stereo Matching using Belief Propagation (with Synchronous message update schedule) - a different aproach
% Computes a disparity map from a rectified stereo pair using Belief Propagation

% Set parameters
dispLevels = 16; %disparity range: 0 to dispLevels-1
iterations = 60;
lambda = 5; %weight of smoothness cost

% Define data cost computation
dataCostComputation = @(differences) abs(differences); %absolute differences
%dataCostComputation = @(differences) differences.^2; %square differences

% Predefined smoothness cost computation: lambda*min(abs(differences),2)

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

% Initialize messages
msgFromUp = zeros(rows,cols,dispLevels,'int32');
msgFromDown = zeros(rows,cols,dispLevels,'int32');
msgFromRight = zeros(rows,cols,dispLevels,'int32');
msgFromLeft = zeros(rows,cols,dispLevels,'int32');

msgToUp1 = intmax*ones(rows,cols,dispLevels+2,'int32');
msgToDown1 = intmax*ones(rows,cols,dispLevels+2,'int32');
msgToRight1 = intmax*ones(rows,cols,dispLevels+2,'int32');
msgToLeft1 = intmax*ones(rows,cols,dispLevels+2,'int32');

msgToUp2 = zeros(rows,cols,dispLevels,'int32');
msgToDown2 = zeros(rows,cols,dispLevels,'int32');
msgToRight2 = zeros(rows,cols,dispLevels,'int32');
msgToLeft2 = zeros(rows,cols,dispLevels,'int32');

costs = zeros(rows,cols,3,'int32');
energy = zeros(iterations,1);
figure

% Start iterations
for it = 1:iterations

    % Compute messages - Step 1
    msgToUp1(:,:,2:end-1) = dataCost + msgFromDown + msgFromRight + msgFromLeft;
    msgToDown1(:,:,2:end-1) = dataCost + msgFromUp + msgFromRight + msgFromLeft;
    msgToRight1(:,:,2:end-1) = dataCost + msgFromUp + msgFromDown + msgFromLeft;
    msgToLeft1(:,:,2:end-1) = dataCost + msgFromUp + msgFromDown + msgFromRight;

    % Find minimum costs
    minMsgToUp = min(msgToUp1,[],3);
    minMsgToDown = min(msgToDown1,[],3);
    minMsgToRight = min(msgToRight1,[],3);
    minMsgToLeft = min(msgToLeft1,[],3);

    % Compute messages - Step 2
    for i = 1:dispLevels
        % Messages to up
        costs(:,:,1) = msgToUp1(:,:,i+1);
        costs(:,:,2) = min(msgToUp1(:,:,i),msgToUp1(:,:,i+2))+lambda;
        costs(:,:,3) = minMsgToUp+2*lambda;
        msgToUp2(:,:,i) = min(costs,[],3)-minMsgToUp;
        
        % Messages to down
        costs(:,:,1) = msgToDown1(:,:,i+1);
        costs(:,:,2) = min(msgToDown1(:,:,i),msgToDown1(:,:,i+2))+lambda;
        costs(:,:,3) = minMsgToDown+2*lambda;
        msgToDown2(:,:,i) = min(costs,[],3)-minMsgToDown;
        
        % Messages to right
        costs(:,:,1) = msgToRight1(:,:,i+1);
        costs(:,:,2) = min(msgToRight1(:,:,i),msgToRight1(:,:,i+2))+lambda;
        costs(:,:,3) = minMsgToRight+2*lambda;
        msgToRight2(:,:,i) = min(costs,[],3)-minMsgToRight;
        
        % Messages to left
        costs(:,:,1) = msgToLeft1(:,:,i+1);
        costs(:,:,2) = min(msgToLeft1(:,:,i),msgToLeft1(:,:,i+2))+lambda;
        costs(:,:,3) = minMsgToLeft+2*lambda;
        msgToLeft2(:,:,i) = min(costs,[],3)-minMsgToLeft;
    end

    % Send messages
    msgFromDown(1:end-1,:,:) = msgToUp2(2:end,:,:); %shift up
    msgFromUp(2:end,:,:) = msgToDown2(1:end-1,:,:); %shift down
    msgFromLeft(:,2:end,:) = msgToRight2(:,1:end-1,:); %shift right
    msgFromRight(:,1:end-1,:) = msgToLeft2(:,2:end,:); %shift left

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
    smoothnessEnergyHorizontal = sum(sum(lambda*min(abs(diff(dispMap,1,2)),2)));
    smoothnessEnergyVertical = sum(sum(lambda*min(abs(diff(dispMap,1,1)),2)));
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