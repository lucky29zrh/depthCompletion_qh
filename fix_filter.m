close all;
clear all;
% load('D:\convnet\model_result\models\demo\net-epoch-200.mat'); %win
load('/Users/Hall/convnn/depthCompletionNet/models/morp/net-epoch-200-morp.mat');
net = Net(net);
load('/Users/Hall/convnn/depthCompletionNet/imdb_sparse_500morph_test.mat');

imdb.images.data(:,:,4,:) = imdb.images.data(:,:,4,:)/80;
imdb.images.data(:,:,1:3,:) = imdb.images.data(:,:,1:3,:)/255;

imdb_new.images.data =  zeros(size(imdb.images.data),'single');
imdb_new.images.data(:,:,1:3,:) = imdb.images.data(:,:,1:3,:);
% imdb_new.images.labels = zeros(size(imdb.images.labels),'single');
size_ = size(imdb.images.data);
% N =size_(4) ; % the number of images for testing 
N =1; % for test 
M = 3; % the types  of filters 
ave_error = 0;
error = 0;
for j = 1:M
   switch j 
        case 1        
        for i =1: N
             imdb_new.images.data(:,:,4,i) = imdb.images.data(:,:,4,i);
             net.eval({'images', imdb_new.images.data(:,:,:,i), 'labels', single(imdb.images.labels(:,:,1,i))},'test');
             error = error + net.getValue('loss1'); 
        end
        ave_error = error/N;
        error = 0;
        figure(1);
        subplot(4,1,2);
        imagesc(net.getValue('prediction'));
        title("without filter")
        
        case 2
         for i =1: N
            imdb_new.images.data(:,:,4,i) = imdiffusefilt(imdb.images.data(:,:,4,i), 'GradientThreshold', 10, 'NumberOfIterations', 15);
             net.eval({'images', imdb_new.images.data(:,:,:,i), 'labels', single(imdb.images.labels(:,:,1,i))},'test');
            error = error + net.getValue('loss1'); 
         end
        ave_error = [ave_error error/N];
        error = 0;
        figure(1);
        subplot(4,1,3);
        imagesc(net.getValue('prediction'));
        title("imdiffusefilt");
        
        case 3
         for i =1: N
            imdb_new.images.data(:,:,4,i) = imbilatfilt(imdb.images.data(:,:,4,i));
             net.eval({'images', imdb_new.images.data(:,:,:,i), 'labels', single(imdb.images.labels(:,:,1,i))},'test');
            error = error + net.getValue('loss1'); 
         end
        ave_error = [ave_error error/N];
        error = 0;
        figure(1);
         subplot(4,1,4);
         imagesc(net.getValue('prediction'));
         title("imbilatfilt");
        
   end 

end 

figure(1);
 subplot(4,1,1); 
 imagesc(imdb_new.images.data(:,:,1:3,500));title("RGB");





