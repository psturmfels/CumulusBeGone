function histVec = colorHistVec(b, pixelLabels, k, image, superpixelID)
%
%Computes a color histograms for superpixel with id 'superpixelID'. 
%
%Arguments: b - number of bins for each channel histogram
%           pixelLabels - output of SLIC segmentation
%           k - number of superpixels
%           image - input image
%           superpixelID - id of superpixel for which we want a histogram
%
%Returns: histVec - a matrix of size (3*b, 1) containing a color histogram

%default 256 bins for each channel of the color histogram
if ~exist('b','var') || isempty(b)
    b = 256;
end
  
numChannels = size(image, 3);
histVec = zeros(3*b, 1);

histSP = [];
for j=1:numChannels
    singleChan = image(:,:,j);
    singleSPChan = singleChan(pixelLabels == superpixelID);
    curHist = imhist(singleSPChan, b);
    curHistNorm = curHist / sum(curHist(:)); %curHist / norm(curHist, 1); %normalized histogram
    histSP = [histSP; curHistNorm];
end

histVec = histSP;

        
        
        
    
    
    
    
 





