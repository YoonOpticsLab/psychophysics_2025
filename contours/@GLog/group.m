function obj=group(obj,s)

    if ~obj.Exist;
        return;
    end
    
    if isempty(obj.Group)
        obj.Group = struct;
    end

    st = dbstack;
    if ~isscalar(st)
        callf = st(2).name;
    else
        callf = 'Other';
    end

    if ~isfield(obj.Group,callf)
        obj.Group.(callf) = false;
    end
    
    if ~obj.Group.(callf) && strcmp(s,'on')
        obj.Group.(callf) = true;
    elseif obj.Group.(callf) && strcmp(s,'off')
        obj.Group.(callf) = false;
    end
    
end