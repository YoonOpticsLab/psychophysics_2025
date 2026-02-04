function [x0,y0] = centroid(obj)
    
fnc_name = 'GContour.centroid';

    obj = validate(obj);

    if ~obj.closed
        msg = 'To compute the centroid, the contour must be closed.';
        GERT_ShowError(fnc_name,msg,3);
    end

    [x0,y0] = GERT_Aux_Centroid(obj.x,obj.y);

end