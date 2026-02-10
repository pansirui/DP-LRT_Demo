function [Denoising, k]  = TR_LSM_Denoising(ori, Y, par)

[Nx,Ny,Nt] = size(Y);

tau = par.tau;
lambda1 = par.lambda1;
lambda2 = par.lambda2;
alpha = par.alpha; 
beta = par.beta; 
gamma = par.gamma; 
d = par.d;
rho = par.rho;
iter_x = par.iter_x;

% Initialization
Bx = zeros(Nx,Ny,Nt); 
By = zeros(Nx,Ny,Nt); 
B = zeros(Nx,Ny,Nt);
Dx = zeros(Nx,Ny,Nt); 
Dy = zeros(Nx,Ny,Nt); 
Z = Y; 
% X = Y; 
J = Y;

All_PSNR = zeros (1, par.Iter);
Denoising = cell (1,par.Iter);

for k = 1: par.Iter

    % Update X
    [Xnew] = UpdateXTen(Y,Z,Dx,Dy,B,Bx,By,alpha,beta,gamma,d,rho,iter_x,J);
    % RSE(k) = norm( Xnew(:) - X(:),2 )/norm(X(:));
    J = Xnew;  % 下一轮迭代的初始化
    X = Xnew;    
    
    % Update Z
    % [Znew, objV] = proxF_tSVD_1(X+B,tau/alpha,1);
    % [Znew, objV] = proxF_tSVD_GSM(X+B,tau/alpha,1);
    [Znew] = proxF_TR_Main(X+B, tau, alpha, par);
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

    Denoising{k} = Xnew;

    % fprintf('the Iter is  %d,  the RSE is  %f\n',k,RSE(k))
    
    [PSNR_iter] = evaluate_1(((ori - min(ori(:))) / (max(ori(:)) - min(ori(:))))*255,...
      ((Xnew - min(Xnew(:))) / (max(Xnew(:)) - min(Xnew(:))))*255);

    PSNR_iter = mean(PSNR_iter);


    All_PSNR (k) = PSNR_iter;     
    

    fprintf( 'TR_PnP: Iter = %d, PSNR = %2.2f\n', k, PSNR_iter);
     
    % % 提前停止迭代
    % if  k > 1
    % 
    %     if All_PSNR (k) - All_PSNR (k-1) <  0
    %         break;
    %     end
    % 
    % end     
    % 
end
 
end

