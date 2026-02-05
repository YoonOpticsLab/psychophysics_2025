if (~exist('gen1x.m'))
    disp('Adding contours/ to path..')
    addpath('contours/');
end
load("precomputed_shapes.mat");

trial_order=repmat( blur_levels_multiplier, [1, num_repeats]);
num_trials = size(trial_order,2);
trial_order=trial_order( randperm(num_trials) );

%targets = dir(sprintf('%s/%s',targets_dir,filename_mask));
targets = dir('./contours/shapes/*/*.svg');
targets = targets;

num_images = size(targets,1);
%image_order = repmat( 1:num_images, [1 ceil(num_trials/num_images)]);
%image_order = image_order(1:num_trials);
%image_order=image_order( randperm(num_trials) );
image_order = randsample(1:num_images, num_trials,true);

% Read first one to init mask buffer etc. TODO: don't need. Can use imsize
% since they are all rescaled.
%target1=targets(image_order(1));
%fullname = [target1.folder '/' target1.name];
%img1=imread(fullname);  
img1=zeros(imsize);
img1 = im2double(im2gray(img1)); % Convert to grayscale and double % Make b&w

siz=size(img1,1)/4;

%Prepare output
colHeaders = {'trial_num', 'file','blur_sigma','correct','target_quad','resp','rt'};
results=NaN * ones(length(trial_order),length(colHeaders)); %preallocate results matrix

if (visualize_psf)
    z4_um_b = -z4_baseline_D / 4 / sqrt(3) * (pupil_zernike_mm/2)^2
    psf_b=defocus_psf(psf_pixels,z4_um,z12_baseline_um,arcmin_per_pixel,pupil_mm,pupil_zernike_mm,pupil_real_mm,visualize_psf,psf_normalize_area);
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

    display_pixels = stimulus_size_deg*60 / arcmin_per_pixel;
	%display_pixels = imsize(1);
    texture_width=display_pixels;
    texture_height=display_pixels;

    %% Make a circular Gaussian mask for the image.
    %mask parameters
    maskRadius = texture_width/2;
    maskSigma = maskRadius;
    % smoothing method: cosine (0), smoothstep (1), inverse smoothstep (2)
    maskMethod = 0;
    %[masktex, maskrect] = CreateProceduralSmoothedDisc(expWin,...
    %    texture_width, texture_height, [], maskRadius, maskSigma, useAlpha, maskMethod);
    X=linspace(-1,1,texture_width);
    Y=linspace(-1,1,texture_width);
    [XX,YY]=meshgrid(X,Y);
    RR=sqrt(XX.^2+YY.^2);
    RR(RR>1)=1.0; % clip round edges
    RR = 1 - RR; % invert
    %mask=RR / max(max(RR)); 
    mask= RR .* 0 + 1;
