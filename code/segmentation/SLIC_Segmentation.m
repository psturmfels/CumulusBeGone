% SLIC Simple Linear Iterative Clustering SuperPixels
%
% Implementation of Achanta, Shaji, Smith, Lucchi, Fua and Susstrunk's
% SLIC Superpixels
%
% Usage:   [l, Am, Sp, d] = slic(im, k, m, seRadius, colopt, mw)
%
% Arguments:  im - Image to be segmented.
%              k - Number of desired superpixels. Note that this is nominal
%                  the actual number of superpixels generated will generally
%                  be a bit larger, espiecially if parameter m is small.
%              m - Weighting factor between colour and spatial
%                  differences. Values from about 5 to 40 are useful.  Use a
%                  large value to enforce superpixels with more regular and
%                  smoother shapes. Try a value of 10 to start with.
%       seRadius - Regions morphologically smaller than this are merged with
%                  adjacent regions. Try a value of 1 or 1.5.  Use 0 to
%                  disable.
%         colopt - String 'mean' or 'median' indicating how the cluster
%                  colour centre should be computed. Defaults to 'mean'
%             mw - Optional median filtering window size.  Image compression
%                  can result in noticeable artifacts in the a*b* components
%                  of the image.  Median filtering can reduce this. mw can be
%                  a single value in which case the same median filtering is
%                  applied to each L* a* and b* components.  Alternatively it
%                  can be a 2-vector where mw(1) specifies the median
%                  filtering window to be applied to L* and mw(2) is the
%                  median filtering window to be applied to a* and b*.
%
% Returns:     l - Labeled image of superpixels. Labels range from 1 to k.
%             Am - Adjacency matrix of segments.  Am(i, j) indicates whether
%                  segments labeled i and j are connected/adjacent
%             Sp - Superpixel attribute structure array with fields:
%                   L  - Mean L* value
%                   a  - Mean a* value
%                   b  - Mean b* value
%                   r  - Mean row value
%                   c  - Mean column value
%                   stdL  - Standard deviation of L* 
%                   stda  - Standard deviation of a* 
%                   stdb  - Standard deviation of b* 
%                   N - Number of pixels
%                   edges - List of edge numbers that bound each
%                           superpixel. This field is allocated, but not set,
%                           by SLIC. Use SPEDGES for this.
%              d - Distance image giving the distance each pixel is from its
%                  associated superpixel centre.


