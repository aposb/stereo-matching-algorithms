dispLevels = 16;
windowSize = 5;

% Read the stereo images as grayscale
leftImg = rgb2gray(imread('left.png'));
rightImg = rgb2gray(imread('right.png'));

% Apply a Gaussian filter
leftImg = imgaussfilt(leftImg,0.6,'FilterSize',5);
rightImg = imgaussfilt(rightImg,0.6,'FilterSize',5);

% Get image size
[rows,cols] = size(leftImg);

% Convert from uint8 to double
leftImg = double(leftImg);
rightImg = double(rightImg);

% Compute initial matching cost
rightImgShifted = zeros(rows,cols,dispLevels);
for d = 0:dispLevels-1
	rightImgShifted(:,d+1:end,d+1) = rightImg(:,1:end-d);
end
C0 = abs(leftImg-rightImgShifted);

% Compute aggregated matching cost
C1 = imboxfilt3(C0,[windowSize windowSize 1]);

% Create disparity map
[~,ind] = min(C1,[],3);
dispMap = ind-1;

% Create disparity image
scaleFactor = 256/dispLevels;
dispImage = uint8(dispMap*scaleFactor);

% Show disparity image
figure; imshow(dispImage)

% Save disparity image
imwrite(dispImage,'disparity.png')