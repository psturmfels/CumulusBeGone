function [pixelMask, LabelVector] = classifier(image, X, Labels)

%Returns a mask for the image to allow extraction of superpixels that are
%clouds

%%CONSTANTS
NUM_BINS = 50;
K = 100;
NUM_TRAINDATA = 60;
FINAL_RATIO = 0.5;
NUM_TREES = 500;

%Set up pixel mask
pixelMask = zeros(size(image, 1), size(image, 2));

%Get data and labels for decision tree classifier
%[X, Labels] = meanColorHist(NUM_BINS, K, NUM_TRAINDATA);

[pixelLabels, ~, ~, Clusters] = slic(image, K);
numSuperPixels = size(Clusters, 2);

%Create a bag of decision trees
B = TreeBagger(NUM_TREES, X, Labels, 'OOBPrediction', 'On')

figure;
oobErrorBaggedEnsemble = oobError(B);
plot(oobErrorBaggedEnsemble)
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';

%Classify superpixels accordingly
TestData = [];
for i=1:numSuperPixels
    hist = colorHistVec(NUM_BINS, pixelLabels, numSuperPixels, image, i);
    TestData = [TestData; hist'];
end

PredictedLabels = predict(B, TestData);
LabelVector = cell2mat(PredictedLabels);

for i=1:numSuperPixels
    if (LabelVector(i) == 1)
        pixelMask(pixelLabels == i) = 255;
    else
        pixelMask(pixelLabels == i) = 0;
    end
end

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
        
        
        






