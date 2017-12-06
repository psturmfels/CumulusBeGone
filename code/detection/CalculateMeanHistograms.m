%%CONSTANTS
cloudThreshold = 0.8;
b = 50;
numTrainData = 999;

%primary training data directory
imageDir = '../../data/swimseg/images/';
GTDir = '../../data/swimseg/GTmaps/';

%%Go through every image in training data up to 0300.png
numImage = 1;
%Holds color histogram data
XCloud = [];
XSky = [];


while (numImage < numTrainData)
    if (floor(numImage / 10) == 0)
        imName = strcat('000', int2str(numImage));
    elseif (floor(numImage / 10) >= 1 && floor(numImage / 10) < 10)
        imName = strcat('00', int2str(numImage));
    else
        imName = strcat('0', int2str(numImage));
    end
    
    imageName = strcat(imName, '.png');
    if (mod(numImage, 50) == 0)
        fprintf('Trained on images up to %s\n', imageName);
    end
    GTName = strcat(imName, '_GT.png');
    im = rgb2lab(im2double(imread(strcat(imageDir, imageName))));
    imGT = im2double(imread(strcat(GTDir, GTName)));
    
    XCloud = [XCloud; (colorHistVec(imGT, im, 1))];
    
    XSky = [XSky; (colorHistVec(imGT, im, 0))];
   
    numImage = numImage + 1;
end
averageCloudHistVec = mean(XCloud, 1); 
averageSkyHistVec = mean(XSky, 1);
save 'averageCloudHistVec' averageCloudHistVec;
save 'averageSkyHistVec' averageSkyHistVec;


    