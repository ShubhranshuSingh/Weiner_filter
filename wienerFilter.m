%% Read image and add noise

Input_Image = imread('input.jpg');
Gray_image = rgb2gray(Input_Image);
Sigma = 50; % Standard deviation of noise
Size = 11;  % Size of patch
blur_kernel = fspecial('gaussian',Size,2); % Blurring gaussian kernel
Image_with_blur = imfilter(Input_Image,blur_kernel);
Image_with_noise = imnoise(Image_with_blur,'gaussian',0,(Sigma/255)^2); % Add WGN

%% Filtering

P_I = (1/Size^2).*abs(fft2(Gray_image(50:50+Size-1,50:  50+Size-1))).^2; % PSD of image patch
P_n = (Sigma^2); % PSD of noise

blur_fft = fft2(blur_kernel); % DTFT of blur kernel

wiener_fft = zeros(Size,Size);

for i=1:Size
    for j=1:Size
        wiener_fft(i,j) = conj(blur_fft(i,j))/((abs(blur_fft(i,j)^2))+(P_n/P_I(i,j)));
    end
end

wiener_filt = real(ifft2(wiener_fft)); % Wiener filter

%% Show output

out = imfilter(Image_with_noise,wiener_filt);

figure()
imshow(Input_Image)
title('Clean Image')

figure()
imshow(Image_with_noise)
title('Noisy Image')
fprintf('PSNR of Noisy Image: %f\n',psnr(Image_with_noise,Input_Image));
fprintf('MMSE of Noisy Image: %f\n',immse(Image_with_noise,Input_Image));


figure()
imshow(out)
title('Filtered Image')
fprintf('PSNR of Filtered Image: %f\n',psnr(out,Input_Image));
fprintf('MMSE of Filtered Image: %f\n',immse(out,Input_Image));

% Uncomment to save images
% imwrite(Image_with_noise,'in_noise.jpg')
% imwrite(out,'in_filtered.jpg')

%% Test on other images

while 1
    a= input('Image location : '); % Destination of test image
    blur_sd = input('Gaussian blur standard deviation: ');
    noise_sd = input('Noise standard deviation: ');
    
    test = imread(a);
    test_noise = imfilter(test,fspecial('gaussian', Size, blur_sd)); % Add blur
    test_noise = imnoise(test_noise,'gaussian',0,(noise_sd/255)^2); % Add noise

    out_test = imfilter(test_noise,wiener_filt); % Filtered image
    
    figure()
    imshow(test)
    title('Clean Image')
    
    figure()
    imshow(test_noise)
    title('Noisy Image')
    fprintf('PSNR of Noisy Image: %f\n',psnr(test_noise,test));
    fprintf('MMSE of Noisy Image: %f\n',immse(test_noise,test));


    figure()
    imshow(out_test)
    title('Filtered Image')
    fprintf('PSNR of Filtered Image: %f\n',psnr(out_test,test));
    fprintf('MMSE of Filtered Image: %f\n',immse(out_test,test));
    
%     Uncomment to save images    
%     imwrite(test_noise,'Y_noise.jpg')
%     imwrite(out_test,'Y_filtered.jpg')
    
    b = input('Do you want to exit(y or n): ');
    if(b == 'y')
        break
    end
end