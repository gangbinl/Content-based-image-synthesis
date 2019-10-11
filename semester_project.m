% -------------------------------------------------------------------------
% Please consult the README before using this program for best results 
% -------------------------------------------------------------------------

clear all
close all
clc

height_scale = 500;

% Load and rescale foreground image
fg = imread('foreground.png');
fg_height = size(fg, 1);
scale = height_scale/fg_height;
rescale_fg = imresize(fg, scale);

% Load and rescale background image
bg = imread('background.png');
bg_height = size(bg, 1);
scale = height_scale/bg_height;
rescale_bg = imresize(bg, scale);

% Display background and foreground images
figure,imshow(rescale_bg);
figure,imshow(rescale_fg);

% Convert foreground image to binary
done = 0;
while(done == 0)
    
    % Prompt user to enter a threshold
    prompt = ['Convert foreground to binary: enter a threshold value ' ...
        'in the range [0, 1].'];
    answer = (inputdlg(prompt));
    threshold = str2num(answer{1});
    bw_img = im2bw(rescale_fg, threshold);
    figure,imshow(bw_img);
    
    % Allow user to enter a new threshold. Any input other than 'y' is 
    % taken as 'n'.
    prompt = ['Type y to redo. Type anything else to continue with ' ...
        'your current result.'];
    answer = (inputdlg(prompt));
    yes = 'y';
    if (strcmp(string(answer), yes) ~= 1)
        done = 1;
    end
    
end

% Erode and dilate binary image
done = 0;
while(done == 0)
    
    % Prompt user to enter a number of times
    prompt = ['Erosion and dilation: enter a number of times to apply ' ...
        'each operation.'];
    answer = (inputdlg(prompt));
    k = str2num(answer{1});
    processed_img = bwmorph(bw_img, 'erode', k);
    processed_img = bwmorph(processed_img, 'dilate', k);
    figure,imshow(processed_img);
    
    % Allow user to enter a new number of times. Any input other than 'y' 
    % is taken as 'n'.
    prompt = ['Type y to redo. Type anything else to continue with ' ...
        'your current result.'];
    answer = (inputdlg(prompt));
    yes = 'y';
    if (strcmp(string(answer), yes) ~= 1)
        done = 1;
    end
    
end

% Copy the input image to edit
imgrows = size(rescale_fg,1);
imgcols = size(rescale_fg,2);
output = rescale_fg;

% Replace sky pixels with background image pixels
for x = 1:imgrows
   for y = 1:imgcols 
       
       % The z vector holds the rgb values
       if processed_img(x,y) == 1
           output(x,y,1) = bg(x,y,1);
           output(x,y,2) = bg(x,y,2);
           output(x,y,3) = bg(x,y,3);
       end
       
   end
end
figure,imshow(output);

% Give the user the option to apply color filter to foreground
done = 0;
prompt = ['Type y to apply a color filter to foreground. Type ' ...
        'anything else to save your current result.'];
answer = (inputdlg(prompt));
yes = 'y';
if (strcmp(string(answer), yes) ~= 1)
    done = 1;
end

% Give the user a brief explanation of MATLAB rgb color triplets if they
% chose to apply color filter to foreground
if done == 0
    waitfor(msgbox(['Your color image represents color as an rgb ' ...
        'triplet: an additive quantity of red, green, and blue. In ' ...
        'this MATLAB program the value for each color is in the range ' ...
        '[0,255]. To tint the image, choose an amount by which to ' ...
        'alter the values for each color channel. Note that the ' ...
        'program will accept large values, but may result in a ' ...
        'completely white (if positive) or completely black (if ' ...
        'negative) foreground. See the README for more information on ' ...
        'how to achieve specific tints.']));
end

% Apply color filter to foreground
while(done == 0)
    
    temp = output;
    
    % Prompt user to enter a value to alter each color channel
    prompt = 'Color filter: enter a value to alter the red channel.';
    answer = (inputdlg(prompt));
    r_val = str2num(answer{1});
    prompt = 'Color filter: enter a value to alter the green channel.';
    answer = (inputdlg(prompt));
    g_val = str2num(answer{1});
    prompt = 'Color filter: enter a value to alter the blue channel.';
    answer = (inputdlg(prompt));
    b_val = str2num(answer{1});
    
    % Add the values to alter each color channel to foreground image pixels
    for x = 1:imgrows
        for y = 1:imgcols 
       
            % The z vector holds the rgb values
            if processed_img(x,y) == 0
                temp(x,y,1) = output(x,y,1) + r_val;
                temp(x,y,2) = output(x,y,2) + g_val;
                temp(x,y,3) = output(x,y,3) + b_val;
            end
       
        end
    end
    figure,imshow(temp);
    
    % Allow user to enter new value. Any input other than 'y' is taken as 
    % 'n'.
    prompt = ['Type y to redo. Type anything else to save your ' ...
        'current result.'];
    answer = (inputdlg(prompt));
    yes = 'y';
    if (strcmp(string(answer), yes) ~= 1)
        done = 1;
        output = temp;
    end
    
end

% Disply and save output image
figure,imshow(output);
imwrite(output, 'output.png');
