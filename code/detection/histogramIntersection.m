function distance = histogramIntersection(hist1, hist2)

%Calculate the similarity between histograms. Returns 1 ifz identical.

%Assuming the number of bins between histograms is the same
numBins = size(hist1, 2);

sumMin = 0;
for i=1:numBins
    sumMin = sumMin + min(hist1(i), hist2(i));
end

distance = sumMin;