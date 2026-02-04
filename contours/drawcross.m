function IMG = drawcross(params)

IMG = ones((params.size*2)+1,(params.size*2)+1) * params.bg_lum;

horl = 1 + round(params.ver_cross * (params.size*2) );
verl = 1 + round(params.hor_cross * (params.size*2) );

IMG(horl,:) = params.fg_lum;
IMG(:,verl) = params.fg_lum;