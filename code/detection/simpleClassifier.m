function [pixelMask] = simpleClassifier(im, averageCloudHistVec, averageSkyHistVec, pixelLabels, Clusters)
SKY = 2;
CLOUDS = 1;
UNKNOWN = 0;
cloudThreshold = 0.5;
skyThreshold = 10;
% RBCloudThreshold = 60/255;
RBDifferenceMap = abs(im(:,:,1) - im(:,:,3));
BChannelMap = im(:,:,3);
pixelMask = zeros(size(im, 1), size(im, 2));

numSuperPixels = size(Clusters, 2);

LABImage = rgb2lab(im2double(im));
aChannel = LABImage(:,:,2);
bChannel = LABImage(:,:,3);

for i=1:numSuperPixels
    hist = colorHistVec(pixelLabels, LABImage, i);
    skyIntersection = histogramIntersection(hist, averageSkyHistVec) / 2;
    cloudIntersection = histogramIntersection(hist, averageCloudHistVec) / 2;
    
    currentRBDiff = RBDifferenceMap(pixelLabels == i);
    currentB = BChannelMap(pixelLabels == i);
    meanBValue = mean(currentB(:));
    meanRBValue = mean(currentRBDiff(:));
    
    currentLABb = bChannel(pixelLabels == i);
    meanLABbValue = -mean(currentLABb(:));
    
    currentAChannel = aChannel(pixelLabels == i);
    currentBChannel = bChannel(pixelLabels == i);
    meanAChannelValue = mean(currentAChannel(:));
    meanBChannelValue = mean(currentBChannel(:));
    meanDifferenceFromCenter = meanAChannelValue^2 + meanBChannelValue^2;
    
    LABDistScore = 1.01^(-meanDifferenceFromCenter);
    RBDiffScore = exp(-meanRBValue);
    cloudScore = LABDistScore * RBDiffScore;
    skyScore = meanLABbValue;
%       fprintf('cloudScore: %f, skyScore: %f\n', cloudScore, skyScore);
%      fprintf('LABDist: %f, RBDiff: %f, cloudIntersection: %f, skyIntersection: %f', LABDistScore, RBDiffScore, cloudIntersection, skyIntersection);
    if cloudScore > cloudThreshold
        pixelMask(pixelLabels == i) = CLOUDS;
    elseif skyScore > skyThreshold
        pixelMask(pixelLabels == i) = SKY;
    end
  
end

