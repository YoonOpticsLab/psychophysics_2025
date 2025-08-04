trial_order=repmat( text_sizes, [1, num_repeats]);
num_trials = size(trial_order,2);
trial_order=trial_order( randperm(num_trials) );

%Prepare output
colHeaders = {'trial_num', 'string','size','correct','number','resp','rt'};
results=NaN * ones(length(trial_order),length(colHeaders)); %preallocate results matrix

try
    % Enable unified mode of KbName, so KbName accepts identical key names on
    % all operating systems (not absolutely necessary, but good practice):
    KbName('UnifyKeyNames');

    %funnily enough, the very first call to KbCheck takes itself some
    %time - after this it is in the cache and very fast
    %to make absolutely sure, we thus call it here once for no other
    %reason than to get it cached. This btw. is true for all major
    %functions in Matlab, so calling each of them once before entering the
    %trial loop will make sure that the 1st trial goes smooth wrt. timing.
    KbCheck;

    %disable output of keypresses to Matlab. !!!use with care!!!!!!
    %if the program gets stuck you might end up with a dead keyboard
    %if this happens, press CTRL-C to reenable keyboard handling -- it is
    %the only key still recognized.
    ListenChar(2);

    Screen('Preference', 'SkipSyncTests', 1)

    %Set higher DebugLevel, so that you don't get all kinds of messages flashed
    %at you each time you start the experiment:
    olddebuglevel=Screen('Preference', 'VisualDebuglevel', 10);

    %Choosing the display with the highest display number is
    %a best guess about where you want the stimulus displayed.
    %usually there will be only one screen with id = 0, unless you use a
    %multi-display setup:
    screens=Screen('Screens');
    screenNumber=max(screens);

    if fullScreen
        [expWin,rect] = Screen('OpenWindow', screenNumber, background);
    else
        [expWin,rect] = Screen('OpenWindow', screenNumber, background, partialRect);
    end

    fliprate=Screen('GetFlipInterval', expWin); % e.g. 1/60.
    duration_flips = floor( stimulus_duration/fliprate );

    %open an (the only) onscreen Window, if you give only two input arguments
    %this will make the full screen white (=default)
    %[expWin,rect]=Screen('OpenWindow',screenNumber,128);

    [mx, my] = RectCenter(rect);

    %get rid of the mouse cursor, we don't have anything to click at anyway
    HideCursor;

    for ntrial=1:num_trials
        which_size = trial_order(ntrial);
        randstr_len1 = randi(randstr_lengths);
        randstr=[];
        for n=1:randstr_len1
            if use_uppercase
                random_ascii_value = randi([65, 65+26-1]);
            else
                random_ascii_value = randi([97, 97+26-1]);
            end
            randstr=[randstr char(random_ascii_value)];
        end
        if skip_outermost
            randloc=randi([2 randstr_len1-1]);
        else
            randloc=randi([1 randstr_len1]);
        end
        % NO ZEROS
        rand_num=randi([49 49+9-1]);
        randstr(randloc)=char(rand_num);

        Screen('drawline',expWin,[0 0 0],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[0 0 0],mx,my-fix_size,mx,my+fix_size,2);
    
        % Draw 'myText', centered in the display window:
        %DrawFormattedText(expWin, 'Press a key to start', mx, my+50);
        Screen('Flip', expWin);
        KbWait([], 2); %wait for keystroke
    
        if draw_mask
            if use_uppercase
                masktext=repmat('X',[1 randstr_len1] );
            else
                masktext=repmat('x',[1 randstr_len1] );
            end
        end
    
        Screen('TextSize', expWin, which_size);
% Now horizontally and vertically centered:
        [nx, ny, bbox] = DrawFormattedText(expWin, randstr, 'center', 'center', background);

        % First one will be from DrawFT
        for flip_count=2:duration_flips
            Screen('Flip', expWin);
            Screen('DrawText', expWin, randstr, bbox(1), bbox(2), text_color);
            %DrawFormattedText(expWin,randstr,'center','center',text_color);
        end
        
        if draw_mask            
            for flip_count=1:duration_flips 
                Screen('DrawText', expWin, masktext, bbox(1), bbox(2), text_color);
                %DrawFormattedText(expWin,masktext,'center','center',text_color);
                Screen('Flip', expWin);
            end
        end
    
        Screen('drawline',expWin,[0 0 0],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[0 0 0],mx,my-fix_size,mx,my+fix_size,2);
        
        Screen('Flip', expWin);

        tic;
        [resptime, keyCode] = KbWait;
        rt=toc;

        %find out which key was pressed
        cc=KbName(keyCode);  %translate code into letter (string)

        resp=0;
        if isempty(cc) || strcmp(cc,'ESCAPE')
            break;   %break out of trials loop, but perform all the cleanup things
        else
            resp=cc;
        end

        correct=(resp==char(rand_num))*1;

        %results(ntrial,:)=[ntrial,randstr,text_size,correct,char(rand_num),resp,rt];
        results(ntrial,:)=[ntrial,0,which_size,correct,char(rand_num),resp,rt];
        results(ntrial,:)
    end

    n_unique=0;
    output_filename=[output_name '.csv'];
    while isfile( output_filename)
        n_unique = n_unique + 1;
        output_filename = sprintf('%s_%02d.csv',output_name,n_unique);
    end

    writecell(colHeaders, output_filename );
    writematrix(results, output_filename, 'WriteMode', 'Append' );

    %clean up before exit
    ShowCursor;
    sca; %or sca;
    ListenChar(0);
    %return to olddebuglevel
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);

    averages = zeros( [1 size(text_sizes,2)]);
    for n=1:size(averages,2)
        % Sum the correct column of the results for each level
        averages(n) = mean( results( results(:,3)==text_sizes(n), 4) );
    end

    figure();
    plot( text_sizes, averages, 'o-');

catch
    % This section is executed only in case an error happens in the
    % experiment code implemented between try and catch...
    ShowCursor;
    sca; %or sca
    ListenChar(0);
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);
    %output the error message
    psychrethrow(psychlasterror);
end
    
