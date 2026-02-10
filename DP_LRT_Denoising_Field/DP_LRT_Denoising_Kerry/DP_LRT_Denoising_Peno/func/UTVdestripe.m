%%% 注: 算法均对水平条带进行处理
%%% 求解 u 时利用 FFT
function u = UTVdestripe(f,I,alpha,belta,lamda,omega1,omega2,MaxIter)

[N1,N2] = size(f);
%%% 初始化 %%%
u = f; % 给解赋初值
g = f; % 观测值
% Psix = zeros(size(f));
% Psiy = zeros(size(f));

k = 0;
Tol = 1e-4;  %%% 迭代容许误差
StopFlag = 0;
Psix = 0;
Psiy = 0;
bx = 0;
by = 0;
[M,N] = size(f);
ep = 1e-6;


%%% compute fixed quantities
[conjoDx,conjoDy,num1,Denom1,Denom2] = getC(g);
%%% 主循环 
while StopFlag == 0,

    k = k + 1;
     %%% (3) 使用FFT更新解 u
    FPsix = fft2( Psix - bx );
    FPsiy = fft2( Psiy - by );
    FGPx = conjoDx .* FPsix;
    FGPy = conjoDy .* FPsiy; 
    Denom = alpha*Denom1 + belta*Denom2 + 2*omega1*fft2(eye(1));   
    Fu = ( alpha*num1 + alpha* FGPx + belta*FGPy + 2*omega1*fft2(g))./(Denom+ep) ; %%% 出现分母除零情况
    unew = real( ifft2( Fu ) ); % compute new u
%   unew(unew<0)=0;
    udiff = norm( unew(:) - u(:),2 )/norm(u(:));
    u = unew;

    %%% (1) 求分离变量 Psix
    temp = diff(u-g,1,2);
    dx = [temp temp(:,N2-1)];   % column diff
    Psixnew = shrink(dx+bx,omega2/alpha);

    
    %%% (2) 求分离变量 Psiy
    temp1 = diff(u,1,1);
    dy = [temp1;temp1(N1-1,:)];
    Psiynew = shrink(dy+by,(lamda/belta));

    %%% 更新分离变量 Psix, Psiy
    Psix = Psixnew;
    Psiy = Psiynew;
    
    %%% 更新 bx, by
    bx = bx +  (u(:,[2:N,N]) - u) - (g(:,[2:N,N])- g) - Psix;
    by = by + u([2:M,M],:)- u - Psiy;
    
    %%% Stopping criterions
    if k >= MaxIter
        StopFlag = 1;
    elseif udiff <= Tol
        StopFlag = 2;
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [conjoDx,conjoDy,num1,Denom1,Denom2] = getC(g)
% compute fixed quantities
sizeI = size(g);
% otfDx = psf2otf([1,0;0 0;0 0;0 0;0 0;0 0;0 -1],sizeI);
% otfDy = psf2otf([0 0 0 0 0 0 -1;1 0 0 0 0 0 0],sizeI);
% otfDx = psf2otf([0,1;0 0;-1 0],sizeI);
% otfDy = psf2otf([1 0 0;0 0 -1],sizeI);
% otfDx = psf2otf([0,1;-1,0],sizeI);
% otfDy = psf2otf([1 0;0 -1],sizeI);
otfDx = psf2otf([1,-1],sizeI);
otfDy = psf2otf([1;-1],sizeI);
conjoDx = conj(otfDx);
conjoDy = conj(otfDy);
num1 = abs(otfDx).^2.*fft2(g);
Denom1 = abs(otfDx).^2;
Denom2 = abs(otfDy).^2;
