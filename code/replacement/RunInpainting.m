function RunInpainting(imageNumberString)
imageBaseDir = '../../data/swimseg/images/';
maskBaseDir  = '../../data/swimseg/GTmaps/';

imageFileName = strcat(imageBaseDir, strcat(imageNumberString, '.png'));
maskFileName = strcat(maskBaseDir, strcat(imageNumberString, '_GT.png'));

im = im2double(imread(imageFileName));
mask = im2double(imread(maskFileName));

inpaintedImage = inpaint(im, mask);

subplot(1,3,1);
imshow(im);
subplot(1,3,2);
imshow(mask);
subplot(1,3,3);
imshow(inpaintedImage);
end