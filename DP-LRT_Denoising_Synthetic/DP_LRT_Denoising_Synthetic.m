clear all
close all
clc

m_10=0; 
m_20=0; 
m_30=0;    
m_40=0;  
m_50=0; 
m_60=0; 
m_70=0; 

All_data_Results_2_10 = cell(1,200);   
All_data_Results_2_20 = cell(1,200);  
All_data_Results_2_30 = cell(1,200);
All_data_Results_2_40 = cell(1,200);
All_data_Results_2_50 = cell(1,200);
All_data_Results_2_60 = cell(1,200);
All_data_Results_2_70 = cell(1,200);

  
% F = [0.1, 0.2, 0.5];   
% G = [0.02, 0.04, 0.06, 0.08];

F = 0.2;   
G = 0.08;

for f = F

    for g = G

            filename_clear = 'clean_40_40_300';
            filename_noisy = sprintf('noisy_40_40_300_%d_%d',f*100,g*100);
            fn_clear = [filename_clear, '.mat'];
            fn_noisy = [filename_noisy, '.mat'];

            ori = load (fn_clear);  
            ori = ori.clear_40_40_300;
            ori = permute(ori, [2 3 1]);
            
            Y = load(fn_noisy); 
            Y = Y.noisy_40_40_300;
            Y = permute(Y, [2 3 1]);


% calculate initial PSNR
dc = ori;
df = Y;
dc = ((dc - min(dc,[],'all')) / (max(dc,[],'all') - min(dc,[],'all')))*255;
df = ((df - min(df,[],'all')) / (max(df,[],'all') - min(df,[],'all')))*255;
PSNR_Initial = PSNR3D(dc, df);
clear dc df 

fprintf('filename_noisy = %s\n', filename_noisy)
fprintf('Initial PSNR = %2.2f\n', PSNR_Initial)

for j  =  1:1

    for m = 1:1
        
        for n = 1:1
            
            for mm = 1:1
                
                for nn = 1:1
                    
                    for mn = 1:1

                        for nm = 1:1

                            for pp = 1:1

                                for qq = 1:1
    
 
randn ('seed',0);

Tau_Num  = [0.5];
Alpha_Num = [1];
Beta_Num  = [0.5];
Gamma_Num = [0.1];
Lamb_Num1= [0.2];
Lamb_Num2 =  [2];

R_Num = [[14 10 10]];
D_Num = [0.05];
Rho_Num = [0.001]; 


tau  = Tau_Num(j);
alpha = Alpha_Num(m);
beta = Beta_Num(n);
gamma = Gamma_Num(mm);
lambda1 = Lamb_Num1(nn);
lambda2 =  Lamb_Num2(mn);

r = R_Num(nm,:);
d = D_Num(pp);
rho = Rho_Num(qq);

iter_g = 25;  
iter_x = 1;  

fprintf('tau = %2.2f, alpha = %2.2f, beta = %2.2f, gamma = %2.2f, lambda1 = %2.2f, lambda2 = %2.2f, TR-rank = [%d %d %d], d = %d, rho = %d, iter_g = %d, iter_x = %d\n', tau,alpha,beta,gamma,lambda1,lambda2,r,d,rho,iter_g,iter_x)

[PSNR_Final,FSIM_Final,SSIM_Final, ERGAS_Final, SAM_Final, Iters, Time_s] = TR_LSM_Denoising_Test (ori, Y, tau, alpha, beta, gamma, lambda1, lambda2, r, d, rho, iter_g, iter_x); 

PSNR_Gain = PSNR_Final - PSNR_Initial;

m_10 = m_10 + 1;
All_data_Results_2_10{m_10} = {filename_noisy, tau, alpha, beta, gamma, lambda1, lambda2, r(1), r(2), r(3), d, rho, iter_g, iter_x, PSNR_Final,FSIM_Final,SSIM_Final, ERGAS_Final, SAM_Final, Iters, Time_s, PSNR_Initial, PSNR_Gain};
 
writecell( All_data_Results_2_10{m_10}, 'TR_PnP_Denoising_Test_manuscript.xls','Sheet',1,'WriteMode','append');
 
clearvars -except F G f g filename_noisy ori Y i j m n mm nn mn nm pp PSNR_Initial m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
                                end

clearvars -except F G f g filename_noisy ori Y i j m n mm nn mn nm PSNR_Initial m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
                            end

 clearvars -except F G f g filename_noisy ori Y i j m n mm nn mn PSNR_Initial m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
                        end

 clearvars -except F G f g filename_noisy ori Y i j m n mm nn PSNR_Initial m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
                    end
                    
 clearvars -except F G f g filename_noisy ori Y i j m n mm PSNR_Initial m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
                end
                
 clearvars -except F G f g filename_noisy ori Y i j m n PSNR_Initial m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
            end
            
 clearvars -except F G f g filename_noisy ori Y i j m PSNR_Initial m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
        end
        
 clearvars -except F G f g filename_noisy ori Y i j PSNR_Initial m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
    end

 clearvars -except F G f g filename_noisy ori Y i PSNR_Initial m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
end

 clearvars -except F G f m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
    end

 clearvars -except F G m_20 All_data_Results_2_20 m_30 All_data_Results_2_30 m_40 All_data_Results_2_40...
    m_10 All_data_Results_2_10 m_50 All_data_Results_2_50 m_60 All_data_Results_2_60 m_70 All_data_Results_2_70
end  
