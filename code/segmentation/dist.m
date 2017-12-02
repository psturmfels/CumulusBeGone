%-- dist -------------------------------------------
%
% Usage:  D = dist(C, im, r1, c1, S, m)
% 
% Arguments:   C - Cluster being considered
%             im - sub-image surrounding cluster centre
%         r1, c1 - row and column of top left corner of sub image within the
%                  overall image.
%              S - grid spacing
%              m - weighting factor between colour and spatial differences.
%
% Returns:     D - Distance image giving distance of every pixel in the
%                  subimage from the cluster centre
function D = dist(C, im, r1, c1, S, l_weight, a_weight, b_weight)

    % Squared spatial distance
    [rows, cols, chan] = size(im);
    [x,y] = meshgrid(c1:(c1+cols-1), r1:(r1+rows-1));
    x = x-C(4);  % x and y dist from cluster centre
    y = y-C(5);
    ds2 = x.^2 + y.^2;
    
    % Compute difference between image pixels and cluster center
    for n = 1:chan
        im(:,:,n) = (im(:,:,n)-C(n)).^2;
    end
    
    % Squared l difference
    dcl = im(:,:,1);
    
    % Squared a difference
    dca = im(:,:,2);
    
    % Squared b difference
    dcb = im(:,:,3);
    
    D = sqrt(ds2/S^2 + dcl * l_weight^2 + dca * a_weight^2 + dcb * b_weight^2);
    