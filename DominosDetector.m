clear
clc
% read saved variable 'positiveInstances' from the training image labeler in MATLAB
load('C:\Users\kfhlx\Desktop\Lab2\matlab.mat');
% locate the positive folder
imDir = ('C:\Users\kfhlx\Desktop\Lab2\AutoPostivie\total');
addpath(imDir);
% locate the negative folder
negativeFolder = ('C:\Users\kfhlx\Desktop\Lab2\negative');
% train cascade object detector
trainCascadeObjectDetector('dominoDetector1978_0.5_5.xml',positiveInstances,negativeFolder,'FalseAlarmRate',0.5,'NumCascadeStages',5);
