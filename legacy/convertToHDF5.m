files = dir('*.mhd');
fileCount = length(files);

for i = 2 : fileCount
    rawFile = strrep(files(i).name,'.mhd','.raw');
    fileDesc = fopen(files(i).name,'r');
    fileRaw = fopen(rawFile,'r');
    fileDim = [0 0 0];
    %read File properties
        while 1
            tline = fgetl(fileDesc);
            if ~ischar(tline), break, end
            splitedLine = strsplit(tline,' = ');
            if(strcmp(splitedLine(1),'DimSize'))
                x = strsplit(cell2mat(splitedLine(2)));
                fileDim = str2num(cell2mat(x'));
                break;
            end
        end
        fclose(fileDesc);
     %reading file Descriptions did end
     
I=fread(fileRaw,prod(fileDim),'int16=>int16'); 
Z=reshape(I,fileDim');
Z=permute(Z,[2 1 3]);
ct_obj = CT(Z);
ilker_write_CT2h5(strrep(files(i).name,'.mhd',''), ct_obj);
end