function createImagePath(pathRoot, datasetName)
dirs_img = dir([pathRoot datasetName '/images/*.jpg']);
fileName = ['./data/' datasetName '_path.txt'];
fid = fopen(fileName, 'w');
for i = 1:length(dirs_img)
    fprintf(fid, [pathRoot datasetName '/images/' dirs_img(i).name ' ' num2str(0) '\n']);
end
fclose(fid);