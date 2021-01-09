slice = imread('0001.png');

sigma=min(size(slice))*0.005;
fslice = imgaussfilt(im2double(slice), sigma); %sigma is a value od standard deviation
figure; imshow(fslice, [min(fslice(:)),max(fslice(:))]); title('Gaussian smoothing');

% % Roberts mask
% kx = [-1, 1]
% ky = [-1; 1]
% Prewitt mask/cross
kx = [-1 0 +1; -1 0 +1; -1 0 +1];
ky = [-1 -1 -1; 0 0 0; +1 +1 +1];

gx = conv2(fslice, kx, 'same');
gy = conv2(fslice, ky, 'same');

figure; imshow(gx,[]); title('Horizontal gradient');
figure; imshow(gy,[]); title('Vertical gradient');

% % OR EVEN SIMPLER CALCULATION FOR THE WHOLE MATRIX
mag = sqrt(gx.^2 + gy.^2);
ang = atan2(gy, gx); % or atan2d(gy,gx)
%ang = ang*180/pi;

figure; imshow(mag, [min(mag(:)),max(mag(:))]); title('Magnitude');
figure; imshow(ang, [min(ang(:)),max(ang(:))]); title('Angle');

% N1: Thin the ridges using non-maximum suppression (using magnitude and angle)
x = size(fslice, 1);
y = size(fslice, 2);

% Discretization of directions
ang_1 = zeros(x, y);

for i=1:x
    for j=1:y
        if ((ang(i,j) > 0) && (ang(i,j) < 22.5) || (ang(i,j) > 157.5) && (ang(i,j) < -157.5))
            ang_1(i,j) = 0;
        end
        if ((ang(i,j) > 22.5) && (ang(i,j) < 67.5) || (ang(i,j) < -112.5) && (ang(i,j) > -157.5))
            ang_1(i,j) = 45;
        end    
        if ((ang(i,j) > 67.5 && ang(i,j) < 112.5) || (ang(i,j) < -67.5 && ang(i,j) > 112.5))
            ang_1(i,j) = 90;
        end        
        if ((ang(i,j) > 112.5 && ang(i,j) <= 157.5) || (ang(i,j) < -22.5 && ang(i,j) > -67.5))
            ang_1(i,j) = 135;
        end
    end
end

im = zeros(x, y);

for i=2:x-1
    for j=2:y-1
        if (ang_1(i,j)==0)
            im(i,j) = (mag(i,j) == max([mag(i,j), mag(i,j+1), mag(i,j-1)]));
        end
        if (ang_1(i,j)==45)
            im(i,j) = (mag(i,j) == max([mag(i,j), mag(i+1,j-1), mag(i-1,j+1)]));
        end
        if (ang_1(i,j)==90)
            im(i,j) = (mag(i,j) == max([mag(i,j), mag(i+1,j), mag(i-1,j)]));
        end
        if (ang_1(i,j)==135)
            im(i,j) = (mag(i,j) == max([mag(i,j), mag(i+1,j+1), mag(i-1,j-1)]));
        end
    end
end

im = im.*mag;
figure; imshow(im); title('non-maximum suppression');

% N2: Hysteresis thresholding (separation into strong and weak edge pixels)
% N3: Form longer edges (edge-linking w/ 8-connectivity of weak pixels to strong pixels)
TL = 0.001; %polovica TH
TH = 0.01; %doloci otsc

TL = TL*max(max(im))
TH = TH*max(max(im))

T = zeros(x, y);

for i=1:x
    for j=1:y
        if (im(i,j) < TL)
            T(i,j) = 0;
        elseif (im(i,j) > TH)
            T(i,j) = 1;
        %Using 8-connected components %pogledamo ce je v sosescini kaksen
        %mocen piksel in je potem rob
        elseif (im(i+1,j) > TH || im(i-1,j) > TH || im(i,j+1) > TH || im(i,j-1) > TH || im(i-1, j-1) > TH || im(i-1, j+1) > TH || im(i+1, j+1) > TH || im(i+1, j-1) > TH)
            T(i,j) = 1;
        end
    end
end

figure; imshow(T); title('Hysteresis thresholding');

final = im2uint8(T);
imwrite(final, strcat('0001_r1.png'));
%Show final edge detection result
figure, imshow(final); title('final');


