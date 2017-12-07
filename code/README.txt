===============HOW TO USE THIS REPOSITORY===============
Given an example image in double format called im, call the 'ReplaceClouds(im)' function. This function segments the image, identifies cloud-like regions, and inpaints those regions. This function then displays the result.

This function first segments the image using the slic.m function. It then detects cloud and sky regions using simpleClassifier.m. Finally, it replaces the cloud regions using inpaint.m.

===============CONTENTS OF THIS REPOSITORY==============
The following files were ORIGINAL code written by Pascal Sturmfels and Jeffrey Dominic:

-detection
+--CalculateMeanHistograms.m
+--classifier.m
+--colorHistVec.m
+--histogramIntersection.m
+--HOGClassifier.m
+--meanColorHist.m
+--RestoreClassifier.m
+--RunTraining.m
+--simpleClassifier.m
+--simpleThreshold.m

-replacement
+--inpaint.m
+--RunInpainting.m

-segmentation
+--dist.m
+--RunSegmentation.m
+--slic.m

The files below were taken from an online website: http://www.peterkovesi.com. They are NOT original work.

-segmentation
+--circularstruct.m
+--finddisconnected.m
+--makeregionsdistinct.m
+--mcleanupregions.m
+--regionadjacency.m
+--renumberregions.m

-tests
+--SegmentationComparison.py

The files taken from an online repository are used to do morphological cleaning up of SLIC superpixels after they are segmented. The rest of this repository is original work.