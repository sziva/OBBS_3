files = dir('./images/*.png');

for file = files'
    slika = imread(strcat('./images/', file.name)); %v 8 bitnem zapisu (od 0-črna do 255-bela) [uint8]
    slika = im2double(slika); %da dobimo vrednosti med 1-bela in 0-črna [double]
    
    %{
    %%%%%%%%%%%%%filtriramo vsi imajo enako utež
    %[kernel=ones(3,3);
    kernel = kernel/sum(kernel(:));
    fslika = conv2(slika, kernel, 'same'); %same nam pove da je iyhodna slika enake dimenzije kot vhodna 
    
    %se ena moznost filtriranja
    f1slika = imfilter(slika, kernel); %izhod v istem formatu kot format slike
    %%%%%%%%%%%%%%
    %}
    
    %%%%%%%gausov filter ima različne uteži
    
    %kernel = calcGauss(1); %povemo mu sigmo in sam vrne kernel in določi meje ki so še smiselne 
    %kernel = fspecial('gauss', [7 7], 1) %ta 7x7 pomeni koliko bo prispeval bolj oddaljen pixel
    
    sigma=min(size(slika))*0.005; % sigma=0.5% of min. image size dimension in pixels
    % calculate the kernel coefficients and visualize the kernel with a 3d mesh
    kernel = calcGauss(sigma);
    %kernel = calcLoG(sigma);
    mesh(kernel); 

    % filter the image using the imfilter function and the kernel
    filterSlika = imfilter(I, kernel);
    % instead it is possible to use 2d convolution
    % G = conv2(im2double(I), k1, 'same');
    figure;
    subplot(1,2,1); imshow(slika); % original
    subplot(1,2,2); imshow(filterSlika); % filtered

    % use the fspecial function to calculate the Gaussian kernel 
    % coefficients, then filter the image and show the results
    kernel2 = fspecial('gaussian', 17, sigma);
    filterSlika2 = imfilter(slika, kernel2);

    figure;
    subplot(1,2,1); imshow(slika); % original
    subplot(1,2,2); imshow(filterSlika2); % filtered
    
    
   
    
    
end

%imshow(slika, []) ce zelimo samo inteziteto od x do x pokazat
%imwrite