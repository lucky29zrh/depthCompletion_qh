function [] = sparseNN(imdb)
% demo script for training a dummy depth completion network
gpuDevice(1);
% SETUP:
% gpuDevice(1)
% [imdb] = generate_imdb_demo([]); 
setup_autonn;
vl_setupnn;
   
try  % detect the usable of GPU 
   gpuArray(1);
   gpus=true;
catch
   gpus=[];
end 


%%% train %%%
% setup location for network coefficients
% opts.expDir = fullfile('D:\convnet\model_result\models', 'demo') ;
% load('D:\convnet\depthCompletionNet-master\data\imdb_sparse_500morph.mat');
%opts.expDir = fullfile('f:\convnet\model_result\models', 'demo') ;
opts.expDir = fullfile('/Users/Hall/convnn/data/models/demo', 'demo') ;
load('/Users/Hall/convnn/data/imdb_sparse_100.mat');
% >>>>>>> 7c8bdb14717a1e80ae83306db61a0954b08b0de5


if gpus %select batchSize according to GPU or CPU
    batchSize = 4; % gpu
else 
    batchSize = 2; % cpu
end 

opts.batchSize = batchSize; 
imdb.batchSize = opts.batchSize;
opts.gpus = gpus;

images = Input('images');
labels = Input('labels');

if gpus
    images.gpu = true; %mac
else 
    images.gpu = false;
end 

channels = 16;
expansion = [1,2,4,4,4,8]; % the factors used to expand the channel number

% depth U-net pathway %
fsLow = [3 , 3]; padLow = floor(fsLow(1)/2);
fsMed_simple = [7 , 7]; padMed = floor(fsMed_simple(1)/2);
fsHigh_simple= [11 , 11]; padHigh= floor(fsHigh_simple(1)/2);
b = gpuArray(randn(1,16,'single'));
c = gpuArray(randn(1,1,'single'));

mask0 = single(images ~= 0);
conv0_mul = images.*mask0;
conv1 = vl_nnconv(conv0_mul, 'size', [fsHigh_simple(1), fsHigh_simple(2), 1, expansion(1)*channels], 'stride',1,'pad', 5,  'hasBias', false);
% conv1_mask = vl_nnconv(mask0, 'size', [fsHigh(1), fsHigh(2), 1, 1], 'stride',1, 'pad', 5, 'weightScale', 'allone', 'trainable', false, 'hasBias', false);  % initial a all one kernel!!
conv1_mask = vl_nnconv(mask0, gpuArray(ones(11,11, 'single')), [],  'stride',1, 'pad', 5);
% conv1_1 = conv1 ./ (conv1_mask+1); 
conv1_maskinv = conv1./(conv1_mask+0.01);
conv1_1 = vl_nnconv(conv1_maskinv, [], b); 
mask1 = vl_nnpool(mask0, 11, 'method', 'max', 'stride', 1 , 'pad' ,5);


conv1_mul = conv1_1.*mask1;
conv2 = vl_nnconv(conv1_mul, 'size', [fsMed_simple(1), fsMed_simple(2), 16, expansion(1)*channels], 'stride',1,'pad', 3, 'hasBias', false );
% conv2_mask = vl_nnconv(mask1, 'size', [fsMed(1), fsMed(2), 1, 1], 'stride',1, 'pad', 3, 'weightScale', 'allone', 'trainable', false, 'hasBias', false);  
conv2_mask = vl_nnconv(mask1, gpuArray(ones(7,7, 'single')), [],  'stride',1, 'pad', 3);
conv2_maskinv = conv2 ./ (conv2_mask+0.01);
conv2_1 = vl_nnconv(conv2_maskinv, [], b); 
mask2 = vl_nnpool(mask1, 7, 'method', 'max', 'stride', 1 , 'pad' ,3);

conv3_mul = conv2_1.*mask2;
conv3 = vl_nnconv(conv3_mul, 'size', [5, 5, 16, expansion(1)*channels], 'stride',1,'pad', 2, 'hasBias', false );
% conv3_mask = vl_nnconv(mask2, 'size', [5, 5, 1, 1], 'stride',1, 'pad', 2, 'weightScale', 'allone', 'trainable', false, 'hasBias', false); 
conv3_mask = vl_nnconv(mask2, gpuArray(ones(5,5, 'single')), [],  'stride',1, 'pad', 2);
conv3_maskinv = conv3 ./(conv3_mask+0.01);
conv3_1 = vl_nnconv(conv3_maskinv, [], b); 
mask3 = vl_nnpool(mask2, 5, 'method', 'max', 'stride', 1 , 'pad' ,2);

conv4_mul = conv3_1.*mask3;
conv4 = vl_nnconv(conv4_mul, 'size', [fsLow(1), fsLow(2), 16, expansion(1)*channels], 'stride',1,'pad', 1 , 'hasBias', false);
% conv4_mask = vl_nnconv(mask3, 'size', [fsLow(1), fsLow(2), 1, 1], 'stride',1, 'pad', 1, 'weightScale', 'allone', 'trainable', false, 'hasBias', false);  
conv4_mask = vl_nnconv(mask3, gpuArray(ones(fsLow(1),fsLow(2), 'single')), [],  'stride',1, 'pad', 1);
conv4_maskinv = conv4 ./(conv4_mask+0.01);
conv4_1 = vl_nnconv(conv4_maskinv, [], b); 
mask4 = vl_nnpool(mask3, fsLow(1), 'method', 'max', 'stride', 1 , 'pad' ,1);

