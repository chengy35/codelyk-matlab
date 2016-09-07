function [fullvideoname, videoname,vocabDir,featDir,actionName,descriptor_path,class_category] = getConfig()
    vocabDir = '~/remote/Data/Vocab'; % Path where dictionary/GMM will be saved.
    featDir = '~/remote/Data/feats'; % Path where features will be saved
    descriptor_path = '~/remote/Data/descriptor/'; % change paths here 
    video_dir = '~/remote/KTH/';
    category = dir(video_dir);

    index = 1;
    for i = 3 : length(category)
    	fnames = dir(fullfile(video_dir,category(i).name));
    	for j = 3: length(fnames)
        	fullvideoname{index,1}=fullfile(video_dir,category(i).name,fnames(j).name);
        	videoname{index,1} = fnames(j).name;
            class_category{index,1}= i-2;
        	index = index+1;
        end
    end 
    actionName = {'boxing','handclapping','handwaving','jogging','running','walking'};		
end
