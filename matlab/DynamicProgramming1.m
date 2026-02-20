dispLevels = 16;
Pocc = 10; % Occlusion penalty
Pdisc = 3; % Vertical discontinuity penalty

% Read stereo image
left = rgb2gray(imread('Left.png'));
right = rgb2gray(imread('Right.png'));

% Use gaussian filter
left = imgaussfilt(left,0.6,'FilterSize',5);
right = imgaussfilt(right,0.6,'FilterSize',5);

% Get image size
[rows,cols] = size(left);

D = Inf(cols+1,cols+1); % Minimum costs
T = zeros(cols+1,cols+1); % Transitions
dispMap = zeros(rows,cols);

% For each scanline
for y = 1:rows

    % Compute matching cost
    L = double(left(y,:)); % Left scanline
    R = double(right(y,:)); % Right scanline
    C = abs(L-R'); % Matching cost
    
    T0 = T;

    % Forward step
    D(1,1:dispLevels) = (0:dispLevels-1) * Pocc;
    T(1,2:dispLevels) = 2;
    for j = 2:cols+1
        for i = j:min(j+dispLevels-1,cols+1)
            % Compute costs
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
                T(j,i) = 1; % Match
            elseif c2 <= c3
                D(j,i) = c2;
                T(j,i) = 2; % Left occlusion
            else
                D(j,i) = c3;
                T(j,i) = 3; % Right occlusion
            end
        end
    end

    % Backtracking
    i = cols+1;
    j = cols+1;
    while i > 1
        if T(j,i) == 1
            dispMap(y,i-1) = i-j;
            i = i-1;
            j = j-1;
        elseif T(j,i) == 2
            %dispMap(y,i-1) = i-j; % disparity map without occlusion
            i = i-1;
        elseif T(j,i) == 3
            j = j-1;
        end
    end
end

% Convert disparity map to image
scaleFactor = 256/dispLevels;
dispImage = uint8(dispMap*scaleFactor);

% Show disparity image
imshow(dispImage)

% Save disparity image
imwrite(dispImage,'Disparity.png')
