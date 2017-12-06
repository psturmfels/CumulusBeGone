function [pixelMask, LabelVector] = classifier(image, B, pixelLabels, Clusters)
addpath('../segmentation/');
%Returns a mask for the image to allow extraction of superpixels that are
%clouds

%%CONSTANTS
NUM_BINS = 50;
NUM_TRAINDATA = 300;
FINAL_RATIO = 0.5;

%Set up pixel mask
pixelMask = zeros(size(image, 1), size(image, 2));

numSuperPixels = size(Clusters, 2);

%Classify superpixels accordingly
TestData = [];
for i=1:numSuperPixels
    hist = colorHistVec(NUM_BINS, pixelLabels, numSuperPixels, image, i);
    TestData = [TestData; hist'];
end

PredictedLabels = predict(B, TestData);
LabelVector = cell2mat(PredictedLabels);
disp(PredictedLabels);
disp(LabelVector);

for i=1:numSuperPixels
    if (LabelVector(i) == '1')
        pixelMask(pixelLabels == i) = 255;
    else
        pixelMask(pixelLabels == i) = 0;
    end
end

pixelMask = im2double(pixelMask);

%imshow(pixelMask);


%{
for i=1:numSuperPixels
    i
    hist = colorHistVec(NUM_BINS, pixelLabels, numSuperPixels, image, i);
    distanceCloud = histogramIntersection(hist, meanCloudHist);
    distanceSky = histogramIntersection(hist, meanSkyHist);

    if (abs(distanceCloud) < 1500) %if superpixel is a cloud
        pixelMask(pixelLabels == i) = 1;
    else
        pixelMask(pixelLabels == i) = 0;
    end
end

imshow(pixelMask);
%}
