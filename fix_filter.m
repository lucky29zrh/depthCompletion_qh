load('D:\convnet\model_result\models\demo\net-epoch-200.mat');
net = Net(net);
load('D:\convnet\depthCompletionNet-master\data\imdb_sparse_500interpo_test.mat');
imdb.images.data(:,:,4,:) = imdb.images.data(:,:,4,:)/80;
imdb.images.data(:,:,1:3,:) = imdb.images.data(:,:,1:3,:)/255;

imdb_new.images.data =  zeros(size(imdb.images.data),'single');
imdb_new.images.data(:,:,1:3,:) = imdb.images.data(:,:,1:3,:);
% imdb_new.images.labels = zeros(size(imdb.images.labels),'single');
size_ = size(imdb.images.data);
N =size_(4) ; % the number of images for testing 
M = 2; % the types  of filters 
ave_error = 0;
error = 0;
for j = 1:2
   switch j 
        case 1        
        for i =1: N
             imdb_new.images.data(:,:,4,i) = imdb.images.data(:,:,4,i);
             net.eval({'images', imdb_new.images.data(:,:,:,i), 'labels', single(imdb.images.labels(:,:,1,i))},'test');
            error = error + net.getValue('loss1'); 
        end
        ave_error = error/N;
        error = 0;
        
        case 2
         for i =1: N
            imdb_new.images.data(:,:,4,i) = imdiffusefilt(imdb.images.data(:,:,4,i));
             net.eval({'images', imdb_new.images.data(:,:,:,i), 'labels', single(imdb.images.labels(:,:,1,i))},'test');
            error = error + net.getValue('loss1'); 
         end
        ave_error = [ave_error error/N];
        error = 0;
        
        case 3
         for i =1: N
            imdb_new.images.data(:,:,4,i) = imbilatfilt(imdb.images.data(:,:,4,i));
             net.eval({'images', imdb_new.images.data(:,:,:,i), 'labels', single(imdb.images.labels(:,:,1,i))},'test');
            error = error + net.getValue('loss1'); 
         end
        ave_error = [ave_error error/N];
        error = 0;
   end 

end 


