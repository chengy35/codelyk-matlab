function computeDistance(fullvideoname,featDir)
	st = 1;
	centerSize = 4000;
	r = 0.125*0;

	%send = size(fullvideoname);
	send = 10;
	video_dir = '~/remote/KTH/';
    category = dir(video_dir);
    	
	for j = 1:25
		timest = tic();
	    trainfeatFile = {};
	    index = 1;
	    for k = 1:25
	    	if j ~= k,
				trainfeatFile{index} = [fullfile(featDir,sprintf('/mbh/%d.mat',k))];
				index = index+1;
			end
		end
		testfeatFile = fullfile(featDir,sprintf('/mbh/%d.mat',j));
		distanceFile = fullfile(featDir,sprintf('/distance/%d.mat',j));
		fprintf('%s is testfeatFile\n', testfeatFile);
		fprintf('%s is distanceFile\n', distanceFile);
		trainclassAndwordTerm = [];
		for k = 1:length(trainfeatFile)
			trainclassandwordterm = dlmread(trainfeatFile{k});
			trainclassAndwordTerm = [trainclassAndwordTerm; trainclassandwordterm];
			fprintf('%s is trainfeatFile\n', trainfeatFile{k});	
		end

		testclassAndwordTerm = [];
		testclassandwordterm = dlmread(testfeatFile);
		testclassAndwordTerm = [trainclassAndwordTerm; testclassandwordterm];
		TF = ones(1,centerSize);
		TF = FeatureSelection(TF);
		ComputeWeight(distanceFile,trainclassAndwordTerm,testclassAndwordTerm,TF);
		timest = toc(timest);
	    fprintf('%d/%d --> %1.2f sec\n',j,25,timest);
	end
end

function TF =  FeatureSelection(TF)
	index = 0;
	stop = round(r*centerSize);
	weightValues=[TF];
	maxIG = max(TF);
	weightValues = sort(weightValues);
	threshold = weightValues[stop];
	below = [TF < threshold]*0.001;
	above = [TF >= threshold]*1;
	TF = [below + above] % matlab is great...
end

