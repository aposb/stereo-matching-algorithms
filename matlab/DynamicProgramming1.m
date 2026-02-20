% Stereo Matching using Dynamic Programming (with Left-Right Axes DSI)
% Computes a disparity map from a rectified stereo pair using Dynamic Programming

% Set parameters
dispLevels = 16;% disparity range: 0 to dispLevels-1
Pocc = 5; %occlusion penalty
Pdisc = 1; %vertical discontinuity penalty

% Define data cost computation
dataCostComputation = @(differences) abs(differences); %absolute differences
%dataCostComputation = @(differences) differences.^2; %square differences

% Predefined smoothness cost computation: Pocc*abs(differences)

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

D = intmax*ones(cols+1,cols+1,'int32'); %minimum costs
T = zeros(cols+1,cols+1,'int32'); %transitions
dispMap = zeros(rows,cols);

% For each scanline
for y = 1:rows

    % Compute matching cost
    L = leftImg(y,:); %left scanline
    R = rightImg(y,:); %right scanline
    C = dataCostComputation(L-R.'); %matching cost

    % Keep previous transitions
    T0 = T;

    % Compute DP table (forward pass)
    D(1,1:dispLevels) = (0:dispLevels-1)*Pocc;
    T(1,2:dispLevels) = 2;
    for j = 2:cols+1
        for i = j:min(j+dispLevels-1,cols+1)
            % Compute cost for match and costs for occlusions
            c1 = D(j-1,i-1) + C(j-1,i-1);
            c2 = D(j,i-1) + Pocc;
            c3 = D(j-1,i) + Pocc;

            % Add discontinuity cost
            if T0(j,i) == 1
                c2 = c2 + Pdisc;
                c3 = c3 + Pdisc;
            elseif T0(j,i) == 2
                c1 = c1 + Pdisc;
                c3 = c3 + Pdisc;
            elseif T0(j,i) == 3
                c1 = c1 + Pdisc;
                c2 = c2 + Pdisc;
            end

            % Find minimum cost
            if c1 <= c2 && c1 <= c3
                D(j,i) = c1;
                T(j,i) = 1; %match
            elseif c2 <= c3
                D(j,i) = c2;
                T(j,i) = 2; %left occlusion
            else
                D(j,i) = c3;
                T(j,i) = 3; %right occlusion
            end
        end
    end

    % Compute disparity map (backtracking)
    i = cols+1;
    j = cols+1;
    while i > 1
        if T(j,i) == 1
            dispMap(y,i-1) = i-j;
            i = i-1;
            j = j-1;
        elseif T(j,i) == 2
            dispMap(y,i-1) = i-j; %comment this line for occlusion handling
            i = i-1;
        elseif T(j,i) == 3
            j = j-1;
        end
    end
end

% Normalize the disparity map for display
scaleFactor = 256/dispLevels;
dispImg = uint8(dispMap*scaleFactor);

% Show disparity map
figure; imshow(dispImg)

% Save disparity map
imwrite(dispImg,'disparity.png')