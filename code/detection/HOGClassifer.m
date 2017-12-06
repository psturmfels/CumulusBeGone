%HOGClassifier
%
%This classifer will be trained using an SVM. The data will be HOG features
%extracted from the center points of each superpixel, determined by SLIC.
%But we first have to structure the training data to allow training. This
%requires each superpixel to be given a binary classification (assume each
%superpixel is either a cloud or not, not both).
%
% Supporting Functions
%
%   [pixelLabels, pixelClusterDistances, spCenters, Am] = slic(im, k, l_weight,
%   a_weight, b_weight, seRadius)
%
%   X = extractTrainData(im, spCenters) 