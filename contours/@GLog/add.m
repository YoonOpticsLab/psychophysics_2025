function obj = add(obj,entry_type,entry_val,entry_name)

    % A log must exist
    fnc_name = 'GLog.add';
    
    if ~obj.Exist;
        return;
    end

    % Query the calling stack
    st = dbstack;
    if ~isscalar(st)
        callf = st(2).name;
    else
        callf = 'Other';
    end
    
    if ~isfield(obj.Group,callf)
        obj.Group.(callf) = false;
    end
    
    % If a message
    if strcmp(entry_type,'msg')

        if ~isa(entry_val,'char') || size(entry_val,1) ~= 1 || ndims(entry_val) ~= 2
            msg = '''msg'' log entries must be 1xN character arrays';
            GERT_ShowError(fnc_name,msg,3);
        end

        Functions = obj.Functions;
        if ~isfield(Functions, callf)
            Functions.(callf) = cell(1,1);
            Functions.(callf){1} = struct;
            fn = 1;
        else
            if obj.Group.(callf)
                fn = length(Functions.(callf));
            else
                fn = length(Functions.(callf)) + 1;
                Functions.(callf) = [Functions.(callf) cell(1,1)];
                Functions.(callf){end} = struct;
            end
        end

        if isfield(Functions.(callf){fn},'msg')
            curn = length(Functions.(callf){fn}.msg );
        else
            Functions.(callf){fn}.msg = {};
            curn = 0;
        end

        msg = char(strcat(datestr(now,'HH:MM:SS.FFF'),{' - '},entry_val));
        Functions.(callf){fn}.msg{curn+1,1} = msg;

        obj.Functions = Functions;

        % If a variable
    elseif strcmp(entry_type,'var')

        if strcmp(entry_name,'msg')
            msg = 'Forbidden variable entry name!';
            GERT_ShowError(fnc_name,msg,3);
        end

        Functions = obj.Functions;
        if ~isfield(Functions, callf)
            Functions.(callf) = cell(1,1);
            Functions.(callf){1} = struct;
            fn = 1;
        else
            if obj.Group.(callf)
                fn = length(Functions.(callf));
            else
                fn = length(Functions.(callf)) + 1;
                Functions.(callf) = [Functions.(callf) cell(1,1)];
                Functions.(callf){end} = struct;
            end
        end

        Functions.(callf){fn}.(entry_name) = entry_val;

        obj.Functions = Functions;
        
        % If a file
    elseif strcmp(entry_type,'file')

        Files = obj.Files;
        
        %entry_name = ['f_' entry_name];
        entry_name = entry_name(regexp(entry_name, '\w'));

        Files.(entry_name) = {};
        fid=fopen(entry_val);

        if fid == -1
            msg = strcat(entry_val,' could not be found as a file.');
            GERT_ShowError(fnc_name,msg,3);
        end

        i=0;
        while 1
            tline = fgetl(fid);
            if ~ischar(tline),   break,   end
            i=i+1; Files.(entry_name)(i,1)= {tline};
        end
        fclose(fid);

        obj.Files = Files;

    else
        GERT_ShowError(fnc_name,'Invalid entry type. Use ''msg'', ''var'' or ''file''.',3);
    end

end