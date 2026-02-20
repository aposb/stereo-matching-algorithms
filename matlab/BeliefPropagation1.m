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
smoothnessCost3d_1(1,:,:) = smoothnessCost(:,:);
smoothnessCost3d_2(:,1,:) = smoothnessCost(:,:);

% Initialize messages
msgUp = zeros(rows,cols,dispLevels);
msgDown = zeros(rows,cols,dispLevels);
msgRight = zeros(rows,cols,dispLevels);
msgLeft = zeros(rows,cols,dispLevels);

figure
energy = zeros(iterations,1);

% Start iterations
for i = 1:iterations
    
    % Horizontal forward pass - Send messages right
    for x = 1:cols-1
        msg = dataCost(:,x,:)+msgUp(:,x,:)+msgDown(:,x,:)+msgLeft(:,x,:);
        msg = min(msg+smoothnessCost3d_1,[],3);
        msgLeft(:,x+1,:) = msg-min(msg,[],2); %normalize message
    end
    
    % Horizontal backward pass - Send messages left
    for x = cols:-1:2
        msg = dataCost(:,x,:)+msgUp(:,x,:)+msgDown(:,x,:)+msgRight(:,x,:);
        msg = min(msg+smoothnessCost3d_1,[],3);
        msgRight(:,x-1,:) = msg-min(msg,[],2); %normalize message
    end
    
    % Vertical forward pass - Send messages down
    for y = 1:rows-1
        msg = dataCost(y,:,:)+msgUp(y,:,:)+msgRight(y,:,:)+msgLeft(y,:,:);
        msg = min(msg+smoothnessCost3d_2,[],3)';
        msgUp(y+1,:,:) = msg-min(msg,[],2); %normalize message
    end
    
    % Vertical backward pass - Send messages up
    for y = rows:-1:2
        msg = dataCost(y,:,:)+msgDown(y,:,:)+msgRight(y,:,:)+msgLeft(y,:,:);
        msg = min(msg+smoothnessCost3d_2,[],3)';
        msgDown(y-1,:,:) = msg-min(msg,[],2); %normalize message
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
