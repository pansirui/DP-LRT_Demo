clear all
close all
clc

n1=400;n2=150;n3=40;
t1=150;p11=0;p12=0;
plane1=zeros(n1,n2,n3);
for i2=1:n2
    for i3=1:n3
        
        t=floor(t1+p11*i2+p12*i3);
        plane1(t,i2,i3)=1;
    end
end
plane1=ricker_mada(plane1,0.002,10);

%plane2
n1=400;n2=150;n3=40;
t2=20;p21=2;p22=2;
plane2=zeros(n1,n2,n3);
for i2=1:n2
    for i3=1:n3
        
        t=floor(t2+p21*i2+p22*i3);
        plane2(t,i2,i3)=1;
    end
end
plane2=ricker_mada(plane2,0.002,10);

%%plane3
n1=400;n2=150;n3=40;
t3=400;p31=-2;p32=-2;
plane3=zeros(n1,n2,n3);
max=0;
for i2=1:n2
    for i3=1:n3
        
        t=floor(t3+p31*i2+p32*i3);
        if max<t
            max=t;
        end
        plane3(t,i2,i3)=1;

    end
end
plane3=ricker_mada(plane3,0.002,10);   %ÆµÓòÂË²¨

dc=plane1+plane2+plane3;
dc=yc_scale(dc,3);
%figure;imagesc(squeeze(dc(:,:,1))');     %%¸É¾»µÄÍ¼Ïñ


%% adding random noise
% randn('state',201314);
% var=0.2;
% % dn=d+var*randn(size(d));
% n=0.02*randn(size(dc));

%% adding footprint noise
[nt,nx,ny]=size(dc);
x=[0:nx-1];
y=sin(10*x);
noise2d=y(:)*ones(1,ny);

noise3d=zeros(nt,nx,ny);
for it=0:nt-1
    noise3d(it+1,:,:) = noise2d*0.1^(it/(nt-1));
end

dn=dc+noise3d*0.1;

d=squeeze(dn(100,:,:));
figure;imagesc(d);title('ori','Interpreter','none')   
noise = dn-dc;
figure;imagesc(squeeze(noise(100,:,:)))

d44=yc_mfs(d,4,1,1,1);
noise_d44 = d-d44;
figure;imagesc(d44);title('MF','Interpreter','none')  
figure;imagesc(noise_d44);
yc_snr(squeeze(dc(100,:,:)),squeeze(d44(:,:)))


% noise_MF = dn-d44;
% figure;imagesc(squeeze(noise_MF(:,:,1))');
% figure;imagesc(squeeze(d44(:,:,1))');title('MF','Interpreter','none')
% yc_snr(squeeze(dc(:,:,1)),squeeze(d44(:,:)))