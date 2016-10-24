function createImagePath(pathRoot, datasetName)
% ����ͼ���ļ��б�
% img_root = '/mnt/pan/D_windows/data/attribute/relative_attributes_v2/relative_attributes/osr/images/';
dirs_img = dir([pathRoot datasetName '/images/*.jpg']);
fileName = ['./data/' datasetName '_path.txt'];
fid = fopen(fileName, 'w');
for i = 1:length(dirs_img)
    fprintf(fid, [pathRoot datasetName '/images/' dirs_img(i).name ' ' num2str(0) '\n']);
end
fclose(fid);