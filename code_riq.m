trial_order=repmat( 1:size(pairs,2), [1, num_repeats]);
order_order=repmat( 1:num_repeats, [1, size(pairs,2)]);
num_trials = size(trial_order,2);
% Randomize order:
trial_order=trial_order( randperm(num_trials) );
order_order=order_order( randperm(num_trials) );

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
colHeaders = {'trial_num', 'which_image','x1','x2','metric','resp','shift','rt'};
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
    duration_flips_noise = floor( noise_duration/fliprate );

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

    for ntrial=1:num_trials
        which_quad = floor(rand(1)*4)+1; % TODO: make counterbalanced
        blur_multiplier = trial_order(ntrial);

        which_pair = trial_order(ntrial);
        which_order = order_order(ntrial); 
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

        pair1=pairs(:,which_pair);
        if which_order==1
            z4_baseline_D1 = pair1.x_left;
            z4_baseline_D2 = pair1.x_right;
        else
            z4_baseline_D2 = pair1.x_left;
            z4_baseline_D1 = pair1.x_right;
        end

        z4_delta_D = 0;

        % #1
        z4_um = -(z4_delta_D + z4_baseline_D1) / 4 / sqrt(3) * (pupil_zernike_mm/2)^2
        psf1=defocus_psf(psf_pixels,z4_um,z12_baseline_um,arcmin_per_pixel,pupil_mm,pupil_zernike_mm,pupil_real_mm,visualize_psf,psf_normalize_area);
        blurred1 = conv2(img1,psf1,'same');
        blurred1 = blurred1 - min(min(blurred1));
        blurred1 = blurred1 / max(max(blurred1));
        % #2
        z4_um = -(z4_delta_D + z4_baseline_D2) / 4 / sqrt(3) * (pupil_zernike_mm/2)^2
        psf2=defocus_psf(psf_pixels,z4_um,z12_baseline_um,arcmin_per_pixel,pupil_mm,pupil_zernike_mm,pupil_real_mm,visualize_psf,psf_normalize_area);
        blurred2 = conv2(img1,psf2,'same');
        blurred2 = blurred2 - min(min(blurred2));
        blurred2 = blurred2 / max(max(blurred2));

        Screen('drawline',expWin,[0 0 0],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[0 0 0],mx,my-fix_size,mx,my+fix_size,2);
    
        % Draw 'myText', centered in the display window:
        %DrawFormattedText(expWin, 'Press a key to start', mx, my+50);
        Screen('Flip', expWin);
        KbWait([], 2); %wait for keystroke
    
        tex1 = Screen('MakeTexture', expWin, blurred1*255);
        tex2 = Screen('MakeTexture', expWin, blurred2*255);
    
        noise_pix1=generate_2d_pink_noise(512,512,2);
        noise1=Screen('MakeTexture', expWin, noise_pix1*255);
        noise_pix2=generate_2d_pink_noise(512,512,2);
        noise2=Screen('MakeTexture', expWin, noise_pix2*255);

        [x,y] = WindowCenter(expWin);
        %display_pixels = stimulus_size_deg*60 / arcmin_per_pixel;
		display_pixels = imsize(1);
        texture_width=display_pixels;
        texture_height=display_pixels;

        posx=[x-texture_width/2*1.1, x+texture_width/2*1.1, x-texture_width/2*1.1, x+texture_width/2*1.1];
        posy=[y-texture_height/2*1.1, y-texture_height/2*1.1, y+texture_height/2*1.1, y+texture_height/2*1.1];

        if duration_flips>0
            for flip_count=1:duration_flips
                x_pos=x;
                y_pos=y;
                dstRect = [x_pos - texture_width/2, y_pos - texture_height/2, x_pos + texture_width/2, y_pos + texture_height/2]; 
                Screen('DrawTexture', expWin, tex1, [], dstRect);
                Screen('Flip', expWin);
            end
        end
        if duration_flips_noise>0
            for flip_count=1:duration_flips_noise
                x_pos=x;
                y_pos=y;
                dstRect = [x_pos - texture_width/2, y_pos - texture_height/2, x_pos + texture_width/2, y_pos + texture_height/2]; 
                Screen('DrawTexture', expWin, noise1, [], dstRect);
                Screen('Flip', expWin);
            end
        end

        if duration_flips>0
            for flip_count=1:duration_flips
                x_pos=x;
                y_pos=y;
                dstRect = [x_pos - texture_width/2, y_pos - texture_height/2, x_pos + texture_width/2, y_pos + texture_height/2]; 
                Screen('DrawTexture', expWin, tex2, [], dstRect);
                Screen('Flip', expWin);
            end
        end
        if duration_flips_noise>0
            for flip_count=1:duration_flips_noise
                x_pos=x;
                y_pos=y;
                dstRect = [x_pos - texture_width/2, y_pos - texture_height/2, x_pos + texture_width/2, y_pos + texture_height/2]; 
                Screen('DrawTexture', expWin, noise2, [], dstRect);
                Screen('Flip', expWin);
            end
        end                    

        tic;
        Screen('drawline',expWin,[0 0 255],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[0 0 255],mx,my-fix_size,mx,my+fix_size,2);
        Screen('Flip', expWin);

        valid_resp=0;
        keyIsDown=0;
        shift_down=0;

        while valid_resp==0
            while (keyIsDown==0)
                [keyIsDown, secs_response, keyCode, deltaSecs] = KbCheck();
            end
            keyIsDown=0; % ready for next time (if needed)

            %find out which key was pressed
            cc=KbName(keyCode)  %translate code into letter (string)
    
            if size(cc,2)>1
                cc=cc(1);
            end

            if isempty(cc) || strcmp(cc,'ESCAPE')
                valid_resp=1;
                break;   %break out of trials loop, but perform all the cleanup things
            elseif strcmp(cc,'1') || strcmp(cc,'q')
                resp = 1;
                valid_resp=1;
                break;
            elseif strcmp(cc,'2') || strcmp(cc,'e')
                resp = 2;
                valid_resp=1;
                break;
            elseif strcmp(cc,'1!') || strcmp(cc,'q')
                resp = 1;
                valid_resp=1;
                shift_down=1;
                break;
            elseif strcmp(cc,'2@') || strcmp(cc,'e')
                resp = 2;
                valid_resp=1;
                shift_down=1;
                break;                
            elseif keyCode(KbName('LeftShift')) || keyCode(KbName('RightShift'))                
                shift_down=1;
            end
        end
        rt=toc;

        %{'trial_num', 'which_image','x1','x2','metric','resp','shift','rt'};
        results(ntrial,:)=[ntrial,which_image,z4_baseline_D1,z4_baseline_D2,pair1.y_value,resp,shift_down,rt];
        results(ntrial,:)
    end
    
    n_unique=0;
    output_filename = sprintf('results/riq-%s_%02d.csv',output_name,n_unique);
    while isfile( output_filename)
        n_unique = n_unique + 1;
        output_filename = sprintf('results/riq-%s_%02d.csv',output_name,n_unique);
    end

    writecell(colHeaders, output_filename );
    writematrix(results, output_filename, 'WriteMode', 'Append' );

    %clean up before exit
    ShowCursor;
    sca; %or sca;
    ListenChar(0);
    %return to olddebuglevel
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);

    if show_pf
        variable=blur_levels_multiplier*blur_baseline_D;
        averages = zeros( [1 size(variable,2)]);
        for n=1:size(averages,2)
            % Sum the correct column of the results for each level
            averages(n) = mean( results( results(:,3)==variable(n), 4) );
        end
    
        figure();
        plot( variable, averages, 'o-');
    end

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
  

