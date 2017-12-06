function ReplaceClouds(im)
    addpath('segmentation/');
    addpath('replacement/');
    addpath('detection/');

    load('DecisionTreeClassifier');
    [pixelLabels, ~, ~, Clusters] = slic(image);
    bw = boundarymask(pixelLabes);
    [pixelMask, ~] = classifier(image, B, pixelLabels, Clusters);
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
