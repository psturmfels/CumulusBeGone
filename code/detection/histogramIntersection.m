function distance = histogramIntersection(hist1, hist2)

%Calculate the similarity between histograms. Returns 1 ifz identical.

%Assuming the number of bins between histograms is the same
numBins = size(hist1, 1);

sumH1 = 0;
sumMin = 0;
for i=1:numBins
    sumH1 = sumH1 + hist1(i);
    sumMin = min(hist1(i), hist2(i));
end

distance = norm(hist1 - hist2);