conv5_mul = conv4_1.*mask4;
conv5 = vl_nnconv(conv5_mul, 'size', [fsLow(1), fsLow(2), 16, expansion(1)*channels], 'stride',1,'pad', 1, 'hasBias', false );
% conv5_mask = vl_nnconv(mask4, 'size', [fsLow(1), fsLow(2), 1, 1], 'stride',1, 'pad', 1, 'weightScale', 'allone', 'trainable', false, 'hasBias', false);  
conv5_mask = vl_nnconv(mask4, gpuArray(ones(fsLow(1),fsLow(2), 'single')), [],  'stride',1, 'pad', 1);
conv5_maskinv = conv5 ./(conv5_mask+0.01);
conv5_1 = vl_nnconv(conv5_maskinv, [], b); 
mask5 = vl_nnpool(mask4, fsLow(1), 'method', 'max', 'stride', 1 , 'pad' ,1);

conv6_mul = conv5_1.*mask5;
conv6 = vl_nnconv(conv6_mul, 'size', [1, 1, 16, 1], 'stride',1,'pad', 0, 'hasBias', false );
% conv6_mask = vl_nnconv(mask5, 'size', [1, 1, 1, 1], 'stride',1, 'pad', 0, 'weightScale', 'allone', 'trainable', false, 'hasBias', false);  
conv6_mask = vl_nnconv(mask5, gpuArray(ones(1,1, 'single')), [],  'stride',1, 'pad', 0);

conv6_maskinv = conv6 ./(conv6_mask+0.01);
conv6_1 = vl_nnconv(conv6_maskinv, [], c); 
mask6 = vl_nnpool(mask5, 1, 'method', 'max', 'stride', 1 , 'pad' ,0);

output =80*( conv6_1.*mask6);


% output = vl_nnconv(cat1, 'size', [1, 1, 17, 1], 'stride',1,'pad', 0 );
loss = vl_nnloss(output, labels, 'loss', 'mse');

Layer.workspaceNames();

net = Net(loss);


[net, info] = sparseNN_train(net, imdb, getBatch(opts,net.meta) ,opts) ;
% system('shutdown -s')

end




function fn = getBatch(opts,meta, gpu)
% fn = @(x,y) getDagNNBatch(x,y) ;
fn = @(x,y,z) getDagNNBatchSR(x,y,z) ;
end

function inputs = getDagNNBatchSR(imdb, batch, gpu)
    
    % returns a batch of images or patches for training 
    images =  imdb.images.data(:,:,:,batch) ; % selects the correct batch 
	labels =  imdb.images.labels(:,:,:,batch) ; 
    
    images(:,:,4,:) = single(images(:,:,4,:))/80;
    labels = single(labels);

    if gpu 
        inputs = {'images',gpuArray(single(images(:,:,4,:))),'labels',gpuArray(single(labels))} ;
    else
        inputs = {'images',single(images(:,:,4,:)),'labels',single(labels)} ; %mac
    end 
end


function net_out = add_(net, opts, sz, order, varargin)
opts.weightInitMethod = 'morph';
% opts.cudnnWorkspaceLimit = 1024*1024*1204*4 ; % 1GB
% opts.batchNormalization = false ;

filters = Param('value', init_weight(opts, sz, 'single'), 'learningRate', 10^1); % 1  0
biases = Param('value', zeros(sz(4), 1, 'single'), 'learningRate', 10^3); % 3  0


net_top = net.^(order);
net_bot = net.^(order-1);

net_top1 = vl_nnconv(net_top, filters, biases, varargin{:}) ; % set the learning rate to 0
net_bot1 = vl_nnconv(net_bot, filters, biases, varargin{:}) ;

net_out = net_top1./net_bot1;

% "A Fast Thresholded Linear Convolution Representation of Morphological Operations"

% net = vl_nnconv(net, filters, biases, varargin{:}) ;
% net = net.*[net>0.5];

% net = vl_nnrelu(net) ;
end

function weights = init_weight(opts, sz, type)  %initialize the weight of filter (learning path) 

switch lower(opts.weightInitMethod)
  case 'gaussian'
    sc = 0.01/opts.scale ;
    weights = randn(sz, type)*sc;
  case 'xavier'
    sc = sqrt(3/(sz(1)*sz(2)*sz(3))) ; 
    weights = abs( (rand(sz, type)*2 - 1)*sc ) ;   
  case 'morph'        
    weights = ones(sz, type) ;
  case 'xavierimproved'
    sc = sqrt(2/(sz(1)*sz(2)*sz(4))) ;  
    weights = randn(sz, type)*sc ;
  case 'full'
    weights = ones(sz, type);
  otherwise
    error('Unknown weight initialization method''%s''', opts.weightInitMethod) ;
end
end


function bw = morph_diamond(x_input, k)
    % x_input: the input of ; packed binary image of any dimension.

    % k: the morph. kernel size;
    r = floor(k/2);
    se = strel('diamond',r);
    bw = imdilate(x_input, se);
end 


