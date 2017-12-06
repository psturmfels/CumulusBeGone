function ReplaceClouds(im)
    addpath('segmentation/');
    addpath('replacement/');
    addpath('detection/');

    load('DecisionTreeClassifier');
    load('averageCloudHistVec');
    load('averageSkyHistVec');
    [pixelLabels, ~, ~, Clusters] = slic(im);
    bw = boundarymask(pixelLabels);
    [pixelMask, ~] = classifier(im, B, pixelLabels, Clusters);
    replacedImage = inpaint(im, pixelMask);

    subplot(2,2,1);
    imshow(im);
    subplot(2,2,2);
    imshow(imoverlay(im, bw, 'cyan'));
    subplot(2,2,3);
    imshow(imoverlay(pixelMask, bw, 'cyan'));
    subplot(2,2,4);
    imshow(replacedImage);
end
