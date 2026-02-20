dispLevels = 16;
iterations = 60;
lambda = 5; %smoothnesCost = min(abs(d1-d2),2)*lambda

% Read the stereo images as grayscale
leftImg = rgb2gray(imread('left.png'));
rightImg = rgb2gray(imread('right.png'));

% Apply a Gaussian filter
leftImg = imgaussfilt(leftImg,0.6,'FilterSize',5);
rightImg = imgaussfilt(rightImg,0.6,'FilterSize',5);

% Get the image size
[rows,cols] = size(leftImg);

% Compute data cost
dataCost = zeros(rows,cols,dispLevels);
leftImg = double(leftImg);
rightImg = double(rightImg);
for d = 0:dispLevels-1
    rightImgShifted = [zeros(rows,d),rightImg(:,1:end-d)];
    dataCost(:,:,d+1) = abs(leftImg-rightImgShifted);
end

% Initialize messages
msgFromUp = zeros(rows,cols,dispLevels);
msgFromDown = zeros(rows,cols,dispLevels);
msgFromRight = zeros(rows,cols,dispLevels);
msgFromLeft = zeros(rows,cols,dispLevels);

msgToUp = Inf(rows,cols,dispLevels+2);
msgToDown = Inf(rows,cols,dispLevels+2);
msgToRight = Inf(rows,cols,dispLevels+2);
msgToLeft = Inf(rows,cols,dispLevels+2);

energy = zeros(iterations,1);
figure

% Start iterations
for iter = 1:iterations
    % Update messages
    msgToUp(:,:,2:end-1) = dataCost + msgFromDown + msgFromRight + msgFromLeft;
    msgToDown(:,:,2:end-1) = dataCost + msgFromUp + msgFromRight + msgFromLeft;
    msgToRight(:,:,2:end-1) = dataCost + msgFromUp + msgFromDown + msgFromLeft;
    msgToLeft(:,:,2:end-1) = dataCost + msgFromUp + msgFromDown + msgFromRight;
    
    minMsgToUp = min(msgToUp,[],3);
    minMsgToDown = min(msgToDown,[],3);
    minMsgToRight = min(msgToRight,[],3);
    minMsgToLeft = min(msgToLeft,[],3);
    
    for i = 1:dispLevels
        % Create messages to up
        costs(:,:,1) = msgToUp(:,:,i+1);
        costs(:,:,2) = min(msgToUp(:,:,i),msgToUp(:,:,i+2))+lambda;
        costs(:,:,3) = minMsgToUp+2*lambda;
        msgFromDown(:,:,i) = min(costs,[],3)-minMsgToUp;
        
        % Create messages to down
        costs(:,:,1) = msgToDown(:,:,i+1);
        costs(:,:,2) = min(msgToDown(:,:,i),msgToDown(:,:,i+2))+lambda;
        costs(:,:,3) = minMsgToDown+2*lambda;
        msgFromUp(:,:,i) = min(costs,[],3)-minMsgToDown;
        
        % Create messages to right
        costs(:,:,1) = msgToRight(:,:,i+1);
        costs(:,:,2) = min(msgToRight(:,:,i),msgToRight(:,:,i+2))+lambda;
        costs(:,:,3) = minMsgToRight+2*lambda;
        msgFromLeft(:,:,i) = min(costs,[],3)-minMsgToRight;
        
        % Create messages to left
        costs(:,:,1) = msgToLeft(:,:,i+1);
        costs(:,:,2) = min(msgToLeft(:,:,i),msgToLeft(:,:,i+2))+lambda;
        costs(:,:,3) = minMsgToLeft+2*lambda;
        msgFromRight(:,:,i) = min(costs,[],3)-minMsgToLeft;
    end

    msgFromDown = [msgFromDown(2:end,:,:);zeros(1,cols,dispLevels)]; %shift up
    msgFromUp = [zeros(1,cols,dispLevels);msgFromUp(1:end-1,:,:)]; %shift down
    msgFromLeft = [zeros(rows,1,dispLevels),msgFromLeft(:,1:end-1,:)]; %shift right
    msgFromRight = [msgFromRight(:,2:end,:),zeros(rows,1,dispLevels)]; %shift left

    % Compute belief
    belief = dataCost + msgFromUp + msgFromDown + msgFromRight + msgFromLeft;
    
    % Update disparity map
    [~,ind] = min(belief,[],3);
    disparityMap = ind-1;
    
    % Compute energy
    [row,col] = ndgrid(1:size(ind,1),1:size(ind,2));
    linInd = sub2ind(size(dataCost),row,col,ind);
    dataEnergy = sum(sum(dataCost(linInd)));
    smoothnessEnergyHorizontal = sum(sum(min(abs(ind(:,1:end-1)-ind(:,2:end)),2)*lambda));
    smoothnessEnergyVertical = sum(sum(min(abs(ind(1:end-1,:)-ind(2:end,:)),2)*lambda));
    energy(iter) = dataEnergy+smoothnessEnergyHorizontal+smoothnessEnergyVertical;

    % Update disparity image
    scaleFactor = 256/dispLevels;
    disparityImg = uint8(disparityMap*scaleFactor);
    
    % Show disparity image
    imshow(disparityImg)
    
    % Show energy and iteration
    fprintf('iteration: %d/%d, energy: %d\n',iter,iterations,energy(iter))
end

% Show convergence graph
figure
plot(1:iterations,energy,'bo-')
xlabel('Iterations')
ylabel('Energy')

% Save disparity image
imwrite(disparityImg,'disparity.png')