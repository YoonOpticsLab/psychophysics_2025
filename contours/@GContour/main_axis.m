function [ma, pt] = main_axis(obj)

    fnc_name = 'GContour.main_axis';

    obj = validate(obj);

    if ~obj.closed
        msg = 'To compute the main axis, the contour must be closed.';
        GERT_ShowError(fnc_name,msg,3);
    end

    [ma pt] = GERT_Aux_MainAxis(obj.x,obj.y);

end