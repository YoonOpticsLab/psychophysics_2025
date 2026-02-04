function obj = addfield(obj,name,defval,valfnc)

if ~GERT_Aux_ValidVec(name,'char')
    msg = 'Fieldname should be a 1xN char';
    GERT_ShowError(fnc_name,msg,3);
end

if ~isa(valfnc,'function_handle')
    msg = 'Third argument should be a valid function handle';
    GERT_ShowError(fnc_name,msg,3);
end

obj.n = obj.n+1;
obj.fields{1}(obj.n) = {name};
obj.fields{2}(obj.n) = {defval};
obj.fields{3}(obj.n) = {valfnc};
