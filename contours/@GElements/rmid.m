function obj = rmid(obj)

    fnc_name = 'GElements.rmid';
    
    [xv,yv,idx] = GERT_Aux_RemoveIdenticalPoints(obj.x,obj.y);

    obj.x = xv;
    obj.y = yv;
    
    if ~isempty(obj.tags{1})
        obj.tags{1} = obj.tags{1}(idx);
        obj.tags{2} = obj.tags{2}(idx);
    end

    obj = validate(obj);
    obj.n = length(obj.x);
    
end