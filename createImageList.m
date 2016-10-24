function createImageList(pathRoot, datasetName)
dirs_img = dir([pathRoot datasetName '/images/*.jpg']);
fileName = ['./data/' datasetName '_list.txt'];
fid = fopen(fileName, 'w');
for i = 1:length(dirs_img)
    fprintf(fid, '%s %d\n', dirs_img(i).name, 0);
end
fclose(fid);