% Stereo Matching using Belief Propagation (with Bipartite message update schedule)
% Computes a disparity map from a rectified stereo pair using Belief Propagation

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
mask = mod((1:rows).'+(1:cols),2) + permute(zeros(dispLevels,1),[3 2 1]);

% Start iterations
for it = 1:iterations
    for i = 0:1
        % Create messages to up
        msgFromDown2 = dataCost + msgFromDown + msgFromRight + msgFromLeft;
        msgFromDown2 = squeeze(min(msgFromDown2+smoothnessCost4d,[],3));
        msgFromDown2 = shiftUp(msgFromDown2,1,0);

        % Create messages to down
        msgFromUp2 = dataCost + msgFromUp + msgFromRight + msgFromLeft;
        msgFromUp2 = squeeze(min(msgFromUp2+smoothnessCost4d,[],3));
        msgFromUp2 = shiftDown(msgFromUp2,1,0);

        % Create messages to right
        msgFromLeft2 = dataCost + msgFromUp + msgFromDown + msgFromLeft;
        msgFromLeft2 = squeeze(min(msgFromLeft2+smoothnessCost4d,[],3));
        msgFromLeft2 = shiftRight(msgFromLeft2,1,0);

        % Create messages to left
        msgFromRight2 = dataCost + msgFromUp + msgFromDown + msgFromRight;
        msgFromRight2 = squeeze(min(msgFromRight2+smoothnessCost4d,[],3));
        msgFromRight2 = shiftLeft(msgFromRight2,1,0);

        % Send messages
        mask1 = int32(mask~=i); mask2 = int32(mask==i);
        msgFromDown = msgFromDown.*mask1 + msgFromDown2.*mask2;
        msgFromUp = msgFromUp.*mask1 + msgFromUp2.*mask2;
        msgFromLeft = msgFromLeft.*mask1 + msgFromLeft2.*mask2;
        msgFromRight = msgFromRight.*mask1 + msgFromRight2.*mask2;
    end

    % Normalize messages
    msgFromDown = msgFromDown-min(msgFromDown,[],3);
    msgFromUp = msgFromUp-min(msgFromUp,[],3);
    msgFromLeft = msgFromLeft-min(msgFromLeft,[],3);
    msgFromRight = msgFromRight-min(msgFromRight,[],3);

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
imwrite(dispImg,'disparityBP_Bipart.png')

% Stop timer and display running time
elapsedTime = toc(timerVal);
fprintf('Running time: %.2f seconds\n',elapsedTime)
