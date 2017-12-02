testImages = {'0186.png', '0236.png', '0845.png', '0234.png'};
testNames   = {'smallBWeight', 'moderateBWeight', 'largerBWeight', 'hugeBWeight', 'largeRefactorRadius', 'nonZeroLWeight', 'smallK', 'largeK'};
k           = [100, 100, 100, 100, 100, 100, 50, 200];
l_weights   = [0, 0, 0, 0, 0, 0.1, 0, 0];
a_weight    = 0.01;
b_weights   = [0.05, 0.1, 0.2, 0.4, 0.1, 0.1, 0.1, 0.1];
seRadius    = [5, 5, 5, 5, 10, 5, 5, 5];

for i = 1:10
    fprintf('===============Experiment %i: %s==============\n', i, char(testNames(i)));
    imageArray = [];
    pixelLabelsArray = [];
    for j = 1:4
        fprintf('[%i]', j);
        [im, pixelLabels, pixelClusterDistances, Am] = segmentImage(char(testImages(j)), k(i), l_weights(i), a_weight, b_weights(i), seRadius(i));
        imageArray = cat(4, imageArray, im);
        pixelLabelsArray = cat(3, pixelLabelsArray, pixelLabels);
    end
    fprintf('\n');
    displaySegmentations(imageArray, pixelLabelsArray, 2, 2, char(testNames(i)));
end

function  [im, pixelLabels, pixelClusterDistances, Am] = segmentImage(imageName, k, l_weight, a_weight, b_weight, seRadius, imageDir)
    %% Set Default Image Directory
    if ~exist('imageDir','var') || isempty(imageDir)
        imageDir = '../../data/swimseg/images/';  
    end
    im = imread(strcat(imageDir, imageName));
    [pixelLabels, pixelClusterDistances, Am] = slic(im, k, l_weight, a_weight, b_weight, seRadius);
end

function displaySegmentations(imageArray, pixelLabelsArray, plotRows, plotCols, title)
    figure;
    for i = 1:plotRows*plotCols
        im = imageArray(:,:,:,i);
        pixelLabels = pixelLabelsArray(:,:,i);
        subplot(plotRows, plotCols, i);
        BW = boundarymask(pixelLabels);
        imshow(imoverlay(im, BW, 'cyan'));
    end
    %suptitle(title);
end