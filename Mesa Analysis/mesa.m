%Justin Haupt
%Computer Applications
%3/4/2015

clear; close all;
load('el_data.mat')

%generates an elevation map
figure
imagesc(zgr); colormap(jet); axis image; title('Elevation Map')
xlabel('Points in x-direction'); ylabel('Points in y-direction')

%creates three matrices
wcount = zeros(size(zgr));          % for counting water movement
isLower = false(size(zgr));         % bool matrix for a buffer
nextdown = zeros([size(zgr),2]);    % double matrix for row and col indices

%sets bounds for the buffer (-2 points on the oustide edges)
buffer = [2,2];
mapMax = size(zgr) - buffer;
mapMin = [1,1] + buffer;
isLower(mapMin(1):mapMax(1),mapMin(2):mapMax(2)) = true;

%% Predicts the flowpath of water
%Completes the 'nextdown' matrices by finding where the lowest elevation
%point at every point of elevation. The first matrix is for row coordinates
%and the other is for column. 
for row = mapMin(1):mapMax(1)
    for col = mapMin(2):mapMax(2)
        i = row; j = col;
        
        group = zgr(i-1:i+1,j-1:j+1);
        
        if (min(group(:)) < group(2,2))
            isLower(i,j) = true;
            
            [i,j] = fn_nextDown(group,i,j);
            nextdown(row,col,1) = i;
            nextdown(row,col,2) = j;
        end
    end
end

%Fills in the wcount matrix by tracking the drainage patterns of the water. 
%Every time a water packet passes through a point, the point increases by 1.
for row = mapMin(1):mapMax(1)
    for col = mapMin(2):mapMax(2)
        i = row; j = col;
        while j~=0 && i ~=0 && isLower(i,j)
            idx = [nextdown(i,j,1) nextdown(i,j,2)];
            i = idx(1); j = idx(2);
            if i~=0 || j~=0
                wcount(i,j) = wcount(i,j) + 1;
            end
        end
    end
end

figure
imagesc(log(wcount)); colormap(jet); axis image; title('Drainage Area')
xlabel('Points in x-direction'); ylabel('Points in y-direction')

%% Slope and water drainage plot
%finds the slopes
[xgrad,ygrad] = gradient(zgr);
slopes = sqrt(xgrad.^2 + ygrad.^2);

%reshapes the wcount and slopes matrices into a single column vector
slopes = reshape(slopes,(size(slopes,1)*size(slopes,2)),1);
wcount = reshape(wcount,(size(wcount,1)*size(wcount,2)),1);

%plots the slope by the drainage area (positive slopes only)
wcount = log(wcount);
slopes = abs(log(slopes));  %makes all slopes positive

figure
scatter(wcount,slopes); 
title('Log of slopes vs. Log of Drainage Area')
xlabel('Drainage area (pixels)'); ylabel('Slope (m/m)')

%% Averaged slope plot
nbins = 25;                                  %number of segments
bins = 0:max(wcount)/(nbins-1):max(wcount);  %creates the segments

mslope = zeros(nbins-1,1);  %slope means matrix
midpoints = mslope;         %midpoints for the x-axis

%calculates the mean slope and midpoints within all the bin groups
for i = 1:nbins-1
    idx          = find(wcount>=bins(i) & wcount<bins(i+1));
    mslope(i)    = nanmean(slopes(idx));     %Includes NaN numbers
    midpoints(i) = (bins(i) + bins(i+1)/2);
end

figure
plot(midpoints,mslope)
title('Averaged Log of slopes vs. Log of Drainage Area')
xlabel('Drainage area (pixels)'); ylabel('Average slopes (m/m)')

%% Regime map
%the breaks are manually chosen by noticable changes in slope
breaks = [0 3 8.5 9.8 10.3 14];
regime = zeros(size(wcount));

for i = 1:length(breaks)-1
    idx2 = find(wcount>=breaks(i) & wcount<breaks(i+1));
    regime(idx2) = i;
end

regime = reshape(regime,270,257);

figure
imagesc(regime); colormap(hot); colorbar; axis image; title('Regime Map')
xlabel('Points in x-direction'); ylabel('Points in y-direction')







