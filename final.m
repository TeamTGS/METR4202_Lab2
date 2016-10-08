% Citation:
% Terven J. Cordova D.M., "Kin2. A Kinect 2 Toolbox for MATLAB", Science of
% Computer Programming.
% https://github.com/jrterven/Kin2, 2016.
% some code are comment out for better performance in real time preview

addpath('Kin2\Mex');
clear
close all
load('cameraParam.mat');

opticalFlow = opticalFlowHS;
%%
% create Kin2 object with color and depth
k2 = Kin2('color','depth');

% color size
color_width = 1920; color_height = 1080;

% depth size
d_width = 512; d_height = 424; outOfRange = 4000;

% color scale
colorScale = 0.5;

% pre-allocate color and depth for faster processing
color = zeros(color_height*colorScale,color_width*colorScale,3,'uint8');
depth = zeros(d_height,d_width,'uint16');

% show color figure
figure, h2 = imshow(color,[]);
title('Domino Detector (press q to exit)');
set(gcf,'keypress','k=get(gcf,''currentchar'');'); % listen keypress

k=[];

disp('Press q on any figure to exit')

% create detector object
%detector = vision.CascadeObjectDetector('dominoDetector1978_0.2_10.xml');
detector = vision.CascadeObjectDetector('dominoDetector1978_1976_0.2_10_2.xml');
while true
    % Get frames from Kinect and save them on underlying buffer
    validData = k2.updateData;
    
    % Before processing the data, we need to make sure that a valid
    % frame was acquired.
    if validData
        
        % Copy data to Matlab matrices        
        color1 = k2.getColor;
        depth = k2.getDepth;
        
        % update color figure and undistrot
        color = undistortImage(imresize(color1,colorScale),cameraParams);
        %color = (imresize(color,colorScale));
                
        % use detector with color picture to find dominos
        bbox = step(detector,color);
        
        % numbers of dominos
        [dominoNumber,n] = size(bbox);

        if dominoNumber ~= 0
            
            % pre-allocate matrix for faster processing
            bboxcenter = zeros(dominoNumber,2,'uint16');
            realbbox = zeros(dominoNumber,4,'uint16');
            realbboxcenter = zeros(dominoNumber,2,'uint16');
            depthValue = zeros(dominoNumber,1,'uint16');
            realLocation = zeros(dominoNumber,2,'int64');
            pixelX = zeros(dominoNumber,1,'double');
            pixelY = zeros(dominoNumber,1,'double');
            bboxx = zeros(dominoNumber);
            bboxy = zeros(dominoNumber);
            label_str = cell(dominoNumber,1);
            dominoVal = zeros(dominoNumber,1,'double');
            
            for i = 1:dominoNumber
                % detected domino bbox center
                bboxcenter(i,:) = [floor(bbox(i,1) + (bbox(i,3)/2)),floor(bbox(i,2) + (bbox(i,4)/2))];
                
            end
            
            for i = 1:dominoNumber
                % real pixel on real picture
                realbboxcenter(i,:) = ([bboxcenter(i,1)/colorScale bboxcenter(i,2)/colorScale]);
                
            end
            
            % detect dominos movement speed by optical flow
             flow = estimateFlow(opticalFlow,rgb2gray(color));
           
            
             for i = 1:dominoNumber
                bstartx = bbox(i,1);
                bendx = bstartx + bbox(i,3);
                bstarty = bbox(i,2);
                bendy = bstarty + bbox(i,4);
                
                 flowMag = flow.Magnitude;
                 roi = flowMag(   bstarty:bendy, bstartx:bendx,1) ;
                 [m,n] = size(roi);
                 maxvector = zeros(m,n);
                 maxvector(i) = max(roi(:));
                
             end
            
            % get domino value by getValue.m function
