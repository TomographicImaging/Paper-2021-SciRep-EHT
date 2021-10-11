function SS = buildSino4D_hxt(nX,nY,nP,nC,warping,badMask)
%% buildSino4D_hxt
% Construct a 4D sinogram from HEXITEC .hxt projection files
% Script reads in individual files, performs gain correction, 
% flatfield normalisation, ring-removal filtering, 
% and then stores the result in a 4D sinogram matrix.
% INPUTS:    nX,    Number of detector pixels (e.g. 80) in X direction
%            nY,    Number of detector pixels (e.g. 80) in Y direction
%            nP,    Number of projection angles acquired
%            nC,    Number of energy channels acquired
%            warping      .hxt values from calibration for gain correction
%            badMask,     .hxt mask file of dead pixels for gain correction
% OUTPUT:    SS,     4D Sinogram, with ring-removal filter applied
% Ryan Warr 25/10/20

%% -------- Create empty arrays for sinogram and flatfield  ----------
 S = zeros(nX,nP,nY,nC); % Empty array to hold 4D sinogram data
 FFF = zeros(nX,nY,nC); % Empty array to hold flatfield data

%% ----- Locate and read in warping and badMask files if not provided -----
if nargin < 5
    disp('Load in warping data');
    uiopen('*.mat');
    disp('Load in bad mask array');
    uiopen('*.mat');
end

%% ----------- Select folder in which projection subfolders lie -----------
disp('Select Project Folder');
FolderName = uigetdir('Select Project Folder');
if isequal(FolderName,0)
    disp('User pressed cancel')
    return
end

%% --------------- Access .hxt files in all subfolders --------------------
% Note: Works on MATLAB 2017/18, not on MATLAB 2014
[fileNames] = dir([FolderName '/*/*.hxt']);
% warning if the number of files is not equal to the number of scan points
if length(fileNames)~=nP
    disp('Warning: Number of projections does not equal number of files found')
    return
end
disp(size(fileNames));

%% --------------- Select Reference Images (flatfields) -------------------
disp('Select All Flatfield Files');
[fileNameFF, pathNameFF] = uigetfile('*.hxt', 'Select Flatfield Files (*.hxt)', 'MultiSelect', 'on');
if isequal(fileNameFF,0) || isequal(pathNameFF,0)
    disp('User pressed cancel')
    return
end

%% ---------------- Read in and analyse Flatfield Data --------------------
for i=1:size(fileNameFF,2)
    disp(fileNameFF(i));
    NameFF = char(fileNameFF(i));
    filePathFF = fullfile(pathNameFF, NameFF); % Create full path name
    F=hxtV3Read(filePathFF); % Convert .hxt file to 3D data array
    FF = calibrate_cow(F,warping,badMask); % Apply COW warping calibration
    FFF = FFF + FF; % Add all flatfields together
end

FFF = FFF./size(fileNameFF,2); % Divide by number of flatfields i.e. averaging

%% ----------- Read in and build Sinograms for data set ----------------------------
for i=1:size(fileNames,1)
    
    %read in individual data files
    Name = char(fileNames(i).name);
    Folder = char(fileNames(i).folder);
    filePath = fullfile(Folder,Name);
    disp(filePath);
    M=hxtV3Read(filePath);
    %M=M(:,:,1:400); % Scale down channels if required
    
    % calibrate .hxt file (N = calibrated 3D matrix)
    N = calibrate_cow(M,warping,badMask);
 
    % Divide by flatfield and build sinogram
    % Fills in each projection with binned mu*x = -log(I/I_0)
    S(:,i,:,:) = -log(N./FFF); %mu*x = -log(I/I_0)

end
% remove NaN
S(~isfinite(S))=0;

% Crop data to channels with non-zero values
S = S(:,:,:,1:200);

%% ---------------- Apply ring-removal filter to data ---------------------
SS = supressRings(S); % Apply ring-removal filter to Sinogram S

%% ---------------- Save Sinogram as .mat and h5 --------------------------
disp('Select location to save complete data');
[~,path] = uiputfile('SS_120s_180proj_Sup_noCent_ch1_200');
full_file_path = strcat(path,'SS_120s_180proj_Sup_noCent_ch1_200.h5');
h5create(full_file_path,'/SS',size(SS));
h5write(full_file_path,'/SS',SS);

disp('----------------- Program Complete! ---------------------------');