function ComputeWeight(distanceFile,trainclassAndwordTerm,testclassAndwordTerm,TF)
	distance = [];
	norFactor = [];
	averageDistance = 0;
	trainlabel = trainclassAndwordTerm(:,1);
	trainclassAndwordTerm = [trainclassAndwordTerm(:,2:size(trainclassAndwordTerm,2))];
	
	testlabel = testclassAndwordTerm(:,1);
	testclassAndwordTerm = [testclassAndwordTerm(:,2:size(testclassAndwordTerm,2))];
	
	%get the normalization factors for training videos
	index = 1;
	for i = 1:size(trainclassAndwordTerm,1)
		norFactor[index] = sum(TF.*trainclassAndwordTerm(i,:));
		index = index +1;
	end
	
	% get the normalization factors for testing videos
	for i = 1:size(testclassAndwordTerm,1)
		norFactor[index] = sum(TF.*testclassAndwordTerm(i,:));
		index = index +1;
	end

	%compute the x^2 distances between training videos

	distance = zeros(size(trainclassAndwordTerm,1) + size(testclassAndwordTerm,1),size(trainclassAndwordTerm,1));
	for iRow = 1:size(trainclassAndwordTerm,1)
		for iCol = 1:size(trainclassAndwordTerm,1)
			iRowEle = 1;
			iColEle = 1;
			distance(iRow,iCol) = 0;
			subscriptrow = find(trainclassAndwordTerm(:,iRow));
			subscriptcol = find(trainclassAndwordTerm(:,iCol));
			lengthrow = length(subscriptrow);
			lengthcol = length(subscriptcol);
			while (true)
				if iRowEle > subscriptrow && iColEle > subscriptcol
					break;
				end
				rowIndex = subscriptrow(iRowEle);
				colIndex = subscriptcol(iColEle);
				if rowIndex < colIndex || iColEle > subscriptcol
					rowValue = TF(rowIndex) * log(trainclassAndwordTerm(iRow,iRowEle) + 1) / norFactor(iRow);
					distance(iRow,iCol)  = distance(iRow,iCol) + 0.5 * rowValue;
					iRowEle = iRowEle + 1;

				else if colIndex < rowIndex || iRowEle > subscriptrow
					colValue = TF(colIndex)  * log(trainclassAndwordTerm(iCol,iColEle) + 1) /  norFactor(iCol);
					distance(iRow,iCol)  = distance(iRow,iCol) + 0.5 * colValue;
					iColEle = iColEle + 1;
				else
					rowValue = TF(rowIndex) * log(trainclassAndwordTerm(iRow,iRowEle) + 1) / norFactor(iRow);
					colValue = TF(colIndex) * log(trainclassAndwordTerm(iCol,iColEle) + 1) / norFactor(iCol);
				
					if rowValue ~= colValue
						distance(iRow,iCol) = distance(iRow,iCol) + 0.5 * (rowValue -  colValue)^2 / (rowValue + colValue);
					end
					iRowEle = iRowEle + 1;
					iColEle = iColEle + 1;
				end
			end
			averageDistance = averageDistance +  distance(iRow,iCol);
		end
	end
	averageDistance = averageDistance/(size(trainclassAndwordTerm,1)^2 - size(trainclassAndwordTerm,1));
	
	%compute the x^2 distances between testing and training videos
	for iRow = 1:size(testclassAndwordTerm,1)
		for iCol = 1:size(trainclassAndwordTerm,1)
			iRowEle = 1;
			iColEle = 1;
			distance(iRow + size(trainclassAndwordTerm,1),iCol) = 0;
			subscriptrow = find(testclassAndwordTerm(:,iRow));
			subscriptcol = find(trainclassAndwordTerm(:,iCol));
			lengthrow = length(subscriptrow);
			lengthcol = length(subscriptcol);
			while (true)
				if iRowEle > subscriptrow && iColEle > subscriptcol
					break;
				end
				rowIndex = subscriptrow(iRowEle);
				colIndex = subscriptcol(iColEle);
				if rowIndex < colIndex || iColEle > subscriptcol
					rowValue = TF(rowIndex) * log(testclassAndwordTerm(iRow,iRowEle) + 1) / norFactor(iRow);
					distance(iRow + size(trainclassAndwordTerm,1),iCol)  = distance(iRow + size(trainclassAndwordTerm,1),iCol) + 0.5 * rowValue;
					iRowEle = iRowEle + 1;

				else if colIndex < rowIndex || iRowEle > subscriptrow
					colValue = TF(colIndex)  * log(trainclassAndwordTerm(iCol,iColEle) + 1) /  norFactor(iCol);
					distance(iRow +size(trainclassAndwordTerm,1),iCol)  = distance(iRow+size(trainclassAndwordTerm,1),iCol) + 0.5 * colValue;
					iColEle = iColEle + 1;
				else
					rowValue = TF(rowIndex) * log(testclassAndwordTerm(iRow,iRowEle) + 1) / norFactor(iRow);
					colValue = TF(colIndex) * log(trainclassAndwordTerm(iCol,iColEle) + 1) / norFactor(iCol);
				
					if rowValue ~= colValue
						distance(iRow+size(trainclassAndwordTerm,1),iCol) = distance(iRow+size(trainclassAndwordTerm,1),iCol) + 0.5 * (rowValue -  colValue)^2 / (rowValue + colValue);
					end
					iRowEle = iRowEle + 1;
					iColEle = iColEle + 1;
				end
			end
		end
	end
	trainSize = size(trainclassAndwordTerm,1);
	testSize =  size(testclassAndwordTerm,1);
	dlmwrite(distanceFile,trainSize,testSize);
	distance = distance/averageDistance;
	distance = exp(-distance);
	total = [[trainlabel;testlabel]];distance]; %do not need it of it.
	dlmwrite(distanceFile,total,'-append');
end