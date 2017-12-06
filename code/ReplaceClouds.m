function ReplaceClouds(im)
    addpath('segmentation/');
    addpath('replacement/');
    addpath('detection/');

    [pixelLabels, ~, ~, Clusters] = slic(im, 400, 0.01, 0.05, 0.1, 3);
    bw = boundarymask(pixelLabels);
    [skyCloudPixelMask, pixelMask] = simpleClassifier(im, pixelLabels, Clusters);
    replacedImage = inpaint(im, pixelMask, skyCloudPixelMask);

    figure;
    subplot(1,4,1);
    imshow(im);
    subplot(1,4,2);
    imshow(imoverlay(im, bw, 'cyan'));
    subplot(1,4,3);
    imshow(imoverlay(skyCloudPixelMask / 2, bw, 'cyan'));
    subplot(1,4,4);
    imshow(replacedImage);
end
