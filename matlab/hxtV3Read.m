function [M,bins] = hxtV3Read(filePath)

%open the file
if nargin < 1
    [fileName, pathName] = uigetfile({'*.hxt;*.ezd','Hyperspectral files'}, 'Select a Hyperspectral file');
    if isequal(fileName,0) || isequal(pathName,0)
        disp('User pressed cancel')
        return
    end
    filePath = fullfile(pathName, fileName);
end
tic
fid = fopen(filePath);

% read first 8 characters to distinguish file type
label = sprintf('%s', fread(fid, 8, 'char'));

if (strcmp(label, 'HEXITECH'))   % HXT format   
    version = fread(fid, 1, 'uint64');
    if version == 3
        % read and store each piece of info in hxt file
        mssX = fread(fid, 1, 'uint32');
        mssY = fread(fid, 1, 'uint32');
        mssZ = fread(fid, 1, 'uint32');
        mssRot = fread(fid, 1, 'uint32');
        GalX = fread(fid, 1, 'uint32');
        GalY = fread(fid, 1, 'uint32');
        GalZ = fread(fid, 1, 'uint32');
        GalRot = fread(fid, 1, 'uint32');
        GalRot2 = fread(fid, 1, 'uint32');
        nCharFPreFix = fread(fid, 1, 'int32');
        filePreFix = fread(fid, nCharFPreFix, '*char');
        dummy = fread(fid,100-nCharFPreFix, '*char');
        timeStamp = fread(fid, 16, '*char');
        nRows = fread(fid, 1, 'uint32');
        nCols = fread(fid, 1, 'uint32');
        nBins = fread(fid, 1, 'uint32');
        bins = fread(fid,nBins,'double');
        d=fread(fid,nBins.*nRows.*nCols,'double');
        M=reshape(d,[nBins nCols nRows]);
        M = permute(M, [2 3 1]);
    else
        disp('Not Version 3 of HXT File - Zeros Returned');
        M = 0;
        bins = 0;
    end
    fclose(fid);
end
%plot(squeeze(M(30,30,:)));