function [PSNR_Final,FSIM_Final,SSIM_Final,ERGAS_Final, SAM_Final, iter, Time_s] = TR_LSM_Denoising_Test(ori, Y, tau, alpha, beta, gamma, lambda1, lambda2, r, d, rho, iter_g, iter_x)

randn('seed',0);

par = Parset_TR_LSM(tau, alpha, beta, gamma, lambda1, lambda2, r, d, rho, iter_g, iter_x);

time0 = clock;
 
[Denoising, iter] = TR_LSM_Denoising(ori, Y, par);  
% iter = iter - 1;

Time_s = (etime(clock,time0));

Xnew = Denoising{iter}; 

% 添加保存Xnew的代码
% save('Denoised_TR_PnP_40_40_300_20_6.mat','Xnew','-v7.3') ;
save('Denoised_TR_PnP_40_40_300_20_8.mat','Xnew','-v7.3') ;

output_image = ((Xnew - min(Xnew(:))) / (max(Xnew(:)) - min(Xnew(:))))*255;

Ori_Image = ((ori - min(ori(:))) / (max(ori(:)) - min(ori(:))))*255;

% [PSNR_all] = evaluate1(Ori_Image,output_image);

[PSNR_Final, SSIM_Final, FSIM_Final, ERGAS_Final, SAM_Final] = MSIQA(Ori_Image, output_image);

end

