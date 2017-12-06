function ReplaceClouds(im)
    addpath('segmentation/');
    addpath('replacement/');
    addpath('detection/');

    [pixelLabels, ~, ~, Clusters] = slic(im, 400, 0.01, 0.05, 0.1, 3);
    bw = boundarymask(pixelLabels);
    [skyCloudPixelMask, pixelMask] = simpleClassifier(im, averageCloudHistVec, averageSkyHistVec, pixelLabels, Clusters);
    replacedImage = inpaint(im, pixelMask, skyCloudPixelMask);

    subplot(2,2,1);
    imshow(im);
    subplot(2,2,2);
    imshow(imoverlay(im, bw, 'cyan'));
    subplot(2,2,3);
    imshow(imoverlay(pixelMask, bw, 'cyan'));
    subplot(2,2,4);
    imshow(replacedImage);
end
