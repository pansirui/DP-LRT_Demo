function  [par]=Parset_TR_LSM(tau, alpha, beta, gamma, lambda1, lambda2, r, d, rho, iter_g, iter_x)
 
par.tau = tau;                 
par.alpha = alpha;                         
par.beta = beta; 
par.gamma = gamma;                                   
par.lambda1 = lambda1; 
par.lambda2 = lambda2;    
par.Iter = 10;  % 10
par. maxiter = iter_g; %25

%par. r = [9 3 3];
%par. r = [12 8 8];

par. r = r;  % r = [14 10 10]
par.d = d;
par.rho = rho;
par.iter_x = iter_x;
 
end
   

