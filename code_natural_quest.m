trial_order=repmat( blur_levels_multiplier, [1, num_repeats]);
num_trials = size(trial_order,2);
trial_order=trial_order( randperm(num_trials) );

targets = dir(sprintf('%s/%s',targets_dir,filename_mask));
targets = targets;

num_images = size(targets,1);
%image_order = repmat( 1:num_images, [1 ceil(num_trials/num_images)]);
%image_order = image_order(1:num_trials);
%image_order=image_order( randperm(num_trials) );
image_order = randsample(1:num_images, num_trials,true);

% Read first one to init mask buffer etc. TODO: don't need. Can use imsize
% since they are all rescaled.
target1=targets(image_order(1));
fullname = [target1.folder '/' target1.name];
img1=imread(fullname);  
img1=imresize(img1,imsize);
img1 = im2double(im2gray(img1)); % Convert to grayscale and double % Make b&w

siz=size(img1,1)/4;

%Prepare output
colHeaders = {'trial_num', 'file','blur_sigma','correct','resp','target_category','target_file','rt'};
results=NaN * ones(length(trial_order),length(colHeaders)); %preallocate results matrix

if (visualize_psf)
    z4_um_b = -z4_baseline_D / 4 / sqrt(3) * (pupil_zernike_mm/2)^2
    psf_b=defocus_psf(psf_pixels,z4_um_b,z12_baseline_um,arcmin_per_pixel,pupil_mm,pupil_zernike_mm,pupil_real_mm,visualize_psf,psf_normalize_area);
    return;
