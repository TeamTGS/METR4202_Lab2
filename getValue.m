function y = getValue(Im)
%% read image
%Im = imread('capture.png');
%Im = imread('sample\5.jpg');
%Im = imresize(Im,0.2);

%% gray scale
%greyIm = rgb2gray(Im);
greyBlueIm = Im(:, :, 3);
%imshow(greyBlueIm);

%% edge detect
cannyIm = edge(greyBlueIm,'canny',0.2);
%imshow(cannyIm);

%% blur
%blurredImage = conv2(single(cannyIm), ones(5));
%se = strel('disk',1);
%afterOpening = imopen(blurredImage,se);

%% edge linking
%[edgelist,edgeim, etypr] = edgelink(cannyIm);
%figure;imshow(edgeim);

%% edge clearing
%imclose
%clearIm = imclearborder(cannyIm);
%figure;imshow(clearIm);

%% remove small object
clearIm = bwareaopen(cannyIm,50);
%imshow(clearIm);hold on


%% find circle using centroid

stats = regionprops(clearIm,'centroid','MajorAxisLength','MinorAxisLength');
centroids = cat(1, stats.Centroid);

Major = cat (1, stats.MajorAxisLength);
Minor = cat (1, stats.MinorAxisLength);
AxisLength = cat(2, Major, Minor);

%diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2); % mean of row
% fliter centroids with large diameters
[m,n] = size(centroids);
j=0;
%plot(centroids(:,1),centroids(:,2),'b*')
for i=1:m
   
    if (AxisLength(i,1) / AxisLength(i,2) )> 1.2 % ratio of major and minor axis to find object similar to a cir
       continue
    else
        j=j+1;
        
        plot(centroids(i,1),centroids(i,2),'b*')
        
    end
    
end

for i=1:m
    floorcentroid(i,1) = floor(centroids(i,1));
    floorcentroid(i,2) = floor(centroids(i,2));
end

y = j;
%plot(centroids(:,1),centroids(:,2), 'b*')

%se = strel('disk',2);
%closeBW = imclose(clearIm,se);

%imshow(closeBW)

%% fill holes
%fillIm = imfill(closeBW,floorcentroid);
%imshow(fillIm);

%% invert color
%invfillIm = ~fillIm;
%figure;
%imshow(invfillIm);

%% use invert image to find numbers of dominos
%cc = bwconncomp(fillIm,8);
%numberOfDominos  = cc.NumObjects;

%% erode
% imerode

%% detect corner
%corners = detectHarrisFeatures(clearIm);

%% predefine number of strongest point (6)
%figure;
%imshow(clearIm); hold on;
%plot(corners.selectStrongest(6));
%c = corners.selectStrongest(6);

%% coordinates of strongest points
%x = c.Location(:, 1);
%y = c.Location(:, 2);

%% find value of dominos
%imshow(cannyIm);
%clearCannyIm = bwareaopen(fillIm,20);
%imshow(fillIm);figure
%fillClearCannyIm = imfill(fillIm,[1,1]);
%imshow(fillClearCannyIm)
%fillClearCannyIm2 = imfill(~fillClearCannyIm,[1,1]);

%fillClearCannyIm3 = imfill(~fillClearCannyIm2,'holes');
%imshow(fillClearCannyIm3)

%stats = regionprops(fillIm,'centroid','MajorAxisLength','MinorAxisLength');
%centroids = cat(1, stats.Centroid);
%plot(centroids(:,1),centroids(:,2), 'b*')


%diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
%radii = diameters/2;

%[m,n] = size(centroids);

%for i = 1:m
   
    
    
%end
%radii(1:3199,1:2) = 13.5;
%viscircles(centroids,radii)


%% find circles
%Rmin = 7;
%Rmax = 17;
%[centersBright, radiiBright] = imfindcircles(fillClearCannyIm3,[Rmin Rmax],'ObjectPolarity','bright');
%viscircles(centersBright, radiiBright,'EdgeColor','b');

% m is the numer of circle
%[m,n]=size(radiiBright);

end
