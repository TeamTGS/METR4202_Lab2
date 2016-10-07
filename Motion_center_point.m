
%%  Find center location, the final output value should be 'center_x' and 'center_y' 
%%  This code can only get x,y value, it will not plot any graph, velocity should be continue developing

%   Load appropriate video (current code suggests use 30 framerate and 5
%   seconds video length)
clear;
clc;
readvid = VideoReader ('motion.avi');   % video file name
nFrames = readvid.NumberOfFrames;


for k=1:nFrames

    capture = read(readvid,k);                  % snapshot



%%%%%%%%
% capture = imresize(imread(capture),1);

%
bbox = step(detector,capture);

detectedImg = insertObjectAnnotation(capture,'rectangle',bbox,'Dominos');   
%%
% Display the detected dominos
%figure;
%imshow(detectedImg);hold on;

%%
% Remove the image directory from the path.
%rmpath(imDir);

%%
[dominoNumber,n] = size(bbox);
% newbbox(1,1) = bbox(1,1)*2;
% newbbox(1,2) = bbox(1,2)*2;

% for i = 0:dominoNumber
%     i=i+1;
%     dominoValue(i) = getValue(imcrop(img,bbox));
%     
% end
% 
%figure (1)
%hold on

%   Set new array
bboxcenter = zeros(2,dominoNumber);
if (dominoNumber >1) ;
    for i = 1:dominoNumber
        bboxcenter(i,1) = floor(bbox(i,1) + (bbox(i,3)/2));
        bboxcenter(i,2) = floor(bbox(i,2) + (bbox(i,4)/2));
        loc_x(k,i)=bboxcenter(i,1);
        loc_y(k,i)=bboxcenter(i,2);
        %plot (bboxcenter(:,1),bboxcenter(:,2),'ro');
    end
elseif (dominoNumber ==1);% && dominoNumber~=[];
    bboxcenter(1,1) = floor(bbox(1,1) + (bbox(1,3)/2));
    bboxcenter(1,2) = floor(bbox(1,2) + (bbox(1,4)/2));
    loc_x(k,1)=bboxcenter(1,1);
    loc_y(k,1)=bboxcenter(1,2);
else (dominoNumber ==0);
    loc_x(k,1)=0;
    loc_y(k,1)=0;
end
%%  finished


end

%%  Filter start
[h,hh]=size(loc_x);
I=find (loc_x~=0);
first_num=I(1);
for aa=1:h-1
    for bb=1:hh
        % 50 can be changed to another number, suggest use 50.
    if ((((abs(loc_x(aa,bb)-loc_x(aa+1,bb))<50) && (abs(loc_y(aa,bb)-loc_y(aa+1,bb))<50))|| (loc_x(aa,bb)==0))|| (loc_y(aa,bb)==0))||(loc_x(aa+1,bb)==0)|| (loc_y(aa+1,bb)==0);
        nloc_x(aa,bb)=loc_x(aa,bb);
        nloc_y(aa,bb)=loc_y(aa,bb);
    else
        nloc_x(aa,bb)=0;
        nloc_y(aa,bb)=0;
    end
    end
end
nloc_x(h,1)=loc_x(h,1);
nloc_y(h,1)=loc_y(h,1);

%   find the biggest value
for aaa=1:h
    center_x(aaa,:)=max(nloc_x(aaa,:));
    center_y(aaa,:)=max(nloc_y(aaa,:));
end

%   write ~0 value
for aaaa=1:h-1
    if center_x(aaaa)==0;
    center_x(aaaa)=center_x(aaaa+1);    % output value
    center_y(aaaa)=center_y(aaaa+1);    % output value
    else
    end
end

%%  Filter End

%%  Velocity calculation cont...
