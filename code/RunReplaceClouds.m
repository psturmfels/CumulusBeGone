imageBaseDir = 'exampleImages/';
imageName = 'FakeClouds.png';
im = im2double(imread(strcat(imageBaseDir, imageName)));
ReplaceClouds(im);