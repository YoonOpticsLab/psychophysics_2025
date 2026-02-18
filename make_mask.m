function mask = make_mask ( width, sigma2, expo)
%% Make a super Gaussian mask for the image.
    maskRadius = width/2;
    maskSigma = maskRadius;
    % smoothing method: cosine (0), smoothstep (1), inverse smoothstep (2)
    maskMethod = 0;
    %[masktex, maskrect] = CreateProceduralSmoothedDisc(expWin,...
    %    texture_width, texture_height, [], maskRadius, maskSigma, useAlpha, maskMethod);
    X=linspace(-1,1,width);
    Y=linspace(-1,1,width);
    [XX,YY]=meshgrid(X,Y);
    RR=sqrt(XX.^2+YY.^2);
    %RR(RR>1)=1.0; % clip round edges
    mask=exp( -( (RR/2/sigma2).^expo) ) ;
    mask = mask / max(max(mask));
    %mask=RR*0+1;
end
