function [Xnew] = UpdateXTen(Y,Z,Dx,Dy,B,Bx,By,alpha,beta,gamma,d,rho,iter_x,J)

Xnew = zeros(size(Y));
Bz = zeros(size(Y));

thr = sqrt(rho/d);

for i = 1:size(Y,3)
    y = Y(:,:,i); 
    z = Z(:,:,i);
    
    dx = Dx(:,:,i); 
    
    dy = Dy(:,:,i);
    
    b  = B(:,:,i); 
    
    bx = Bx(:,:,i); 
    
    by = By(:,:,i);

    bz = Bz(:,:,i);
    j = J(:,:,i);

    for k=1:iter_x 
        
        jnew = FFD_Net_Denoiser (j - bz, thr); %FFDNet
        j = jnew/255;
        xnew = Updatex(y,z,j,b,bx,by,bz,dx,dy,alpha,beta,gamma,d);
        

        bz_new = bz - (j - xnew);
        bz = bz_new;

    end
    
    Xnew(:,:,i) = xnew;

end

end
