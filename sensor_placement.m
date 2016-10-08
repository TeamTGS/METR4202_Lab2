Im = imread('C:\Users\kfhlx\Pictures\KinectScreenshot-Color-06-05-52.png');
[imagePoints,boardSize] = detectCheckerboardPoints(Im);
imshow(Im); 
hold on; 
[CP_x,I] = min(imagePoints(:,1));
CP_y = imagePoints(I,2);
plot(imagePoints(:,1), imagePoints(:,2), 'r*');
camMatrix = cameraMatrix(cameraParams,cameraParams.RotationMatrices(:,:,1),cameraParams.TranslationVectors(1,:));
c = camMatrix;
u=CP_x;
v=CP_y ;
z=620;
syms  w x y ;
[C_X, C_Y,C_W]=solve( c(1,1)*x+c(2,1)*y+c(3,1)*z+c(4,1)*1 ==w*u,c(1,2)*x+c(2,2)*y+c(3,2)*z+c(4,2)*1 ==w*v,c(1,3)*x+c(2,3)*y+c(3,3)*z+c(4,3)*1 ==w,   [x, y,w]);
 r = vrrotmat2vec(cameraParams.RotationMatrices(:,:,1) );
 frame_localtion_pixel =[CP_x,CP_y]
 sensor_localtion_world = [-C_X, -C_Y,-z]
sensor_angle = radtodeg(r(4))
distance=sqrt(sum(sensor_localtion_world.^2))