function N = calibrate_cow(M,warping,badMask)
% Calibrates a data set based upon a previously built calibration matrix
% (e.g. using buildCal). Also sets any bad pixels to zero.
%
% Inputs:
%      M   :  data set to be calibrated (3D)
% calMat   :  calibration matrix (nrows x ncols x 2) [linear calibration]
% badMask  :  array defining location of bad piels (2D)
% commonX  :  common x-axis for spectra (e.g. commonX = 0:0.25:99.75; % 0-100 keV)
% 
% Output:
%     N    : the calibrated data set
%
% Author: CK Egan Nov. 2011
tic
[m,n,o]=size(M);
if nargin < 3
    badMask = zeros(m,n);
end

% M=permute(M,[2 1 3]);
% pad array up to 800 channels with zeros
% if o < 800
%     padlength = 800 - o;
%     M = padarray(M,[0 0 padlength],'post');
%     o = 800;
% end

data = reshape(M,m*n,o);

Xw = cow_apply(data,warping);

N = reshape(Xw,m,n,o);

% remove NaN and inf
N(~isfinite(N))=0;

% Correct bad pixels
N = badPixcorr(N, badMask,'average');
toc