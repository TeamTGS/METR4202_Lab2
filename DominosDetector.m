clear
clc
load('C:\Users\kfhlx\Desktop\Lab2\matlab.mat');

imDir = ('C:\Users\kfhlx\Desktop\Lab2\AutoPostivie\total');
addpath(imDir);

negativeFolder = ('C:\Users\kfhlx\Desktop\Lab2\negative');
trainCascadeObjectDetector('dominoDetector1978_0.5_5.xml',positiveInstances,negativeFolder,'FalseAlarmRate',0.5,'NumCascadeStages',5);