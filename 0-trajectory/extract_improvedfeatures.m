% TODO: Change the paths and improved trajectory binary paths
function [mbhx,mbhy] = extract_improvedfeatures(videofile)   
    [~,nameofvideo,~] = fileparts(videofile);
    txtFile = fullfile('~/remote/Data/temp/tmpfiles',sprintf('%s-%1.6f',nameofvideo,tic())); % path of the temporary file
    % Here the path should be corrected
    system(sprintf('~/Desktop/code_lyk-matlab/0-trajectory/release/debug/DenseTrackStab %s > %s',videofile,txtFile));
    data = dlmread(txtFile);
    delete(txtFile);
    mbhx  = data(:,41+96+108:41+96+108+95);
    mbhy  = data(:,41+96+108+96:41+96+108+96+95);
end

