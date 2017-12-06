function histVec = colorHistVec(pixelLabels, image, superpixelID)
%
%Computes a color histograms for superpixel with id 'superpixelID'. 
%
%Arguments: b - number of bins for each channel histogram
%           pixelLabels - output of SLIC segmentation
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
edges = -50:5:50;

histSP = [];
for j=2:numChannels
    singleChan = image(:,:,j);
    singleSPChan = singleChan(pixelLabels == superpixelID);
    [curHist, ~] = histcounts(singleSPChan, edges);
    curHist = curHist';
    curHistNorm = curHist / sum(curHist(:)); %curHist / norm(curHist, 1); %normalized histogram
    histSP = [histSP; curHistNorm];
end

histVec = histSP';

        
        
        
    
    
    
    
 