%%
    for ntrial=1:num_trials
        which_quad = floor(rand(1)*4)+1; % TODO: make counterbalanced

        %blur_delta = trial_order(ntrial);
	    tTest=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.
	    % 	tTest=QuestMean(q);		% Recommended by King-Smith et al. (1994)
	    % 	tTest=QuestMode(q);		% Recommended by Watson & Pelli (1983)
	    
        tTest=min(max(tTest, tMin), tMax); % Clamp to range       z4_delta_D = tTest;
        z12_quest = tMax-tTest;
        
        which_image = image_order(ntrial);
        target1=targets(which_image);
        fullname = [target1.folder '/' target1.name];
        if contains(fullname, 'animal')
            target_class = 1;
            alternate_classes = [2,3];
        elseif contains( fullname, 'fruit')
            target_class = 2;
            alternate_classes = [1,3];
        else
            target_class = 3;
            alternate_classes = [2,3];
        end

        %img1=imread(fullname);
        tic;
        img1=gen1x_second(precomputed_shape{which_image},tTest_spac,clutter_spac,1);        
        duration_gen = toc;
        time_max = 0.75;
        % To make sure that time isn't giving a cue, pause
        % so they are all about time_max sec.
        if (duration_gen < time_max)
            pause ( time_max - duration_gen);
        end
        img1=imresize(img1,imsize);

        % Target
        %z4_um = -(z4_delta_D + z4_baseline_D) / 4 / sqrt(3) * (pupil_zernike_mm/2)^2;
        z4_um = 3 * z12_quest;
        psf=defocus_psf(psf_pixels,z4_um,z12_quest,arcmin_per_pixel,pupil_mm,pupil_zernike_mm,pupil_real_mm,visualize_psf,psf_normalize_area);
        blurred = conv2(img1,psf,'same');
      
        % max( blurred(:)), min( blurred(:)), mean(blurred(:)), mean( img1(:) )

        blurred_b = blurred;

        blurred = blurred .^ (1/gamma_exponent);
        blurred_b = blurred_b .^ (1/gamma_exponent);

        % Make suitable for 8bit:
        blurred = blurred * 255;
        blurred_b = blurred_b * 255;
        
        %summed = (img1.*(1-mask_entire) + blurred .* (mask_entire) ) / 2.0;

        % "ready" fixation:
        Screen('drawline',expWin,[0 0 0],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[0 0 0],mx,my-fix_size,mx,my+fix_size,2);
        Screen('Flip', expWin);
        %KbWait([], 2); %wait for keystroke
        keyIsDown=0;
        while (keyIsDown==0)
            [keyIsDown, secs_response, keyCode, deltaSecs] = KbCheck();
        end

        imageTextureT = Screen('MakeTexture', expWin, blurred);
        imageTexture  = Screen('MakeTexture', expWin, blurred_b);
    
        %save("blutted", 'blurred');

        [x,y] = WindowCenter(expWin);
        display_pixels = stimulus_size_deg*60 / arcmin_per_pixel;
		%display_pixels = imsize(1);
        texture_width=display_pixels;
        texture_height=display_pixels;

        % Center of the window
        %posx=[x-texture_width/2*1.1, x+texture_width/2*1.1, x-texture_width/2*1.1, x+texture_width/2*1.1];
        %posy=[y-texture_height/2*1.1, y-texture_height/2*1.1, y+texture_height/2*1.1, y+texture_height/2*1.1];
        %posx=[x-texture_width/2*1.1, x+texture_width/2*1.1, x-texture_width/2*1.1, x+texture_width/2*1.1];
        %posy=[y-texture_height/2*1.1, y-texture_height/2*1.1, y+texture_height/2*1.1, y+texture_height/2*1.1];
        posx = [x,x,x,x];
        posy = [y,y,y,y];

        flips_remaining=duration_flips;
        done=0;
        if duration_flips>0
             KbReleaseWait(); % Clear buffer
             % Just to get the correct time for secs_stim_on:
            [keyIsDown, secs_stim_on, keyCode, deltaSecs] = KbCheck();
            while ( (flips_remaining>0) && (done==0) )
                for nquad=1:1
                    if nquad==which_quad
                        tex1=imageTextureT;
                    else
                        tex1=imageTexture;
                    end
                    x_pos=posx(nquad);
                    y_pos=posy(nquad);
                    dstRect = [x_pos - texture_width/2, y_pos - texture_height/2, x_pos + texture_width/2, y_pos + texture_height/2]; 
                    Screen('DrawTexture', expWin, tex1, [], dstRect);
                    %Screen('DrawTextures', expWin, masktex, [], dstRect, [], [], 1, [0, 0, 0, 1]', [], []);                    
                end

                [keyIsDown, secs_response, keyCode, deltaSecs] = KbCheck();
                if (keyIsDown)
                    done=1;
                end

                %Screen('drawline',expWin,[0 0 0],mx-fix_size,my,mx+fix_size,my,2);
                %Screen('drawline',expWin,[0 0 0],mx,my-fix_size,mx,my+fix_size,2);
                Screen('Flip', expWin);

                flips_remaining = flips_remaining - 1;
            end % while
        else
            for nquad=1:4
                if nquad==which_quad
                    tex1=imageTextureT;
                else
                    tex1=imageTexture;
                end
                x_pos=posx(nquad);
                y_pos=posy(nquad);
                dstRect = [x_pos - texture_width/2, y_pos - texture_height/2, x_pos + texture_width/2, y_pos + texture_height/2]; 
                Screen('DrawTexture', expWin, tex1, [], dstRect);
            end
            Screen('Flip', expWin);
            KbWait([], 2); %wait for keystroke
        end

        Screen('drawline',expWin,[255 255 255],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[255 255 255],mx,my-fix_size,mx,my+fix_size,2);        
        Screen('Flip', expWin);

        % RESPONSE SCREEN
       % Screen('drawline',expWin,[0 0 0],mx-fix_size,my,mx+fix_size,my,2);
       % Screen('drawline',expWin,[0 0 0],mx,my-fix_size,mx,my+fix_size,2);
 %posy=[y-texture_height/2*1.1, y-texture_height/2*1.1, y+texture_height/2*1.1, y+texture_height/2*1.1];
        posx=[x-texture_width/2*1.1, x+texture_width/2*1.1, x-texture_width/2*1.1, x+texture_width/2*1.1];
        posy=[y-texture_height/2*1.1, y-texture_height/2*1.1, y+texture_height/2*1.1, y+texture_height/2*1.1];       
        options = [1:which_image-1 which_image+1:num_images];
        options_which = randperm(num_images-1);
        options4 = options(options_which);
%         for nquad=1:4
%             if nquad==which_quad
%                 n_im=which_image;
%             else
%                 n_im=options4(nquad)
%             end            
%             target1=targets(n_im);
%             fullname = [target1.folder '/' target1.name]
%             img1=gen1x_noblur(fullname,tTest_spac);
%             img1=imresize(img1,imsize);
%             tex1 = Screen('MakeTexture', expWin, img1*255);
%             x_pos=posx(nquad);
%             y_pos=posy(nquad);
%             dstRect = [x_pos - texture_width/2, y_pos - texture_height/2, x_pos + texture_width/2, y_pos + texture_height/2]; 
%             Screen('DrawTexture', expWin, tex1, [], dstRect);
%             %Screen('DrawTextures', expWin, masktex, [], dstRect, [], [], 1, [0, 0, 0, 1]', [], []);                    
%        end

        Screen('drawline',expWin,[255 255 255],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[255 255 255],mx,my-fix_size,mx,my+fix_size,2);        

        Screen('DrawText', expWin, 'A', x-100, y-100);
        Screen('DrawText', expWin, 'F', x+100, y-100);
        Screen('DrawText', expWin, 'M', x-100, y+100);
        Screen('DrawText', expWin, '?', x+100, y+100);
        Screen('Flip', expWin);            
        while (done==0) % No response yet. Wait for key
            [keyIsDown, secs_response, keyCode, deltaSecs] = KbCheck();
            if (keyIsDown)
                done=1;
            end
        end
        Screen('drawline',expWin,[255 255 255],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[255 255 255],mx,my-fix_size,mx,my+fix_size,2);        
        Screen('Flip', expWin);

        rt=secs_response-secs_stim_on;

        %find out which key was pressed
        cc=KbName(keyCode);  %translate code into letter (string)

        resp_class=0;
        if isempty(cc) || contains(cc,'ESCAPE')
            break;   %break out of trials loop, but perform all the cleanup things
        elseif contains(cc,'7') || contains(cc,'a') 
            resp_class = 1;
        elseif contains(cc,'9') || contains(cc,'f')
            resp_class = 2;
        elseif contains(cc,'1') || contains(cc,'m')
            resp_class = 3;
        end

        correct=(resp_class==target_class);

        if correct
            feedback_color = [0 255 0];
        else
            feedback_color = [255 0 0];
        end

        Screen('drawline',expWin,feedback_color,mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,feedback_color,mx,my-fix_size,mx,my+fix_size,2);
        Screen('Flip', expWin);

        q=QuestUpdate(q,tTest,correct); % Add the new datum (actual test intensity and observer response) to the database.

        results(ntrial,:)=[ntrial,z4_baseline_D ,z12_quest,correct,target_class,resp_class,rt];
        results(ntrial,:)
    end
    
    n_unique=0;
    output_filename = sprintf('results/contour_sphere-%s_%02d.csv',output_name,n_unique);
    while isfile( output_filename)
        n_unique = n_unique + 1;
        output_filename = sprintf('results/contour_sphere-%s_%02d.csv',output_name,n_unique);
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
        ylabel( "Spacing")
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
    
