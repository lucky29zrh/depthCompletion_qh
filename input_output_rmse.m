% calculate the average error of interpolation vs GD
% calculate the average eror of CNN output vs GD
clear all;
[input_name, model_name]= input_output_path();
load(model_name);
load(input_name);

net = Net(net);
size_ = size(imdb.images.data);
% val_im = size_(4);
val_im = 100;
imdb.images.data(:,:,4,:) = imdb.images.data(:,:,4,:)/80;
imdb.images.data(:,:,1:3,:) = imdb.images.data(:,:,1:3,:)/255;
error =0; 
error_inList = 0;
error_cnnList = 0;

for i = 1:val_im
        
         instanceWeights = imdb.images.labels(:,:,1,i) ~= 0 ;
         
         t = (80* imdb.images.data(:,:,4,i)- imdb.images.labels(:,:,1,i)) .^ 2 ;
         y = instanceWeights .*t;
         y = sum(y);
         error_in = y/sum(sum(instanceWeights));
         error_in = sqrt(sum(error_in));
         error_inList = [error_inList error_in];
        
         net.eval({'images', imdb.images.data(:,:,:,i), 'labels', single(imdb.images.labels(:,:,1,i))},'test');
         cnn_out = net.getValue('prediction');
         error_cnn = net.getValue('loss1'); 
         error_cnnList = [error_cnnList error_cnn]; 
end 


save('D:\convv\results\inout_RMSE.mat','error_cnnList','error_inList');
