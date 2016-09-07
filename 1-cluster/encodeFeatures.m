function encodeFeatures(centers,fullvideoname,descriptor_path,featDir,class_category)
	st = 1;
	%send = size(fullvideoname);
	send = 10;
	video_dir = '~/remote/KTH/';
    category = dir(video_dir);
    for i = 3:length(category) % 1-6 actions
    	timest = tic();
    	for j = 1:25
    		for k = 1:4 % for clips
    			descriptorFile = [];
				clipName = 'person';
				clipName = sprintf('%s%02d',clipName,j);
				clipName = sprintf('%s_%s_d%d_uncomp',clipName,category(i).name,k);
				descriptorFile = fullfile(descriptor_path,sprintf('%s.mat',clipName));
				fprintf('%s is descriptorFile \n', descriptorFile);
				if exist(descriptorFile,'file')
					load(descriptorFile);
					fprintf('load %s complete \n',descriptorFile);
        		else
        			fprintf('%s not exist !!!\n',descriptorFile);
        			[mbhx,mbhy] = extract_improvedfeatures(fullvideoname{i});
        			save(descriptorFile,'mbhx','mbhy'); % should not select so much of it........
        		end
        		mbhx = sqrt(mbhx);mbhy = sqrt(mbhy);
		 		mbh = [mbhx , mbhy];
        		wordTerm = zeros(1,size(centers,2));
        		EDistance  = 100;
	 			tempIndex = 0;
	 			for k = 1:1:size(mbh)
				 		EDistance  = 100;
				 		tempIndex = 0;
				 		for w = 1:1:size(centers,2)
		 					tempDistance = getDistance(centers(:,w),mbh(k,:)');
			 				if EDistance > tempDistance,
			 					EDistance = tempDistance;
			 					tempIndex = w;
			 				end
		 				end
		 			wordTerm(tempIndex) = wordTerm(tempIndex)+1;
		 		end
		 		mbhfeatFile = fullfile(featDir,sprintf('/mbh/%d.mat',j));
		 	    class_label = class_category{i};
		 	    classAndwordTerm = [class_label, wordTerm];
        		dlmwrite(mbhfeatFile,classAndwordTerm, '-append');
    		end
    	end
    	timest = toc(timest);
        fprintf('%d/%d -> %s --> %1.2f sec\n',i-2,length(category)-2,category(i-2).name,timest);		
    end
end

function [distance] = getDistance(a,b)
	sizea = size(a,1);
	sizeb = size(b,1);
	if sizea ~= sizeb
		warning('size not equal return')
	else
		distance = sum((a-b).^2);
		distance = sqrt(distance);
	end
end
