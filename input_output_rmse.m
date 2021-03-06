% calculate the average error of interpolation vs GD
% calculate the average eror of CNN output vs GD
[input_name, model_name, save_name]= input_output_path();

load(model_name);
load(input_name);
net = Net(net);
if strcmpi('WIN64',computer('arch')) 
    net.move('gpu');
else 
    net.move('cpu');
end
size_ = size(imdb.images.data);
% net.getValue('loss1');
num_im = size_(4);
% num_im = 500;
imdb.images.data(:,:,4,:) = imdb.images.data(:,:,4,:)/80;
imdb.images.data(:,:,1:3,:) = imdb.images.data(:,:,1:3,:)/255;
error =0; 
error_inList = zeros(1,num_im);
error_cnnList = zeros(1,num_im);

for i = 1:num_im
% input with fitlers 
         input_data = imdb.images.data(:,:,4,i);
%          input_data = imbilatfilt(imdb.images.data(:,:,4,i),'DegreeOfSmoothing', 3.5, 'SpatialSigma', 5.8);
%          input_data = imbilatfilt(imdb.images.data(:,:,4,i));
%          input_data = imdiffusefilt(imdb.images.data(:,:,4,i), 'GradientThreshold', 14, 'NumberOfIterations', 3, 'Connectivity','minimal');
%            input_data = imdiffusefilt(imdb.images.data(:,:,4,i));
                  
         [error_in, ~] = evalmodel.inputError(input_data, imdb.images.labels(:,:,1,i));
         error_inList(i) = error_in;
         
%          [error_cnn, cnn_out] = evalmodel.cnnOuterror(imdb.images.data(:,:,:,i), imdb.images.labels(:,:,:,i), net);
%          error_cnnList(i) = error_cnn; 
end 

% rmse_plot(error_inList, error_cnnList);
% save(save_name,'error_cnnList','error_inList');
% rmse_plot();

function rmse_plot(error_inList, error_cnnList)
    plot(error_inList);
    hold on
    plot(error_cnnList);
    hold off
    lgd = legend('Morph. +Anisotrpic + Mask', 'Morphological'); % Morph. +Anisotrpic + Mask;Morphological
    lgd.FontSize = 15; 
    ylabel('Error');
    xlabel('Images index');
    title('CNN output error comparison');
end 