end

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

    Screen('Preference', 'SkipSyncTests', 2)

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

    % Not using alpha channel for masking currently. Instead, direct math.
    % Screen('BlendFunction', expWin, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    % use alpha channel for smoothing edge of disc?
    %useAlpha = true;

    fliprate=Screen('GetFlipInterval', expWin); % e.g. 1/60.
    duration_flips = floor( stimulus_duration/fliprate );

    %open an (the only) onscreen Window, if you give only two input arguments
    %this will make the full screen white (=default)
    %[expWin,rect]=Screen('OpenWindow',screenNumber,128);

    %get the midpoint (mx, my) of this window, x and y
    [mx, my] = RectCenter(rect);

    %get rid of the mouse cursor, we don't have anything to click at anyway
    HideCursor;

    % Preparing and displaying the welcome screen
    % We choose a text size of 24 pixels - Well readable on most screens:
    Screen('TextSize', expWin, 48);

    q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,grain,range);
    %q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.

    display_pixels = floor( stimulus_size_deg*60 / arcmin_per_pixel );
    imsize = [display_pixels, display_pixels];
    texture_width=display_pixels;
    texture_height=display_pixels;

    mask = make_mask(texture_width,0.45,8);

    for ntrial=1:num_trials
        which_quad = floor(rand(1)*4)+1; % TODO: make counterbalanced

        %blur_delta = trial_order(ntrial);
	    tTest=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.
	    % 	tTest=QuestMean(q);		% Recommended by King-Smith et al. (1994)
	    % 	tTest=QuestMode(q);		% Recommended by Watson & Pelli (1983)
	    
        tTest=min(max(tTest, tMin), tMax); % Clamp to range

	    % We are free to test any intensity we like, not necessarily what Quest suggested.
	    % 	tTest=min(-0.05,max(-3,tTest)); % Restrict to range of log contrasts that our equipment can produce.
        z4_delta_D = 10^-tTest;
        
        which_image = image_order(ntrial);

        target1=targets(which_image);
        fullname = [target1.folder '/' target1.name];
        img1=imread(fullname);  
        img1=imresize(img1,imsize);

        img1 = im2double(im2gray(img1)); % Convert to grayscale and double % Make b&w

        if ~psf_normalize_area
            img1 = img1 - min(min(img1));
            img1 = img1 / max(max(img1));
        end

        z4_um = -(z4_delta_D + z4_baseline_D) / 4 / sqrt(3) * (pupil_zernike_mm/2)^2
        psf2=defocus_psf(psf_pixels,z4_um,z12_baseline_um,arcmin_per_pixel,pupil_mm,pupil_zernike_mm,pupil_real_mm,visualize_psf,psf_normalize_area);
        blurred = conv2(img1,psf2,'same');
        blurred = blurred - min(min(blurred));
        blurred = blurred / max(max(blurred));

        blurred = apply_mask(blurred,mask);
        blurred = blurred .^ (1/gamma_exponent);        
        blurred = blurred * 255;

        Screen('drawline',expWin,[0 0 0],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[0 0 0],mx,my-fix_size,mx,my+fix_size,2);
        Screen('Flip', expWin);

        keyIsDown=0;
        while (keyIsDown==0)
            [keyIsDown, secs_response, keyCode, deltaSecs] = KbCheck();
        end

        tex1 = Screen('MakeTexture', expWin, blurred);

        [x,y] = WindowCenter(expWin);
        display_pixels = stimulus_size_deg*60 / arcmin_per_pixel;
        texture_width=display_pixels;
        texture_height=display_pixels;

        posx=[x-texture_width/2*1.1, x+texture_width/2*1.1, x-texture_width/2*1.1, x+texture_width/2*1.1];
        posy=[y-texture_height/2*1.1, y-texture_height/2*1.1, y+texture_height/2*1.1, y+texture_height/2*1.1];

        flips_remaining=duration_flips;
        done=0;

        secs_stim_on=tic;
        if duration_flips>0
            for flip_count=1:duration_flips
                x_pos=x;
                y_pos=y;
                dstRect = [x_pos - texture_width/2, y_pos - texture_height/2, x_pos + texture_width/2, y_pos + texture_height/2]; 
                Screen('DrawTexture', expWin, tex1, [], dstRect);
                Screen('Flip', expWin);
            end
        end

        if save_image_snapshots
            imageScreen = Screen('GetImage', expWin);
            % Convert the datetime object to a st15ring using the specified format
            currentTime = datetime('now');
            dateTimeStr = string(currentTime, 'yyyy-MM-dd_HH-mm-ss');
            filname=['screenshot-' convertStringsToChars(dateTimeStr) '.png'];                
            imwrite(imageScreen,filname );
        end

        % Erase with only fixation screen
        Screen('drawline',expWin,[0 0 0],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[0 0 0],mx,my-fix_size,mx,my+fix_size,2);
        Screen('Flip', expWin);            
        while (done==0) % No response yet. Wait for key
            [keyIsDown, secs_response, keyCode, deltaSecs] = KbCheck();
            if (keyIsDown)
                done=1;
            end
        end

        rt=secs_response-secs_stim_on;

        %find out which key was pressed
        cc=KbName(keyCode);  %translate code into letter (string)

        resp=0;

        % Category will be two chars in from last slash in filename
        idxs=strfind(target1.folder,'\'); % find all slashes
        which_category = target1.folder(idxs(end)+2);

        if isempty(cc) || strcmp(cc,'ESCAPE')
            break;   %break out of trials loop, but perform all the cleanup things
        elseif strcmp( cc, which_category ) % Does it match? strcmp is opposite from C
            correct=1;
        else
            correct=0;
        end

        if correct
            colr=[0 255 0];
        else
            colr=[255 0 0];
        end

        %disp( [cc, which_category] )

        Screen('drawline',expWin,colr,mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,colr,mx,my-fix_size,mx,my+fix_size,2);        
        Screen('Flip', expWin);

        q=QuestUpdate(q,tTest,correct); % Add the new datum (actual test intensity and observer response) to the database.

        % Turn the image # into a float.  'n01820546_19716.JPEG'
        firstnum = str2num( target1.name( [2:strfind(target1.name,'_')-1]) );
        secondnum = str2num( target1.name( [strfind(target1.name,'_')+1:strfind(target1.name,'.')-1]) );
        target_num = secondnum; % Just use image # for now... Might collide based on category, but oh well, take a chance

        results(ntrial,:)=[ntrial,z4_baseline_D ,z4_delta_D+z4_baseline_D,correct,resp,which_category,target_num,rt];
        results(ntrial,2) = tTest; % Seem to nee this to get a decimal into the array (WTF!?)
    end
    
    n_unique=0;
    output_filename = sprintf('results/natural-%s_%02d.csv',output_name,n_unique);
    while isfile( output_filename)
        n_unique = n_unique + 1;
        output_filename = sprintf('results/%s_%02d.csv',output_name,n_unique);
    end

    writecell(colHeaders, output_filename );
    writematrix(results, output_filename, 'WriteMode', 'Append' );

    %clean up before exit
    KbCheck();
    KbReleaseWait(); % Remove any keys from buffer: avoid junk in window
    ShowCursor;
    sca; %or sca;
    ListenChar(0);
    KbReleaseWait(); % Remove any keys from buffer: avoid junk in window
    %return to olddebuglevel
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);

    if show_pf
        final_delta = QuestQuantile(q);
        final_D = (final_delta + z4_baseline_D);
        delta = (final_D - z4_baseline_D );
        final_report = ["Baseline defocus (D): "+num2str(z4_baseline_D), "Baseline spherical (um): "+num2str(z12_baseline_um), "Final Threshold: "+num2str(final_D) ]
        plot( results(:,3), 'o-' );
        title(final_report);
        yl = yline(final_D,'--',"Threshold="+final_D,'LineWidth',3);
        ylabel( "Defocus (D)")
        xlabel( "Trial number")
    end

catch
    % This section is executed only in case an error happens in the
    % experiment code implemented between try and catch...
    ShowCursor;
    KbReleaseWait(); % Remove any keys from buffer: avoid junk in window
    sca; %or sca
    ListenChar(0);
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);
    %output the error message
    psychrethrow(psychlasterror);
end
    
