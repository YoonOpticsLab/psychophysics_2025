function psf=defocus_psf(m,z4,z12,arcmin_pixel_px,pupil,pupil_zernike,pupil_real,visualize_psf)

    %m=129;  arcmin_pixel_px=0.2; 
    wave=0.555;
    %pupil=wave*0.001*180/pi*60/arcmin_pixel_px; 
    %pupil_zernike=6;
    %pupil_real= 3;
    
    %z4=1;
    
    xx1=linspace(-pupil/2,pupil/2,m);   yy1=linspace(pupil/2,-pupil/2,m);
    [x1,y1] = meshgrid(xx1,yy1);    r1 = sqrt(x1.^2+ y1.^2);    r1_norm=r1./(pupil_zernike/2);
    tr=r1(:,:)<=pupil_real/2; normalize=sum(sum(tr));
    
    wf=zeros(m);
    wf=z4*sqrt(3)*(2*r1_norm.^2-1) + z12 * sqrt(5) * (6*r1_norm.^4 - 6*r1_norm.^2 + 1);

    wf=wf.*tr;
    
    pupil_ft=tr.*exp(-2i*pi/wave*wf);
    fft_pupil_ft=fftshift(fft2(pupil_ft)); 
    psf=fft_pupil_ft.*conj(fft_pupil_ft);
    psf=psf/(normalize^2);   Strehl = max(max(psf));
    
    psf_resolution=wave*0.001*180/pi*60/pupil; % in arcmin
    psf_x=linspace(-psf_resolution*m/2, psf_resolution*m/2, m);
    
    if visualize_psf
        figure(); 
        subplot(1,2,1); imagesc(xx1,yy1,wf); xlabel('Pupil radius_x (mm)'); ylabel('Pupil radius_y (mm)'); axis image; colorbar('vert'); title('defocus map');
        subplot(1,2,2); imagesc(psf_x,psf_x,psf); xlabel('PSF radius_x (armins)'); ylabel('PSF radius_y (arcmins)'); axis image; colorbar('vert'); title('PSF');
    end
end