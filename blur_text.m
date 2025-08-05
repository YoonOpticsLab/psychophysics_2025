bgColor = [0 0 0];
textColor = [255 255 255];

if text_layout==1
    [normBoundsRect] = Screen('TextBounds', expWin, randstr);
    textWidth = normBoundsRect(3);
    textHeight = normBoundsRect(4);
    % --- Create Offscreen Window/Texture ---
    hpad=text_height; % one character pad front/back
    textureRect = [0 0 textWidth+hpad*2 textHeight];
    offscreenWindowPtr = Screen('OpenOffscreenWindow', expWin, bgColor, textureRect);
    
    % --- Draw Text onto Offscreen Window ---
    Screen('TextFont', offscreenWindowPtr, text_font);
    Screen('TextSize', offscreenWindowPtr, text_height);
    Screen('DrawText', offscreenWindowPtr, randstr, hpad, 0, textColor, bgColor); % Draw at top-left of texture
elseif text_layout==2
    Screen('TextSize', expWin, text_height);    
    [normBoundsRect] = Screen('TextBounds', expWin, 'X');
    textWidth = normBoundsRect(3);
    textHeight = normBoundsRect(4);
    hpad=text_height; % one character pad
    % --- Create Offscreen Window/Texture ---
    textureRect = [0 0 textWidth*1+(textWidth*text_spacing)*2+hpad*2 textHeight*1+(textHeight*text_spacing)*2+hpad*2];
    offscreenWindowPtr = Screen('OpenOffscreenWindow', expWin, bgColor, textureRect);
    
    % --- Draw Text onto Offscreen Window ---
    Screen('TextFont', offscreenWindowPtr, text_font);
    Screen('TextSize', offscreenWindowPtr, text_height);

    charnum=1;
    for row=0:2
        for col=0:2
            xpos=(text_height_pixels*text_spacing)*row+hpad;
            ypos=(text_height_pixels*text_spacing)*col+hpad;
            Screen('DrawText', offscreenWindowPtr, randstr(charnum), xpos, ypos, textColor, bgColor); % Draw at top-left of texture
            charnum = charnum+1;
        end
    end
end

% --- Get Image Data from Offscreen Window ---
imageData = Screen('GetImage', offscreenWindowPtr, [], [], [], 1); % last param 1= gray
%imageArray = Screen('GetImage', expWin, [], 'backBuffer', [], 1 );
blurd=conv2( double(imageData)/255, psf ); %imagesc(blurd)

% Scale to 0-1
blurd=blurd-min(min(blurd));
blurd=blurd/max(max(blurd));

% Make black-on-white, gamma correct
blurd = ((1-blurd) .^ (1/gamma_exponent) ) * 255;

stimulus=Screen('MakeTexture', expWin, blurd); % Or perform other operations with binaryImage
%Screen('DrawTexture', expWin, stimulus);
%Screen('Flip', expWin);
%KbWait([], 2); %wait for keystroke


