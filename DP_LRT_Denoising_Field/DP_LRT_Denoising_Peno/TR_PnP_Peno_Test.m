function [recover] = TR_PnP_Peno_Test(Y, tau, alpha, beta, gamma, lambda1, lambda2, r, d, rho, iter_g, iter_x)

randn('seed',0);

par = Parset_TR_LSM(tau, alpha, beta, gamma, lambda1, lambda2, r, d, rho, iter_g, iter_x);

Y = permute(Y, [2 1 3]);
% 有噪数据

Y = ((Y - min(Y,[],'all')) / (max(Y,[],'all') - min(Y,[],'all')));
Y = 2 * Y - 1;

[Nx,Ny,Nt] = size(Y);

% Initialization
Bx = zeros(Nx,Ny,Nt); 
By = zeros(Nx,Ny,Nt); 
B = zeros(Nx,Ny,Nt);
Dx = zeros(Nx,Ny,Nt); 
Dy = zeros(Nx,Ny,Nt); 
Z = Y; 
% X = Y; 
J = Y;

Iter = 10; % ADMM outer-loop

for k = 1: Iter

    % Update X
    [Xnew] = UpdateXTen(Y,Z,Dx,Dy,B,Bx,By,alpha,beta,gamma,d,rho,iter_x,J);
    % RSE(k) = norm( Xnew(:) - X(:),2 )/norm(X(:));
    J = Xnew;  % 下一轮迭代的初始化
    X = Xnew;    
    
    % Update Z
    % [Znew, objV] = proxF_tSVD_1(X+B,tau/alpha,1);
    % [Znew, objV] = proxF_tSVD_GSM(X+B,tau/alpha,1);
    [Znew] = proxF_TR_Main(X+B, tau, par);
    Z = Znew;

    % Update D1
    Dxx = zeros(Nx,Ny,Nt);
    for i = 1:Nt 
        temp = diff(X(:,:,i)-Y(:,:,i),1,2);
        dx = [temp temp(:,Ny-1)];   
        Dxx(:,:,i) = dx;
    end
    % Dx_new = shrink(Dxx+Bx,lambda1/beta);
    % Dx_new = proxF_GSM_sparsity_3D(Dxx+Bx,lambda1/beta);
    Dx_new = proxF_GSM_sparsity_3D_W(Dxx+Bx,lambda1/beta); 
    Dx = Dx_new;  
    
    % Update D2
    Dyy = zeros(Nx,Ny,Nt);
    for i = 1:Nt
        temp1 = diff(X(:,:,i),1,1);
        dy = [temp1;temp1(Nx-1,:)];
        Dyy(:,:,i) = dy;
    end
    % Dy_new = shrink(Dyy+By,lambda2/gamma);
    % Dy_new = proxF_GSM_sparsity_3D(Dyy+By,lambda2/gamma);
    Dy_new = proxF_GSM_sparsity_3D_W(Dyy+By,lambda2/gamma);
    Dy = Dy_new;

    % Update B, Bx, and By
    B_new = B+(X-Z);
    Bx_new = zeros(Nx,Ny,Nt);
    By_new = zeros(Nx,Ny,Nt);
    for i = 1:Nt
        Bx_new(:,:,i) = Bx(:,:,i) +  (X(:,[2:Ny,Ny],i) - X(:,:,i)) - (Y(:,[2:Ny,Ny],i)- Y(:,:,i)) - Dx(:,:,i);        
        By_new(:,:,i) = By(:,:,i) +   X([2:Nx,Nx],:,i)- X(:,:,i) - Dy(:,:,i);
    end
    B  = B_new;    
    Bx = Bx_new;    
    By = By_new;

end

% 函数输出
recover = X; 
noise = Y - X;

save('peno_recover.mat','recover','-v7.3');
save('peno_removed.mat','noise','-v7.3');

end

