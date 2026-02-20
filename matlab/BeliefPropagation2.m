dispLevels = 16;
iterations = 60;
lambda = 5;
threshold = 2;

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

% Compute smoothness cost
d = 0:dispLevels-1;
smoothnessCost = lambda*min(abs(d-d'),threshold);
smoothnessCost4d(1,1,:,:) = smoothnessCost;

% Initialize messages
msgFromUp = zeros(rows,cols,dispLevels);
msgFromDown = zeros(rows,cols,dispLevels);
msgFromRight = zeros(rows,cols,dispLevels);
msgFromLeft = zeros(rows,cols,dispLevels);

figure
energy = zeros(iterations,1);

% Start iterations
for i = 1:iterations
    % Create messages to up
    msgToUp = dataCost + msgFromDown + msgFromRight + msgFromLeft;
    msgToUp = permute(min(msgToUp+smoothnessCost4d,[],3),[1,2,4,3]);
    msgToUp = msgToUp-min(msgToUp,[],3); % normalize
    
    % Create messages to down
    msgToDown = dataCost + msgFromUp + msgFromRight + msgFromLeft;
    msgToDown = permute(min(msgToDown+smoothnessCost4d,[],3),[1,2,4,3]);
    msgToDown = msgToDown-min(msgToDown,[],3); % normalize
    
    % Create messages to right
    msgToRight = dataCost + msgFromUp + msgFromDown + msgFromLeft;
    msgToRight = permute(min(msgToRight+smoothnessCost4d,[],3),[1,2,4,3]);
    msgToRight = msgToRight-min(msgToRight,[],3); % normalize
    
    % Create messages to left
    msgToLeft = dataCost + msgFromUp + msgFromDown + msgFromRight;
    msgToLeft = permute(min(msgToLeft+smoothnessCost4d,[],3),[1,2,4,3]);
    msgToLeft = msgToLeft-min(msgToLeft,[],3); % normalize

    % Send messages
    msgFromDown = [msgToUp(2:end,:,:);zeros(1,cols,dispLevels)]; %shift up
    msgFromUp = [zeros(1,cols,dispLevels);msgToDown(1:end-1,:,:)]; %shift down
    msgFromLeft = [zeros(rows,1,dispLevels),msgToRight(:,1:end-1,:)]; %shift right
    msgFromRight = [msgToLeft(:,2:end,:),zeros(rows,1,dispLevels)]; %shift left

    % Compute belief
    belief = dataCost + msgFromUp + msgFromDown + msgFromRight + msgFromLeft;
    
    % Update disparity map
    [~,ind] = min(belief,[],3);
    disparityMap = ind-1;
    
    % Compute energy
    [row,col] = ndgrid(1:size(ind,1),1:size(ind,2));
    linInd = sub2ind(size(dataCost),row,col,ind);
    dataEnergy = sum(sum(dataCost(linInd)));
    row = [reshape(ind(:,1:end-1),[],1);reshape(ind(1:end-1,:),[],1)];
    col = [reshape(ind(:,2:end),[],1);reshape(ind(2:end,:),[],1)];
    linInd = sub2ind(size(smoothnessCost),row,col);
    smoothnessEnergy = sum(smoothnessCost(linInd));
    energy(i) = dataEnergy+smoothnessEnergy;
    
    % Update disparity image
    scaleFactor = 256/dispLevels;
    disparityImg = uint8(disparityMap*scaleFactor);
    
    % Show disparity image
    imshow(disparityImg)
    
    % Show current energy and iteration
    fprintf('iteration: %d/%d, energy: %d\n',i,iterations,energy(i))
end

% Show convergence graph
figure
plot(1:iterations,energy,'bo-')
xlabel('Iterations')
ylabel('Energy')

% Save disparity image
imwrite(disparityImg,'disparity.png')