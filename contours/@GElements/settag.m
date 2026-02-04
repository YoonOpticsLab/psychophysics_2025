function obj = settag(obj,tag,idx)

    fnc_name = 'GElements.settag';

    obj = validate(obj);
        
    if nargin ~=3 && nargin ~= 2
        msg = 'One or two input arguments needed';
        GERT_ShowError(fnc_name,msg,3);
    end

    if nargin == 2
        idx = 1:obj.n;
    end

    if ~isa(idx,'double') || size(idx,1) ~= 1 || size(idx,2) < 1 ...
            || ndims(idx) > 2 || any(~isfinite(idx)) || any(imag(idx)) ...
            || any(idx<1) || any(mod(idx,1))
        msg = 'Indices must be real-valued, finite, positive integers in a 1xN double vector';
        GERT_ShowError(fnc_name,msg,3);
    end

    if max(idx) > obj.n
        msg = 'Tag index exceeds the number of elements';
        GERT_ShowError(fnc_name,msg,3);
    end

    tags = obj.tags;

    if isscalar(tag) && isa(tag,'char')

        if ~ismember(tag,'abcdefghijklmnopqrstuvwxyz')
            msg = 'Scalar tags must be a letter';
            GERT_ShowError(fnc_name,msg,3);
        end

        if any(idx>obj.n)
            msg = 'Some indices exceed the number of elements';
            GERT_ShowError(fnc_name,msg,1);
        end

        maxn = max(tags{2}(tags{1} == tag));
        nextn = min(setdiff(1:maxn,tags{2}));

        if isempty(maxn)
            maxn = 0;
        end

        if isempty(nextn)
            nextn = maxn+1;
        end

        tags{1}(idx) = tag;
        tags{2}(idx) = nextn;

    elseif ndims(tag) == 2 && size(tag,1) == 1 && isa(tag,'char')

        if ~ismember(tag(1),'abcdefghijklmnopqrstuvwxyz')
            msg = 'First tag character must be a small caps letter';
            GERT_ShowError(fnc_name,msg,3);
        end

        if any(~ismember(tag(2:end),'0123456789'))
            msg = 'Second and next tag characters must be a number 0-9';
            GERT_ShowError(fnc_name,msg,3);
        end

        tags{1}(idx) = tag(1);
        tags{2}(idx) = str2double(tag(2:end));

    else
        msg = 'Element tag must be a 1xN char';
        GERT_ShowError(fnc_name,msg,3);
    end

    obj.tags = tags;

end