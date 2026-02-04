function idx = gettag(obj,tag)

    fnc_name = 'GElements.gettag';

    if nargin ~=2
        msg = 'One input argument needed';
        GERT_ShowError(fnc_name,msg,3);
    end

    obj = validate(obj);

    if isscalar(tag) && isa(tag,'char')

        if ~ismember(tag,'abcdefghijklmnopqrstuvwxyz')
            msg = 'Scalar tags must be small caps letter';
            GERT_ShowError(fnc_name,msg,3);
        end

        idx = find(obj.tags{1}==tag);

    elseif ndims(tag) == 2 && size(tag,1) == 1 && isa(tag,'char')

        if ~ismember(tag(1),'abcdefghijklmnopqrstuvwxyz')
            msg = 'First tag character must be a small caps letter';
            GERT_ShowError(fnc_name,msg,3);
        end

        if any(~ismember(tag(2:end),'0123456789'))
            msg = 'Second and next tag characters must be a number 0-9';
            GERT_ShowError(fnc_name,msg,3);
        end

        idx = intersect(find(obj.tags{1}==tag(1)), find(obj.tags{2}==str2double(tag(2:end))));

    else
        msg = 'Element tag must be a 1xN char';
        GERT_ShowError(fnc_name,msg,3);
    end

end