%             for i = 1:dominoNumber
%                 realbbox(i,:) = bbox(i,:)/colorScale;
%                 getValIm = imcrop(color1,realbbox(i,:));
%                 dominoVal(i) = getValue(getValIm);
%             end
            
            for i = 1:dominoNumber
                % get depth value for each box by using mapColorPoints2Depth from Kin2
                singlePixelX = double(realbboxcenter(i,1));
                singlePixelY = double(realbboxcenter(i,2));
                pixelX(i) = double(realbboxcenter(i,1));
                pixelY(i) = double(realbboxcenter(i,2));
                depthCoords = k2.mapColorPoints2Depth([singlePixelX,singlePixelY]);
                if (depthCoords(1) ~= 0) && (depthCoords(2) ~= 0)
                    depthValue(i) = depth(depthCoords(2),depthCoords(1));
                end
            end
            
            for i = 1:dominoNumber
                if depthValue(i) == 0
                    label_str{i} = ['Domino: Depth sensor out of range. x: ' num2str(realbboxcenter(i,1)) ', y:' num2str(realbboxcenter(i,2))];
                else
                    label_str{i} = ['Domino' num2str(i) ':' num2str(depthValue(i)) 'mm, x: ' num2str(realbboxcenter(i,1)) ', y:' num2str(realbboxcenter(i,2)) ', speed: ' num2str(maxvector(i)) ];
                end
            end
            % draw a yellow box around detected dominos
            detectedImg = insertObjectAnnotation(color,'rectangle',bbox,label_str);
            
            % mark the center of each detected dominos
            %color = insertMarker(detectedImg,bboxcenter,'x','color','red','size',5);

            % return the real world coordinates by the depth value return from kinect
%             for ii=1:dominoNumber
%                 camMatrix = cameraMatrix(cameraParams,cameraParams.RotationMatrices(:,:,1),cameraParams.TranslationVectors(1,:));
%                 c = camMatrix;
%                 u = pixelX(ii);
%                 v = pixelY(ii);
%                 z = depthValue(i);
%                 syms  w x y ;
%                 [X, Y, W]=solve( c(1,1)*x+c(2,1)*y+c(3,1)*z+c(4,1)*1 ==w*u,c(1,2)*x+c(2,2)*y+c(3,2)*z+c(4,2)*1 ==w*v,c(1,3)*x+c(2,3)*y+c(3,3)*z+c(4,3)*1 ==w,   [x, y,w]);
%                 
%                 realLocation(i,:) = [double(X),double(Y)];
%             end

        % draw to the figure
        set(h2,'CData',detectedImg);
        end
        
         
        

    end
    % If user presses 'q', exit loop
    if ~isempty(k)
           % if user press 't', calculate the pixel and real world distance of two dominos
         if strcmp(k, 't')

             if(dominoNumber == 2)
%                  realX = zeros(dominoNumber,1);
%                  realY = zeros(dominoNumber,1);
                for i = 1:dominoNumber
                    bboxx(i) = double(bboxcenter(i,1));
%                     realX(i) = realLocation(i,1);
                    bboxy(i) = double(bboxcenter(i,2));
%                     realY(i) = realLocation(i,2);
                end
                
                h3 = line([bboxx(1),bboxx(2)],[bboxy(1),bboxy(2)],'Color','r','LineWidth',2);
                %h4 = line([bboxx(1),bboxx(2)],[bboxy(1),bboxy(2)],'Color','r','LineWidth',2);
                length = sqrt((pixelY(2)-pixelY(1))^2 + (pixelX(2)-pixelX(1))^2);
                reallength = length*0.0675;
                h5 = legend(h3,['real distance: ' num2str(reallength) ' mm']);
                %h6 = legend(h4,['pixel distance: ' num2str(length) ' pixel']);
                
                k=[];
             end
         end
         % if user press c, clear the line and legend from above
         if strcmp(k, 'c')
            %delete(h3);
            %delete(h4);
            %delete(h5);
            %delete(h6);
            %delete(h6);
            k=[];
         end
         if strcmp(k,'k')
            
             if validData
                % Copy data to Matlab matrices        
                
                for i=1:100
                    validData = k2.updateData;
                    color = k2.getColor;
                    filename = ['Calibrate_image_',num2str(i),'.png'];
                    imwrite(color,filename,'png');
                end
                s = rng;
                r = randi(100,20,1);
                
             end
             
         end
         
        if strcmp(k,'q'); break; end;
    end
  
    pause(0.02)
end

% Close kinect object
k2.delete;

close all;
