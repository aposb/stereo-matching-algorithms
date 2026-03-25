% Stereo Matching using Belief Propagation (with Accelerated message update schedule)
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
    %rightImgShifted = shiftArray(rightImg,[0,d]);
    rightImgShifted = circshift(rightImg,d,2); %less accurate, better performances
    dataCost(:,:,d+1) = dataCostComputation(leftImg,rightImgShifted);
end

% Compute smoothness cost
d = 0:dispLevels-1;
smoothnessCost = smoothnessCostComputation(d-d.');
smoothnessCost3d_1 = zeros(1,dispLevels,dispLevels,'int32');
smoothnessCost3d_1(1,:,:) = smoothnessCost;
smoothnessCost3d_2 = zeros(dispLevels,1,dispLevels,'int32');
smoothnessCost3d_2(:,1,:) = smoothnessCost;

% Initialize messages
msgFromUp = zeros(rows,cols,dispLevels,'int32');
msgFromDown = zeros(rows,cols,dispLevels,'int32');
msgFromRight = zeros(rows,cols,dispLevels,'int32');
msgFromLeft = zeros(rows,cols,dispLevels,'int32');

figure
energy = zeros(iterations,1);

% Start iterations
for it = 1:iterations

    % Horizontal forward pass - Send messages right
    for x = 1:cols-1
        msg = dataCost(:,x,:)+msgFromUp(:,x,:)+msgFromDown(:,x,:)+msgFromLeft(:,x,:);
        msg = min(msg+smoothnessCost3d_1,[],3);
        msgFromLeft(:,x+1,:) = msg-min(msg,[],2); %normalize message
    end
    
    % Horizontal backward pass - Send messages left
    for x = cols:-1:2
        msg = dataCost(:,x,:)+msgFromUp(:,x,:)+msgFromDown(:,x,:)+msgFromRight(:,x,:);
        msg = min(msg+smoothnessCost3d_1,[],3);
        msgFromRight(:,x-1,:) = msg-min(msg,[],2); %normalize message
    end
    
    % Vertical forward pass - Send messages down
    for y = 1:rows-1
        msg = dataCost(y,:,:)+msgFromUp(y,:,:)+msgFromRight(y,:,:)+msgFromLeft(y,:,:);
        msg = min(msg+smoothnessCost3d_2,[],3).';
        msgFromUp(y+1,:,:) = msg-min(msg,[],2); %normalize message
    end
    
    % Vertical backward pass - Send messages up
    for y = rows:-1:2
        msg = dataCost(y,:,:)+msgFromDown(y,:,:)+msgFromRight(y,:,:)+msgFromLeft(y,:,:);
        msg = min(msg+smoothnessCost3d_2,[],3).';
        msgFromDown(y-1,:,:) = msg-min(msg,[],2); %normalize message
    end
    
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
imwrite(dispImg,'disparityBP_Accel.png')

% Stop timer and display running time
elapsedTime = toc(timerVal);
fprintf('Running time: %.2f seconds\n',elapsedTime)
