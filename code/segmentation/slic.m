function [pixelLabels, pixelClusterDistances, Am, Clusters] = slic(im, k, l_weight, a_weight, b_weight, seRadius, nItr)
    %% Read in image, set default variables
    if ~exist('nItr','var') || isempty(nItr)
        nItr = 10;  
    end
    if ~exist('k','var') || isempty(k)
        k = 100;  
    end
    if ~exist('l_weight','var') || isempty(l_weight)
        l_weight = 0.01;  
    end
    if ~exist('a_weight','var') || isempty(a_weight)
        a_weight = 0.05;  
    end
    if ~exist('b_weight','var') || isempty(b_weight)
        b_weight = 0.2;  
    end
    if ~exist('seRadius','var') || isempty(seRadius)
        seRadius = 10;  
    end
    
    [rows, cols, chan] = size(im);
    if chan ~= 3
        error('Image must be colour');
    end
    
    %% Convert image to LAB-color space; apparently it is better for color-based clustering
    im = rgb2lab(im); 

    %% Set up initial cluster spacing parameters
    % Note: clusters initialize in a square grid regardless of image
    % size because I am too lazy to factor k 
    rootImageLength = sqrt(rows * cols);
    S = rootImageLength / sqrt(k);
    
    numberNodesSide = round((rootImageLength - 0.5 * S) / S);
    columnSpacing = floor(cols / (numberNodesSide + 0.5));
    rowSpacing = floor(rows / (numberNodesSide + 0.5));
    
    numberNodeColumns = ceil((cols - columnSpacing * 0.5) / columnSpacing);
    numberNodeRows = ceil((rows - rowSpacing * 0.5) / rowSpacing);
    
    k = numberNodeRows * numberNodeColumns;
    S = round(S);
    
    %% Initialize Clusters
    Clusters = zeros(6, k); %[L, A, B, columnPos, rowPos, numberOfPixelsInCluster]
    pixelLabels = -ones(rows, cols);
    pixelClusterDistances = inf(rows, cols);
    clusterCount = 1; 
    for rowIndex = 1:numberNodeRows
        for columnIndex = 1:numberNodeColumns
            clusterRow = round(rowSpacing * (rowIndex - 0.5));
            clusterCol = round(columnSpacing * (columnIndex - 0.5));
            Clusters(1:6, clusterCount) = [squeeze(im(clusterRow, clusterCol, :)); clusterCol; clusterRow; 1];
            clusterCount = clusterCount + 1;
        end
    end
    S = round(S);
    
    %% Run Clustering
    for n = 1:nItr
        for clusterIndex = 1:k
            %% Update pixels in current cluster window
            pixelRowMin = max(Clusters(5, clusterIndex) - S, 1);
            pixelRowMax = min(Clusters(5, clusterIndex) + S, rows);
            
            pixelColMin = max(Clusters(4, clusterIndex) - S, 1);
            pixelColMax = min(Clusters(4, clusterIndex) + S, cols);
            
            pixelWindow = im(pixelRowMin:pixelRowMax, pixelColMin:pixelColMax, :);
            pixelClusterDistWindow = dist(Clusters(:, clusterIndex), pixelWindow, pixelRowMin, pixelColMin, S, l_weight, a_weight, b_weight);
            
            windowClippedDistances =  pixelClusterDistances(pixelRowMin:pixelRowMax, pixelColMin:pixelColMax);
            windowClippedLabels = pixelLabels(pixelRowMin:pixelRowMax, pixelColMin:pixelColMax);
            updateMask = pixelClusterDistWindow < windowClippedDistances;
            windowClippedDistances(updateMask) = pixelClusterDistWindow(updateMask);
            windowClippedLabels(updateMask) = clusterIndex;
           
            pixelClusterDistances(pixelRowMin:pixelRowMax, pixelColMin:pixelColMax) = windowClippedDistances;
            pixelLabels(pixelRowMin:pixelRowMax, pixelColMin:pixelColMax) = windowClippedLabels; 
        end
        
       %% Update clusters based on new values
       Clusters(:) = 0;
       for r = 1:rows
           for c = 1:cols
              Clusters(:, pixelLabels(r,c)) = Clusters(:, pixelLabels(r,c)) + [im(r,c,1); im(r,c,2); im(r,c,3); c; r; 1];
           end
       end
       for clusterIndex = 1:k 
           Clusters(1:5, clusterIndex) = round(Clusters(1:5, clusterIndex) / Clusters(6, clusterIndex)); 
       end
    end
    
    %% Clean up orphaned clusters. I did not write the function below.
    [pixelLabels, Am] = mcleanupregions(pixelLabels, seRadius);
end