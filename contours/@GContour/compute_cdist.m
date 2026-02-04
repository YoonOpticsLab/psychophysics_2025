function obj = compute_cdist(obj)

    fnc_name = 'GContour.compute_cdist';

    obj = validate(obj);

    if obj.n < 2
        msg = 'Too few contour points available to determine distances';
        GERT_ShowError(fnc_name,msg,3);
    end

    if obj.closed
        cdx = [obj.x obj.x(1)];
        cdy = [obj.y obj.y(1)];
    else
        cdx = obj.x;
        cdy = obj.y;
    end

    dists = sqrt(diff(cdx).^2 + diff(cdy).^2);
    obj.cdist = [0 cumsum(dists)];
    obj.clength = obj.cdist(end);

end