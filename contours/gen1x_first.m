function C = gen1x_first(fname)
    C = GERT_GenerateContour_FileSVG(fname);
    C = compute_cdist(C);
    C = compute_lt(C);

    xjit=randi(20)-10;
    yjit=randi(20)-10;
    xloc = 255 + xjit;
    yloc = 255 + yjit;
    C = GERT_Transform_Center(C,[xloc yloc],'Centroid'); % TODO
end