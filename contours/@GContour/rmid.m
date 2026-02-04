function obj = rmid(obj)

    fnc_name = 'GContour.rmid';
    
    [xv,yv,idx] = GERT_Aux_RemoveIdenticalPoints(obj.x,obj.y);

    obj.x = xv;
    obj.y = yv;

    if ~isempty(obj.cdist)
        if length(obj.cdist) ~= obj.n
            msg = 'Length of GContour.cdist does not correspond to the number of elements';
            GERT_ShowError(fnc_name,msg,3);
        end

        obj.cdist = obj.cdist(idx);
    end

    if ~isempty(obj.lt)
        if length(obj.lt) ~= obj.n
            msg = 'Length of GContour.lt does not correspond to the number of elements';
            GERT_ShowError(fnc_name,msg,3);
        end

        obj.lt = obj.lt(idx);
    end

    obj = validate(obj);
    obj.n = length(obj.x);
    
end