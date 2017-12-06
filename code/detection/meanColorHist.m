function [X, Labels] = meanColorHist(b, k, numTrainData)
%meanColorHist
%
%This will calculate the mean color histogram of all cloud superpixels in
%the training data, and then use some form of similarity comparison to
%determine which superpixels in test images are clouds and which are not.

%default 10 bins for each channel of the color histogram
if ~exist('b','var') || isempty(b)
    b = 256;
end

%%CONSTANTS
cloudThreshold = 0.8;

%primary training data directory
imageDir = '../../data/swimseg/images/';
GTDir = '../../data/swimseg/GTmaps/';

%%Go through every image in training data up to 0300.png
numImage = 1;
%Holds color histogram data
X = [];
%Holds labels for classification
Labels = [];


while (numImage < numTrainData)
    if (floor(numImage / 10) == 0)
        imName = strcat('000', int2str(numImage));
    elseif (floor(numImage / 10) >= 1 && floor(numImage / 10) < 10)
        imName = strcat('00', int2str(numImage));
    else
        imName = strcat('0', int2str(numImage));
    end
    
    imageName = strcat(imName, '.png');
    if (mod(numImage, 50) == 0)
        fprintf('Trained on images up to %s\n', imageName);
    end
    GTName = strcat(imName, '_GT.png');
    im = im2double(imread(strcat(imageDir, imageName)));
    imGT = im2double(imread(strcat(GTDir, GTName)));
    
    X = [X; (colorHistVec(b, imGT, im, 1))'];
    Labels = [Labels; 1];
    
    X = [X; (colorHistVec(b, imGT, im, 0))'];
    Labels = [Labels; 0];
    
    %{
    %Call slic for each RGB image
    [pixelLabels, ~, ~, Clusters] = slic(im, k);
    numSuperPixels = size(Clusters, 2);
    
    for i=1:numSuperPixels
        pixelValues = imGT(pixelLabels == i);
        if ((nnz(pixelValues) / size(pixelValues,1)) > cloudThreshold) %if cloud
            X = [X; (colorHistVec(b, pixelLabels, numSuperPixels, im, i))'];
            Labels = [Labels; 1];
        else
            X = [X; (colorHistVec(b, pixelLabels, numSuperPixels, im, i))'];
            Labels = [Labels; 0];
        end
    end
    %}
   
    numImage = numImage + 1;
end
    