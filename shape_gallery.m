%targets = dir(sprintf('%s/%s',targets_dir,filename_mask));
targets = dir('./contours/shapes/*/*.svg');
targets = targets;

lastdir="";
subnum=1;
figure()
for nshape=1:size(targets,1)
    disp(num2str(nshape));
    subplot(3,5,subnum);
    fullname = [targets(nshape).folder '/' targets(nshape).name]
    im1=gen1x(fullname,1.5,1.9,1);
    imshow(im1);

    axis('off');
    if subnum==1
        ylabel('A nimals')
    elseif subnum==6
        ylabel('F ruits and vegs')
    elseif subnum==11
        ylabel('M anmade')
    end

    subnum = subnum + 1;
    if subnum==5
        subnum=6;
    end;

end
