function obj=start(obj)

    % Do not continue if a log already exists
    if obj.Exist
        GERT_ShowError('obj.start','A log already exists! Skipping creation of new log.',1);
        return
    end

    % Clear to be sure
    stop(obj);
    global GERT_matlv;
    
    % General info
    Info = obj.Info;
    Info.Date = datestr(now);
    if strcmp(GERT_matlv{1},'Octave')
        un = uname();
        Info.OS_Version = [un.sysname ' ' un.release ' ' un.version ' ' un.machine];
    else
        Info.OS_Version = [system_dependent('getos'),' ',system_dependent('getwinsys')];
    end
    Info.Matlab_Version = [GERT_matlv{1} ' ' num2str(GERT_matlv{2}) '.' num2str(GERT_matlv{3})];
    Info.GERT_Version = GERT_Version;
    if ispc()
        Info.Computer_ID = strcat(getenv('username'), {' on '},getenv('computername'),{' @ '},getenv('userdomain'));
        Info.Computer_ID = Info.Computer_ID{1};
        Info.Processor = getenv('processor_identifier');
    elseif isunix()
        [foo,computername] = system('hostname');
        [foo,domainname] = system('domainname');
        Info.Computer_ID = strcat(getenv('USER'), {' on '},deblank(computername),{' @ '},deblank(domainname));
        Info.Computer_ID = Info.Computer_ID{1};
        [foo,cpuinfo] = system('cat /proc/cpuinfo | grep "model name" | head -n 1 | cut -d ":" -f2');
        Info.Processor = deblank(cpuinfo);
    end
    Info.Stack = dbstack();
    obj.Info = Info;

    % Variables & Messages (per function, chronological)
    Functions = [];
    obj.Functions = Functions;

    % Files
    Files = [];
    obj.Files = Files;
    
    % Mark the  creation of the log
    obj.Exist = true;
    
    if ~isscalar(Info.Stack)
        obj = add(obj,'file',Info.Stack(2).file,Info.Stack(2).name);
    end


end