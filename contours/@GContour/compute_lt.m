function obj = compute_lt(obj)

    fnc_name = 'GContour.compute_lt';

    obj = validate(obj);

    if obj.n < 2
        msg = 'Too few contour points available to determine tangents';
        GERT_ShowError(fnc_name,msg,3);
    end

    cdx = obj.x;
    cdy = obj.y;

    xshp = circshift(cdx,[0 1]);
    yshp = circshift(cdy,[0 1]);
    xshn = circshift(cdx,[0 -1]);
    yshn = circshift(cdy,[0 -1]);

    t = (pi/2) + atan2(xshp-xshn,yshp-yshn) ;

    if ~obj.closed
        t(1) = t(2);
        t(end) = t(end-1);
    end

    t_diff = diff(t);
    s = sign(t_diff);
    t_diff = abs(t_diff);
    idx = find(t_diff>(pi/2));

    for i = 1:length(idx)
        t(idx(i)+1:end) = t(idx(i)+1:end) - (s(idx(i))*(round(t_diff(idx(i))/pi)*pi));
    end

    obj.lt = t;

end