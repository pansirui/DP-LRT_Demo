function  [im_denoised]     =  FFD_Net_Denoiser (input, imageNoiseSigma)

randn ('seed',0);

inputNoiseSigma   =   imageNoiseSigma;

format compact;
global sigmas;


load(fullfile('models','FFDNet_gray.mat'));
net = vl_simplenn_tidy(net);

% input = double(input);

sigmas = inputNoiseSigma; 

% 转为 single
input = single(input);
for i = 1:numel(net.layers)
    if isfield(net.layers{i}, 'weights')
        for j = 1:numel(net.layers{i}.weights)
            net.layers{i}.weights{j} = single(net.layers{i}.weights{j});
        end
    end
end
    
 % res    = vl_ffdnet_matlab(net, input); % use this if you did  not install matconvnet; very slow
 res    = vl_simplenn(net,input,[],[],'conserveMemory',true,'mode','test');
    
    output = res(end).x;
    
    im_denoised  =  double(output*255);

 


end

