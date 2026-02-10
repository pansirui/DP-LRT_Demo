clear all
close all
clc

Y = load('peno_250_150_40.mat'); 
Y = Y.peno_250_150_40;

m_10=0; 
All_data_Results_2_10 = cell(1,200);   

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

Tau_Num  = [1];  %tau
Alpha_Num = [0.01]; %a
Beta_Num  = [1];  %c
Gamma_Num = [0.05];    %b
Lamb_Num1= [10];     %lambda_1
Lamb_Num2 =  [0.5];  %lambda_2

R_Num = [[14 10 10]];  % [14 10 10]
D_Num = [0.05];
Rho_Num = [0.005];


tau  = Tau_Num(j);
alpha = Alpha_Num(m);
beta = Beta_Num(n);
gamma = Gamma_Num(mm);
lambda1 = Lamb_Num1(nn);
lambda2 =  Lamb_Num2(mn);
r = R_Num(nm,:);
d = D_Num(pp);
rho = Rho_Num(qq);

iter_g = 25;  % iteration numbers of solving each core tensor G_i (PAM)
iter_x = 1;  % iteration numbers of solving x under PnP framework (ADMM)

fprintf('tau = %2.2f, alpha = %2.2f, beta = %2.2f, gamma = %2.2f, lambda1 = %2.2f, lambda2 = %2.2f, TR-rank = [%d %d %d], d = %d, rho = %d, iter_g = %d, iter_x = %d\n', tau,alpha,beta,gamma,lambda1,lambda2,r,d,rho,iter_g,iter_x)

recover = TR_PnP_Peno_Test (Y, tau, alpha, beta, gamma, lambda1, lambda2, r, d, rho, iter_g, iter_x); 


[nx, ny, nt] = size(recover);

BRISQUE_ALL = zeros(1,nt);

noisy = permute(peno_250_150_40, [2 1 3]);

for index = 1:1:nt

    img = squeeze(noisy(:,:,index));

    min_value = min(img(:));
    max_value = max(img(:));
    
    img = uint8(255 * (img - min_value) / (max_value - min_value));
    
    brisqueScore = brisque(img);

    BRISQUE_ALL(index) = brisqueScore;

end

BRISQUE_MEAN = mean(BRISQUE_ALL);

m_10 = m_10 + 1;
All_data_Results_2_10{m_10} = {tau, alpha, beta, gamma, lambda1, lambda2, r(1), r(2), r(3), d, rho, iter_g, iter_x, BRISQUE_MEAN, NIQE_MEAN, PIQE_MEAN};

fprintf('BRISQUE = %2.2f\n', BRISQUE_MEAN)
 
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
