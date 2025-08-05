trial_order=repmat( sigmas, [1, num_repeats]);
num_trials = size(trial_order,2);
trial_order=trial_order( randperm(num_trials) );

targets = dir(targets_dir);
targets = targets(3:end); % DRC: On linux, need to skip first two (. and ..)

% Read first one to init mask buffer etc. TODO: don't need. Can use imsize
% since they are all rescaled.
target1=targets(1);
fullname = [target1.folder '/' target1.name];
num_images = size(targets,1);
image_order = repmat( 1:num_images, [1 ceil(num_trials/num_images)]);
image_order = image_order(1:num_trials);
image_order=image_order( randperm(num_trials) );

img1=imread(fullname);  
img1=imresize(img1,imsize);
img1 = im2double(rgb2gray(img1)); % Convert to grayscale and double % Make b&w

siz=size(img1,1)/4;
midpoint_pixels = siz*midpoint;
[XX,YY]=meshgrid(-siz:siz-1,-siz:siz-1);
RR=sqrt((XX).^2+(YY).^2);
mask = 1 ./ (1+exp(-k*(midpoint_pixels-RR )) );

masks={};
quad_mask = mask.*0;
masks{1} = [mask,quad_mask;quad_mask,quad_mask];
masks{2} = [quad_mask,mask;quad_mask,quad_mask];
masks{3} = [quad_mask,quad_mask;mask,quad_mask];
masks{4} = [quad_mask,quad_mask;quad_mask,mask];

if debug_visualize_mask
    figure();
    subplot(1,2,1);
    m1=masks{1};
    plot(-siz*2:siz*2-1, m1(siz/2,:));
    grid();
    subplot(1,2,2);
    imagesc(m1);
end


%Prepare output
colHeaders = {'trial_num', 'file','blur_sigma','correct','target_quad','resp','rt'};
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

    %get the midpoint (mx, my) of this window, x and y
    [mx, my] = RectCenter(rect);

    %get rid of the mouse cursor, we don't have anything to click at anyway
    HideCursor;

    % Preparing and displaying the welcome screen
    % We choose a text size of 24 pixels - Well readable on most screens:
    Screen('TextSize', expWin, 48);

    for ntrial=1:num_trials
        which_quad = floor(rand(1)*4)+1; % TODO: make counterbalanced
        mask_entire = masks{which_quad};
        blur_val = trial_order(ntrial);
        which_image = image_order(ntrial);

        target1=targets(which_image);
        fullname = [target1.folder '/' target1.name];
        img1=imread(fullname);  
        img1=imresize(img1,imsize);
        img1 = im2double(rgb2gray(img1)); % Convert to grayscale and double % Make b&w

        blurred = imgaussfilt(img1,blur_val);

        summed = (img1.*(1-mask_entire) + blurred .* (mask_entire) ) / 2.0;

        Screen('drawline',expWin,[0 0 0],mx-fix_size,my,mx+fix_size,my,2);
        Screen('drawline',expWin,[0 0 0],mx,my-fix_size,mx,my+fix_size,2);
    
        % Draw 'myText', centered in the display window:
        %DrawFormattedText(expWin, 'Press a key to start', mx, my+50);
        Screen('Flip', expWin);
        KbWait([], 2); %wait for keystroke
    
        imageTexture = Screen('MakeTexture', expWin, summed*255);
        if draw_mask
            img_fft = fft2(summed);
            magnitude = abs(img_fft);
            phase = angle(img_fft);
            
            random_phase = -pi + (pi+pi)*rand(size(phase)); % Random phase between -pi and pi
            scrambled_fft = magnitude .* exp(1i * random_phase);
            phase_scrambled_img = ifft2(scrambled_fft);
            phase_scrambled_img = real(phase_scrambled_img);
            
            % Scale to range [0,1]
            phase_scrambled_img = phase_scrambled_img - min(min(phase_scrambled_img));
            phase_scrambled_img = phase_scrambled_img / max(max(phase_scrambled_img));

            % Match max of input image:
            phase_scrambled_img = phase_scrambled_img * max(max(summed));
            maskTexture = Screen('MakeTexture', expWin, phase_scrambled_img*255);
        end
    
        for flip_count=1:duration_flips
            Screen('DrawTexture', expWin, imageTexture);
            Screen('Flip', expWin);
        end
        
        if draw_mask
            
            for flip_count=1:duration_flips 
                Screen('drawline',expWin,[0 0 0],mx-fix_size,my,mx+fix_size,my,2);
                Screen('drawline',expWin,[0 0 0],mx,my-fix_size,mx,my+fix_size,2);
                Screen('DrawTexture', expWin, maskTexture );
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

        resp_quad=0;
        if isempty(cc) || strcmp(cc,'ESCAPE')
            break;   %break out of trials loop, but perform all the cleanup things
        elseif strcmp(cc,'7') || strcmp(cc,'q')
            resp_quad = 1;
        elseif strcmp(cc,'9') || strcmp(cc,'e')
            resp_quad = 2;
        elseif strcmp(cc,'1') || strcmp(cc,'z')
            resp_quad = 3;
        elseif strcmp(cc,'3') || strcmp(cc,'c')
            resp_quad = 4;
        end

        correct=(resp_quad==which_quad);

        results(ntrial,:)=[ntrial,which_image,blur_val,correct,which_quad,resp_quad,rt];
        results(ntrial,:)
    end
    
    n_unique=0;
    output_filename = sprintf('results/%s_%02d.csv',output_name,n_unique);
    while isfile( output_filename)
        n_unique = n_unique + 1;
        output_filename = sprintf('results/%s_%02d.csv',output_name,n_unique);
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
        variable=blur_levels_D;
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
    
