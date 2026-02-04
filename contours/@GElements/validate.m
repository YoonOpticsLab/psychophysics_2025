function obj = validate(obj)
    
    if ~obj.validated
        fnc_name = 'GElements.validate';

        if length(obj.x) ~= length(obj.y)
            msg = 'Vectors must be of equal length';
            GERT_ShowError(fnc_name,msg,3);
        end

        if ~isempty(obj.dims) && (any(obj.x<obj.dims(1)) || any(obj.x>obj.dims(2)) ||  ...
                any(obj.y<obj.dims(3)) || any(obj.y>obj.dims(4)) )
            msg = 'Some elements fall outside the display dimensions';
            GERT_ShowError(fnc_name,msg,1);
        end

        obj.validated = true;
    end
    
end