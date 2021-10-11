function N = badPixcorr(M,badMask,method)

% interpolates over neighboring pixels to correct for bad pixels
%
% inputs:   M          -     3D data set to correct
%           badMask    -     2D array showing bad pixels  (Bad pixels = 1)
% ouputs:   N          -     corrected data set (3D)
%
% Author: CK Egan Nov. 2011

[n,m,o]=size(M);
N=M;
comp=zeros(8,o);

if nargin < 3
    method = 'average';
end

for i=1:n
    for j=1:m   % loop over pixels
        
        switch method
            case 'average'
                
                if (badMask(i,j) == 1)  % for every bad pixel
                    
                    count=0;
                    
                    if (i-1~=0) && (j-1~=0)
                        comp(1,:) = squeeze(M(i-1,j-1,:));
                        if (sum(comp(1,:),2)~=0)
                            count=count+1;
                        end
                    end
                    
                    if (i-1~=0)
                        comp(2,:) = squeeze(M(i-1,j,:));
                        if (sum(comp(2,:),2)~=0)
                            count=count+1;
                        end
                    end
                    
                    if (i-1~=0) && (j+1~=m+1)
                        comp(3,:) = squeeze(M(i-1,j+1,:));
                        if (sum(comp(3,:),2)~=0)
                            count=count+1;
                        end
                    end
                    
                    if (j+1~=m+1)
                        comp(4,:) = squeeze(M(i,j+1,:));
                        if (sum(comp(4,:),2)~=0)
                            count=count+1;
                        end
                    end
                    
                    if (i+1~=n+1) && (j+1~=m+1)
                        comp(5,:) = squeeze(M(i+1,j+1,:));
                        if (sum(comp(5,:),2)~=0)
                            count=count+1;
                        end
                    end
                    
                    if (i+1~=n+1)
                        comp(6,:) = squeeze(M(i+1,j,:));
                        if (sum(comp(6,:),2)~=0)
                            count=count+1;
                        end
                    end
                    
                    if (i+1~=n+1) && (j-1~=0)
                        comp(7,:) = squeeze(M(i+1,j-1,:));
                        if (sum(comp(7,:),2)~=0)
                            count=count+1;
                        end
                    end
                    
                    if (j-1~=0)
                        comp(8,:) = squeeze(M(i,j-1,:));
                        if (sum(comp(8,:),2)~=0)
                            count=count+1;
                        end
                    end
                    
                    meanSurround = sum(comp,1)./count;
                    
                    N(i,j,:) = meanSurround;
                end
                
            case 'zero'
                if (badMask(i,j) == 1)  % for every bad pixel
                    N(i,j,:) = zeros(o,1);
                end
        end
    end
end


% N(~isfinite(N))=M(~isfinite(N));
% N(N==0)=M(N==0);