function [l, Am, Sp, d] = SLIC_Segmentation(im, k, l_weight, a_weight, b_weight, seRadius, colopt, mw, nItr)
    
    if ~exist('colopt','var') || isempty(colopt), colopt = 'mean'; end
    if ~exist('mw','var')     || isempty(mw),         mw = 0;      end
    if ~exist('nItr','var')   || isempty(nItr),     nItr = 10;     end
        
    MEANCENTRE = 1;
    MEDIANCENTRE = 2;
    
    if strcmp(colopt, 'mean')
        centre = MEANCENTRE;
    elseif strcmp(colopt, 'median')
        centre = MEDIANCENTRE;        
    else
        error('Invalid colour centre computation option');
    end
    
    [rows, cols, chan] = size(im);
    if chan ~= 3
        error('Image must be colour');
    end
    
    % Convert image to L*a*b* colourspace.  This gives us a colourspace that is
    % nominally perceptually uniform. This allows us to use the euclidean
    % distance between colour coordinates to measure differences between
    % colours.  Note the image becomes double after conversion.  We may want to
    % go to signed shorts to save memory.
    im = rgb2lab(im); 

    % Apply median filtering to colour components if mw has been supplied
    % and/or non-zero
    if mw
        if length(mw) == 1
            mw(2) = mw(1);  % Use same filtering for L and chrominance
        end
        for n = 1:3
            im(:,:,n) = medfilt2(im(:,:,n), [mw(1) mw(1)]);
        end
    end
    
    % Nominal spacing between grid elements assuming hexagonal grid
    S = sqrt(rows*cols / (k * sqrt(3)/2));
    
    % Get nodes per row allowing a half column margin at one end that alternates
    % from row to row
    nodeCols = round(cols/S - 0.5);
    % Given an integer number of nodes per row recompute S
    S = cols/(nodeCols + 0.5); 

    % Get number of rows of nodes allowing 0.5 row margin top and bottom
    nodeRows = round(rows/(sqrt(3)/2*S));
    vSpacing = rows/nodeRows;

    % Recompute k
    k = nodeRows * nodeCols;
    
    % Allocate memory and initialise clusters, labels and distances.
    C = zeros(6,k);          % Cluster centre data  1:3 is mean Lab value,
                             % 4:5 is col, row of centre, 6 is No of pixels
    l = -ones(rows, cols);   % Pixel labels.
    d = inf(rows, cols);     % Pixel distances from cluster centres.
    
    % Initialise clusters on a hexagonal grid
    kk = 1;
    r = vSpacing/2;
    
    for ri = 1:nodeRows
        % Following code alternates the starting column for each row of grid
        % points to obtain a hexagonal pattern. Note S and vSpacing are kept
        % as doubles to prevent errors accumulating across the grid.
        if mod(ri,2), c = S/2; else, c = S;  end
        
        for ci = 1:nodeCols
            cc = round(c); rr = round(r);
            C(1:5, kk) = [squeeze(im(rr,cc,:)); cc; rr];
            c = c+S;
            kk = kk+1;
        end
        
        r = r+vSpacing;
    end
    
    % Now perform the clustering.  10 iterations is suggested but I suspect n
    % could be as small as 2 or even 1
    S = round(S);  % We need S to be an integer from now on
    
    for n = 1:nItr
       for kk = 1:k  % for each cluster

           % Get subimage around cluster
           rmin = max(C(5,kk)-S, 1);   rmax = min(C(5,kk)+S, rows); 
           cmin = max(C(4,kk)-S, 1);   cmax = min(C(4,kk)+S, cols); 
           subim = im(rmin:rmax, cmin:cmax, :);  
           assert(numel(subim) > 0)
           
           % Compute distances D between C(:,kk) and subimage
           D = dist(C(:, kk), subim, rmin, cmin, S, l_weight, a_weight, b_weight);


           % If any pixel distance from the cluster centre is less than its
           % previous value update its distance and label
           subd =  d(rmin:rmax, cmin:cmax);
           subl =  l(rmin:rmax, cmin:cmax);
           updateMask = D < subd;
           subd(updateMask) = D(updateMask);
           subl(updateMask) = kk;
           
           d(rmin:rmax, cmin:cmax) = subd;
           l(rmin:rmax, cmin:cmax) = subl;           
       end
       
       % Update cluster centres with mean values
       C(:) = 0;
       for r = 1:rows
           for c = 1:cols
              tmp = [im(r,c,1); im(r,c,2); im(r,c,3); c; r; 1];
              C(:, l(r,c)) = C(:, l(r,c)) + tmp;
           end
       end
       
       % Divide by number of pixels in each superpixel to get mean values
       for kk = 1:k 
           C(1:5,kk) = round(C(1:5,kk)/C(6,kk)); 
       end
       
       % Note the residual error, E, is not calculated because we are using a
       % fixed number of iterations 
    end
    
    % Cleanup small orphaned regions and 'spurs' on each region using
    % morphological opening on each labeled region.  The cleaned up regions are
    % assigned to the nearest cluster. The regions are renumbered and the
    % adjacency matrix regenerated.  This is needed because the cleanup is
    % likely to change the 	 of labeled regions.
     [l, Am] = mcleanupregions(l, seRadius);
%    Am = l;

    % Recompute the final superpixel attributes and write information into
    % the Sp struct array.
    N = length(Am);
    Sp = struct('L', cell(1,N), 'a', cell(1,N), 'b', cell(1,N), ...
                'stdL', cell(1,N), 'stda', cell(1,N), 'stdb', cell(1,N), ...
                'r', cell(1,N), 'c', cell(1,N), 'N', cell(1,N));
    [X,Y] = meshgrid(1:cols, 1:rows);
    L = im(:,:,1);    
    A = im(:,:,2);    
    B = im(:,:,3);    
    for n = 1:N
        mask = l==n;
        nm = sum(mask(:));
        if centre == MEANCENTRE     
            Sp(n).L = sum(L(mask))/nm;
            Sp(n).a = sum(A(mask))/nm;
            Sp(n).b = sum(B(mask))/nm;
            
        elseif centre == MEDIANCENTRE
            Sp(n).L = median(L(mask));
            Sp(n).a = median(A(mask));
            Sp(n).b = median(B(mask));
        end
        
        Sp(n).r = sum(Y(mask))/nm;
        Sp(n).c = sum(X(mask))/nm;
        
        % Compute standard deviations of the colour components of each super
        % pixel. This can be used by code seeking to merge superpixels into
        % image segments.  Note these are calculated relative to the mean colour
        % component irrespective of the centre being calculated from the mean or
        % median colour component values.
        Sp(n).stdL = std(L(mask));
        Sp(n).stda = std(A(mask));
        Sp(n).stdb = std(B(mask));

        Sp(n).N = nm;  % Record number of pixels in superpixel too.
    end
   