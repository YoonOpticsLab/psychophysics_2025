function obj = parse(obj,s)

fnc_name = 'GStructParser.parse';

if ~isstruct(s) || ~isscalar(s)
    msg = 'Input argument to should be a 1x1 structure';
    GERT_ShowError(fnc_name,msg,3);
end

fnames = fieldnames(s);

for i = 1:obj.n
    
    fpresent = isfield(s,obj.fields{1}{i});
    fname = obj.fields{1}(i);
    fname = fname{1};
    fdef = obj.fields{2}(i);
    fdef = fdef{1};
    fval = obj.fields{3}(i);
    fval = fval{1};
    
    if fpresent
        val = s.(fname);
    else
        val = fdef;
    end
    
    if ~fpresent && isa(fdef,'char') && strcmp(fdef,'req')
        msg = char(strcat({'Input structure field is required: '},{fname}));
        GERT_ShowError(fnc_name,msg,3);
    end
    
    if ~fpresent && isa(fdef,'char') && strcmp(fdef,'creq')
        % Continue
    elseif ~fval(val)
        msg = char(strcat({'Input structure field failed validation: '},{fname}));
        GERT_ShowError(fnc_name,msg,3);
    end
    
    obj.results.(fname) = val;
    
end

extra_fields = setdiff(fnames,obj.fields{1});

if ~isempty(extra_fields)
    ef_str = '';
    for j = 1:length(extra_fields)
        ef_str = [ef_str ' ' char(extra_fields(j))];
    end
    msg = char(strcat({'Unknown fields were supplied: '},{ef_str}));
    GERT_ShowError(fnc_name,msg,3);
end