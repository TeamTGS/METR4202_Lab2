% Citation:
% Terven J. Cordova D.M., "Kin2. A Kinect 2 Toolbox for MATLAB", Science of
% Computer Programming.
% https://github.com/jrterven/Kin2, 2016.

addpath('Kin2\Mex');
clear
close all
load('cameraParam.mat');
%%
k2 = Kin2('color','depth');
color_width = 1920; color_height = 1080;
d_width = 512; d_height = 424; outOfRange = 4000;
colorScale = 0.5;
color = zeros(color_height*colorScale,color_width*colorScale,3,'uint8');
depth = zeros(d_height,d_width,'uint16');

figure, h2 = imshow(color,[]);
title('Color Source (press q to exit)');
set(gcf,'keypress','k=get(gcf,''currentchar'');'); % listen keypress

k=[];

disp('Press q on any figure to exit')
detector = vision.CascadeObjectDetector('dominoDetector1978_0.2_10.xml');
%detector = vision.CascadeObjectDetector('dominoDetector1978_1976_0.1_10.xml');
while true
    % Get frames from Kinect and save them on underlying buffer
    validData = k2.updateData;
    
    % Before processing the data, we need to make sure that a valid
    % frame was acquired.
    if validData
        % Copy data to Matlab matrices        
        color = k2.getColor;
        depth = k2.getDepth;
        
        % update color figure
        color = undistortImage(imresize(color,colorScale),cameraParams);
        %color = imresize(color,colorScale);
        %color = color(:, :, 3);
        bbox = step(detector,color);

        [dominoNumber,n] = size(bbox);

        if dominoNumber ~= 0
            
            bboxcenter = zeros(dominoNumber,2,'uint16');
            realbboxcenter = zeros(dominoNumber,2,'uint16');
            %depthCoords = zeros(dominoNumber,2,'uint16');
            depthValue = zeros(dominoNumber,1,'uint16');
            realLocation = zeros(dominoNumber,2,'int64');
            pixelX = zeros(dominoNumber,1,'double');
            pixelY = zeros(dominoNumber,1,'double');
            bboxx = zeros(dominoNumber);
            bboxy = zeros(dominoNumber);
            
            for i = 1:dominoNumber
                bboxcenter(i,:) = [floor(bbox(i,1) + (bbox(i,3)/2)),floor(bbox(i,2) + (bbox(i,4)/2))];
                
            end
            
            % real pixel on real picture
            for i = 1:dominoNumber
                realbboxcenter(i,:) = ([bboxcenter(i,1)/colorScale bboxcenter(i,2)/colorScale]);
            end
            
            %depthCoords = k2.mapColorPoints2Depth(realbboxcenter);
            for i = 1:dominoNumber
                singlePixelX = double(realbboxcenter(i,1));
                singlePixelY = double(realbboxcenter(i,2));
                pixelX(i) = double(realbboxcenter(i,1));
                pixelY(i) = double(realbboxcenter(i,2));
                depthCoords = k2.mapColorPoints2Depth([singlePixelX,singlePixelY]);
                if (depthCoords(1) ~= 0) && (depthCoords(2) ~= 0)
                    depthValue(i) = depth(depthCoords(2),depthCoords(1));
                end
            end

            label_str = cell(dominoNumber,1);
            for ii=1:dominoNumber
                if depthValue(ii) == 0
                    label_str{ii} = ['Domino: Depth sensor out of range. x: ' num2str(realbboxcenter(ii,1)) ', y:' num2str(realbboxcenter(ii,2))];
                else
                    label_str{ii} = ['Domino' num2str(ii) ':' num2str(depthValue(ii)) 'mm, x: ' num2str(realbboxcenter(ii,1)) ', y:' num2str(realbboxcenter(ii,2))];
                end
            end



            detectedImg = insertObjectAnnotation(color,'rectangle',bbox,label_str,'TextBoxOpacity',0.8,'FontSize',10);

            color = insertMarker(detectedImg,bboxcenter,'x','color','red','size',5);
            
            
            
%             for ii=1:dominoNumber
%                 camMatrix = cameraMatrix(cameraParams,cameraParams.RotationMatrices(:,:,8),cameraParams.TranslationVectors(8,:));
%                 c = camMatrix;
%                 u = pixelX(ii);
%                 v = pixelY(ii);
%                 z = depthValue(i);
%                 syms  w x y ;
%                 [X, Y, W]=solve( c(1,1)*x+c(2,1)*y+c(3,1)*z+c(4,1)*1 ==w*u,c(1,2)*x+c(2,2)*y+c(3,2)*z+c(4,2)*1 ==w*v,c(1,3)*x+c(2,3)*y+c(3,3)*z+c(4,3)*1 ==w,   [x, y,w]);
%                 realLocation(i,:) = [X,Y];
%             end

        end
        %plot (bboxcenter(:,1),bboxcenter(:,2),'ro');
        set(h2,'CData',color); 
        

    end
    % If user presses 'q', exit loop
    if ~isempty(k)
         if strcmp(k, 't')

             if(dominoNumber == 2)
                 realX = zeros(dominoNumber,1);
                 realY = zeros(dominoNumber,1);
                for i = 1:dominoNumber
                    bboxx(i) = double(bboxcenter(i,1));
                    realX(i) = realLocation(i,1);
                    bboxy(i) = double(bboxcenter(i,2));
                    realY(i) = realLocation(i,2);
                end
                
                h3 = line([bboxx(1),bboxx(2)],[bboxy(1),bboxy(2)],'Color','r','LineWidth',2);

                length = sqrt(( realY(2)-realY(1) )^2 + (realX(2) - realX(1))^2);
                h4 = legend(h3,num2str(length));
                k=[];
             end
         end
         if strcmp(k, 'c')
            delete(h3);
            delete(h4);
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
