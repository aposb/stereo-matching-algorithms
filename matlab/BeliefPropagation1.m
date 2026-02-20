dispLevels = 16;
iterations = 30;
lambda = 8;
threshold = 2;

% Read the stereo images as grayscale
leftImg = rgb2gray(imread('left.png'));
rightImg = rgb2gray(imread('right.png'));

% Apply a Gaussian filter
leftImg = imgaussfilt(leftImg,1,'FilterSize',5);
rightImg = imgaussfilt(rightImg,1,'FilterSize',5);

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

% Initialize messages
msgUp = zeros(rows,cols,dispLevels);
msgDown = zeros(rows,cols,dispLevels);
msgRight = zeros(rows,cols,dispLevels);
msgLeft = zeros(rows,cols,dispLevels);

figure
energy = zeros(iterations,1);

% Start iterations
for i = 1:iterations
    
    % Horizontal forward pass
    for y = 1:rows
        for x = 1:cols-1
            % Send message right
            msg = squeeze(dataCost(y,x,:)+msgUp(y,x,:)+msgDown(y,x,:)+msgLeft(y,x,:));
            msg = min(msg+smoothnessCost);
            msg = msg-min(msg); %normalize message
            msgLeft(y,x+1,:) = msg;
        end
    end
    
    % Horizontal backward pass
    for y = 1:rows
        for x = cols:-1:2
            % Send message left
            msg = squeeze(dataCost(y,x,:)+msgUp(y,x,:)+msgDown(y,x,:)+msgRight(y,x,:));
            msg = min(msg+smoothnessCost);
            msg = msg-min(msg); %normalize message
            msgRight(y,x-1,:) = msg;
        end
    end
    
    % Vertical forward pass
    for x = 1:cols
        for y = 1:rows-1
            % Send message down
            msg = squeeze(dataCost(y,x,:)+msgUp(y,x,:)+msgRight(y,x,:)+msgLeft(y,x,:));
            msg = min(msg+smoothnessCost);
            msg = msg-min(msg); %normalize message
            msgUp(y+1,x,:) = msg;
        end
    end
    
    % Vertical backward pass
    for x = 1:cols
        for y = rows:-1:2
            % Send message up
            msg = squeeze(dataCost(y,x,:)+msgDown(y,x,:)+msgRight(y,x,:)+msgLeft(y,x,:));
            msg = min(msg+smoothnessCost);
            msg = msg-min(msg); %normalize message
            msgDown(y-1,x,:) = msg;
        end
    end
    
    % Compute belief
    belief = dataCost + msgUp + msgDown + msgRight + msgLeft;
    
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
    
    % Show energy and iteration
    fprintf('iteration: %d/%d, energy: %d\n',i,iterations,energy(i))
end

% Show convergence graph
figure
plot(1:iterations,energy,'bo-')
xlabel('Iterations')
ylabel('Energy')

% Save disparity image
imwrite(disparityImg,'disparity.png')