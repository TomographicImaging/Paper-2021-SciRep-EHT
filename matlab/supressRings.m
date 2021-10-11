function SS = supressRings(S)
% suppress CT ring artefacts in spectral sinogram by a combined wavelet & FFT filtering method
% Copied from this paper:
%
% Münch, Beat, et al. "Stripe and ring artifact removal with combined wavelet—Fourier filtering." 
% Optics express 17.10 (2009): 8567-8591.

[m,n,o,e] = size(S);
SS=S;

figure;
imagesc(squeeze(S(40,:,:,120)))
title('Before ring reduction')

tic
for i=1:m
    for j=1:e

I = squeeze(S(i,:,:,j));

J = xRemoveStripesVertical(I,4,'db25',1.5);

SS(i,:,:,j) = J;

    end
    disp(num2str(i))
end
toc

figure;
imagesc(squeeze(SS(40,:,:,120)))
title('After ring reduction')