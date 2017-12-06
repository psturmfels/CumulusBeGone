% simpleThreshold -- detects clouds pixel by pixel using a set threshold
%
% OVERVIEW: If R-B > 30 for a pixel, where R = red channel and B = blue
% channel, classify as clouds. Else classify as sky. If enough of the
% superpixel is classified as clouds / sky, classify the whole superpixel
% in the same way.
%
% Usage: simpleThreshold(im, pixelLabels)
%
% Arguments:    im - original RGB image
%               k - number of superpixels
%               pixelLabels - output of SLIC; each pixel assigned 1,..,k
%
% Output:       A binary image after applying a mask on the original image

function simpleThreshold(im, ~, ~)
    %[r,c] = size(im);
    
    threshold = 20/255;
    
    % Get the R-B channel image
    diffMap = im(:,:,1) - im(:,:,3);
    diffMap = abs(diffMap);
    
    %binaryImage = zeros(size(diffMap,1), size(diffMap,2));
    binaryImage = diffMap < threshold;
    
    binaryImageInt = double(~binaryImage);
    
    maskedImage = im.*repmat(binaryImageInt,[1,1,3]);
    
    subplot(1,3,1), imshow(im);
    subplot(1,3,2), imshow(binaryImage);
    subplot(1,3,3), imshow(maskedImage);
    
    
    