function s = fetch(obj)

    if ~obj.Exist
        GERT_ShowError('GLog.fetch','No log exists yet, use GLog.create to create it.',3);
    end
    
    s = struct;
    s.Functions = obj.Functions;
    s.Files = obj.Files;
    s.Info = obj.Info;
    
end