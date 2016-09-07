clear;
clc;
% TODO Add paths
addpath('~/lib/vlfeat/toolbox');
vl_setup();
% TODO Add paths
% add open cv to LD_LIB Path
setenv('LD_LIBRARY_PATH','/usr/local/lib/'); 



% TODO
% add lib linear to path
addpath('~/lib/liblinear/matlab');
% TODO
% add lib svm to path
addpath('~/lib/libsvm/matlab');
% TODO change paths inside getConfig
[fullvideoname, videoname,vocabDir,featDir,actionName,descriptor_path,class_category] = getconfig();

st = 1;
send = length(videoname);
fprintf('Start : %d \n',st);
fprintf('End : %d \n',send);
addpath('0-trajectory');
getSalient(st,send,fullvideoname,descriptor_path)

addpath('1-cluster');
totalnumber = 256000;
kmeans_size = 4000;

%centers = SelectSalient(kmeans_size,totalnumber,fullvideoname,descriptor_path,vocabDir);
%encodeFeatures(centers,fullvideoname,descriptor_path,featDir,class_category);
%computeDistance(fullvideoname,featDir);

addpath('2-trainAndtest');
trainAndTest(fullvideoname,featDir);