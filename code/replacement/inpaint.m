function im = inpaint(im, pixelMask)
    im = im2double(im);
    pixelMask = im2double(pixelMask);
    [numberRows, numberCols, numberChannels] = size(im);

    boundaryMask = boundarymask(pixelMask);
    [boundaryRows, boundaryCols] = find(boundaryMask);
    boundaryIndices = [boundaryRows'; boundaryCols'];
    numberOfBoundaryPoints = size(boundaryIndices, 2);
    boundaryIndices = cat(2, boundaryIndices, zeros(2, numberRows * numberCols));
    boundaryDistance = bwdist(boundaryMask);
    boundaryDistance = boundaryDistance / max(boundaryDistance(:));
    
    %Initialize indicator constants
    KNOWN = 0;
    BAND = 1;
    INSIDE = 2;

    %Initialize flags
    F = zeros(size(pixelMask));
    F(boundaryMask) = BAND;
    F(pixelMask & ~boundaryMask) = INSIDE;

    index = 0;
    numberOfExpandIterations = 75;
    pointsAddedDuringExpansion = 0;
    pointIndex = 0;
    while index < numberOfExpandIterations
        index = index + 1;
        stoppingPoint = numberOfBoundaryPoints;
        while pointIndex < stoppingPoint
            pointIndex = pointIndex + 1;
            point = boundaryIndices(:, pointIndex);
            row = point(1);
            col = point(2);
            neighbors = [];
            if row - 1 > 0
                neighbors = [row - 1, col; neighbors];
            end
            if row + 1 < numberRows
                neighbors = [row + 1, col; neighbors];
            end
            if col - 1 > 0
                neighbors = [row, col - 1; neighbors];
            end
            if col + 1 < numberCols
                neighbors = [row, col + 1; neighbors];
            end
            for neighborIndex = neighbors'            
                neighborRow = neighborIndex(1);
                neighborCol = neighborIndex(2);
                if (F(neighborRow, neighborCol) == KNOWN)
                    F(neighborRow, neighborCol) = BAND;
                    numberOfBoundaryPoints = numberOfBoundaryPoints + 1;
                    pointsAddedDuringExpansion = pointsAddedDuringExpansion + 1;
                    boundaryIndices(:, numberOfBoundaryPoints) = [neighborRow; neighborCol];
                end
            end
        end
    end
    boundaryIndices = boundaryIndices(:, 1:numberOfBoundaryPoints);
    boundaryIndices = flip(boundaryIndices, 2);
    numberMissingPoints = sum(pixelMask(:)) - sum(boundaryMask(:)) + size(boundaryIndices, 2);
    fprintf('Number of missing points: %f\n', numberMissingPoints);
    boundaryIndices = cat(2, boundaryIndices, zeros(2, numberRows * numberCols)); 
    
    index = 0;
    while index < numberOfBoundaryPoints
        index = index + 1;
        if (mod(index, 5000) == 0)
            fprintf('Number of points filled in: %i\n', index);
        end

        pointIndex = boundaryIndices(:, index);
        row = pointIndex(1);
        col = pointIndex(2);
        
        F(row, col) = KNOWN;
        
        neighbors = [];
        if row - 1 > 0
            neighbors = [row - 1, col; neighbors];
        end
        if row + 1 < numberRows
            neighbors = [row + 1, col; neighbors];
        end
        if col - 1 > 0
            neighbors = [row, col - 1; neighbors];
        end
        if col + 1 < numberCols
            neighbors = [row, col + 1; neighbors];
        end
        
        %Iterate through the neighbors of the boundary pixel
        for neighborIndex = neighbors'            
            neighborRow = neighborIndex(1);
            neighborCol = neighborIndex(2);
            if (F(neighborRow, neighborCol) ~= KNOWN)
                for colorChannel = 1:numberChannels
                    %Do random texture sampling
                    
                    if (index < pointsAddedDuringExpansion) 
                        im(neighborRow, neighborCol, colorChannel) = (1 - index / pointsAddedDuringExpansion) * inpaintPixel(im, F, boundaryDistance, neighborRow, neighborCol, colorChannel) + (index / pointsAddedDuringExpansion) * im(neighborRow, neighborCol, colorChannel);
                    else 
                        if (neighborRow > 1 && neighborRow < numberRows && neighborCol > 1 && neighborCol < numberCols)
                            randWindowHalfSize = 100;
                            randRowChoices = max(2, neighborRow - randWindowHalfSize):min(numberRows-2, neighborRow + randWindowHalfSize);
                            randColChoices = max(2, neighborCol - randWindowHalfSize):min(numberCols-2, neighborCol + randWindowHalfSize);
                            selectedRow = datasample(randRowChoices, 1);
                            selectedCol = datasample(randColChoices, 1);
                            if (F(selectedRow, selectedCol) == KNOWN)
                                im((neighborRow-1):(neighborRow+1), (neighborCol-1):(neighborCol+1), colorChannel) = 0.8*im((neighborRow-1):(neighborRow+1), (neighborCol-1):(neighborCol+1), colorChannel) + 0.2 * im((selectedRow-1):(selectedRow+1), (selectedCol-1):(selectedCol+1), colorChannel);
                            end
                        end
                        im(neighborRow, neighborCol, colorChannel) = inpaintPixel(im, F, boundaryDistance, neighborRow, neighborCol, colorChannel);
                    end
                end
                if (F(neighborRow, neighborCol) == INSIDE)
                    numberOfBoundaryPoints = numberOfBoundaryPoints + 1;
                    boundaryIndices(:, numberOfBoundaryPoints) = [neighborRow; neighborCol];
                    F(neighborRow, neighborCol) = BAND;
                end
            end
        end
    end
end

function newPixelValue = inpaintPixel(im, F, boundaryDistance, row, col, colorChannel)
    [numberRows, numberCols, ~] = size(im);
    runningVariance = 0;
    runningMean = 0;
    n = 0;
    KNOWN = 0;
    BAND = 1;
    INSIDE = 2;
    windowHalfSize = 5;
    Ia = 0;
    s = 0;
    for neighborRow = max(2, row - windowHalfSize):min(numberRows-2, row + windowHalfSize)
        for neighborCol = max(2, col - windowHalfSize):min(numberCols-2, col + windowHalfSize)
            if F(neighborRow, neighborCol) == KNOWN
                n = n + 1;
                rowDist = row - neighborRow;
                colDist = col - neighborCol;
                distLength = sqrt(rowDist^2 + colDist^2);
                
                w = 1 / (distLength^2 + 100*boundaryDistance(neighborRow, neighborCol));
                
                pixel = im(neighborRow, neighborCol, colorChannel);
                Ia = Ia + w * pixel;
                s = s + w;
                prevRunningMean = runningMean;
                runningMean = runningMean + (pixel - runningMean) / n;
                runningVariance = ((n - 1) * runningVariance + (pixel - runningMean) * (pixel - prevRunningMean))/n;
            end
        end
    end
    if (Ia == 0)
        newPixelValue = im(row, col, colorChannel);
    else
        newPixelValue = Ia / s + randn(1) * sqrt(runningVariance) * 0.25;
    end
end