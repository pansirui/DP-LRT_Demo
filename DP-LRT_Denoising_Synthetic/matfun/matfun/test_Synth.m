clear all
close all
clc

%% generate synthetic data
%plane1
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
plane3=ricker_mada(plane3,0.002,10);  

dc=plane1+plane2+plane3;
dc=yc_scale(dc,3);
%figure;imagesc(squeeze(dc(:,:,1))');     %%干净的图像


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
figure;imagesc(squeeze(dn(100,:,:)));title('ori','Interpreter','none')   
noise = dn-dc;
s_cplot(squeeze(noise(100,:,:)))
xlabel('Inline') 
ylabel('Crossline') 
set (gcf,'Position')
set(gca, 'Position');
caxis([-0.1,0.1])
% figure;imagesc(squeeze(noise(100,:,:)))
%% see the data
%figure;imagesc([squeeze(dc(100,:,:)),squeeze(dn(100,:,:))]);colormap(seis);
%figure;imagesc([dc(:,:,9),dn(:,:,9)]);colormap(seis);

% % denoise by DRR
% flow=0;fhigh=125;dt=0.004;N=3;verb=1;
% d1=fxydmssa(dn(:,:,:),flow,fhigh,dt,N,6,verb);
% DRR_noise = dn-d1;
% figure;imagesc(DRR_noise(100,:,:)');title('DRR_noise','Interpreter','none')
% figure;imagesc(d1(100,:,:)');title('DRR','Interpreter','none')
% yc_snr(squeeze(dc(100,:,:)),squeeze(d1(100,:,:)))   %%计算信噪比  
%% denoise by KSVD
%d=squeeze(dn(100,:,:));
d=squeeze(dn(:,:,20));

l1=8;l2=8;s1=4;s2=4;
c1=8;c2=16;%size of the 1D cosine dictionary (if c2>c1, overcomplete)
%% DCT dictionary (dctmtx will generates orthogonal transform)
dct=zeros(c1,c2);
for k=0:1:c2-1
    V=cos([0:1:c1-1]'*k*pi/c2);
    if k>0
        V=V-mean(V);
    end
    dct(:,k+1)=V/norm(V);
end
DCT=kron(dct,dct);%2D DCT dictionary (64,256)

%% Denoising by KSVD
%param naming following Chen, 2017, GJI; Zhou et al., 2020
K=64;
param.T=3;      %sparsity level
param.D=DCT;    %initial D
param.niter=10; %number of K-SVD iterations to perform; default: 10
param.mode=1;   %1: sparsity; 0: error
%param.exact:   Exact K-SVD update or approximate
param.K=64;     %number of atoms, dictionary size
%for X=DG


%% Option 1: denoise only using the integrated function
param=struct('T',3,'niter',10,'mode',1,'K',64,'D',DCT);
mode=1;l1=8;l2=8;s1=4;s2=4;perc=7;

%% compare performance of two dictionaries
T=3;perc=100;
[n1,n2]=size(d);
%% residual learning    这个不需要
X=yc_patch(d,mode,l1,l2,s1,s2);
[D,G]=yc_ksvd(X,param);
% G2=yc_ompN(D,X,T);
% X2=D*G2;
% d3=yc_patch_inv(X2,mode,n1,n2,l1,l2,s1,s2);
% figure;imagesc([squeeze(dn(100,:,:)),squeeze(d3(100,:,:))]);colormap(seis);
% figure;imagesc([d,d3,d-d3]);title('residual_learn','Interpreter','none')


%% filtered dictionary
%stronger
DD=zeros(size(D));
for ia=1:64
    DD(:,ia)=reshape(yc_mfs(reshape(D(:,ia),l1,l2),2,1,1,4),l1*l2,1);
    DD(:,ia)=reshape(yc_mfs(reshape(DD(:,ia),l1,l2),2,1,2,4),l1*l2,1);
end
%weaker
DDD=zeros(size(D));
for ia=1:64
    DDD(:,ia)=reshape(yc_mfs(reshape(D(:,ia),l1,l2),2,1,1,2),l1*l2,1);
    DDD(:,ia)=reshape(yc_mfs(reshape(DDD(:,ia),l1,l2),2,1,2,2),l1*l2,1);
end

%% residual DL    这个也不需要
% G22=yc_ompN([DD,D-DD],X,3);
% X22=DD*G22(1:K,:);
% d33=yc_patch_inv(X22,mode,n1,n2,l1,l2,s1,s2);
% d33_noise = d-d33;
% figure;imagesc(d33_noise');
% figure;imagesc(d33');title('residual_DL','Interpreter','none')
% yc_snr(squeeze(dc(:,:,1)),squeeze(d33(:,:)))   %计算信噪比

%% residual DL + statistics guided
natom=K;
% k=kurtosis(D);%16.6513 N=21; 16.9889 N=22; 17.1545 N=23; 17.3897 N=24; 17.6918 N=25; 17.1196 N=26
% k=yc_kurtosis2(D,l1,l2);
k=yc_var2(D,l1,l2);
[ks,ii]=sort(k,'descend');
% figure;stem(ks);
% ks_ratio=[ks(1:end-1)./ks(2:end)];% ks_dif=diff(ks);figure;stem(ks_dif);
% figure;stem(ks_ratio);
perc=15;%works fine
% perc=90;%works perfectly? I think so.
tt=round(natom*(100-perc)/100);
inds=ii(1:tt);
% 
% D_o1=D;
% D_o1(:,inds)=0;
% figure('units','normalized','Position',[0.2 0.4 0.6, 0.8]);
% for ia=1:64
%     subplot(8,8,ia);imagesc(reshape(D(:,ia),l1,l2));colormap(jet);
%     set(gca,'Linewidth',1.5,'Fontsize',16);
%     set(gca,'xticklabel',[]);set(gca,'yticklabel',[]);
% end
% 
% figure('units','normalized','Position',[0.2 0.4 0.6, 0.8]);
% for ia=1:64
%     subplot(8,8,ia);imagesc(reshape(D_o1(:,ia),l1,l2));colormap(jet);
%     set(gca,'Linewidth',1.5,'Fontsize',16);
%     set(gca,'xticklabel',[]);set(gca,'yticklabel',[]);
% end

%DD_o=D;
DD_o=DDD;
DD_o(:,inds)=DD(:,inds);
G22_o=yc_ompN([DD_o,D-DD_o],X,3);
X22_o=DD_o*G22_o(1:K,:);
d33_o=yc_patch_inv(X22_o,mode,n1,n2,l1,l2,s1,s2);
s_cplot(d33_o)
xlabel('Inline') 
ylabel('Crossline') 
set (gcf,'Position')
set(gca, 'Position');

noie_SG = d-d33_o;
s_cplot(noie_SG)
xlabel('Inline') 
ylabel('Crossline') 
set (gcf,'Position')
set(gca, 'Position');
caxis([-0.1,0.1])
% figure;imagesc(noie_SG);
% figure;imagesc(d33_o);title('residual_DL_SG','Interpreter','none')
yc_snr(squeeze(dc(:,:,20)),squeeze(d33_o(:,:)))     %%% 


%% without residual DL   效果很差 基本没有意义
% G222=yc_ompN([DD],X,12);
% X222=D*G222(1:K,:);
% d333=yc_patch_inv(X222,mode,n1,n2,l1,l2,s1,s2);
% %figure;imagesc([d,d333,d-d333]);colormap(seis);

%with mf  面20
d44=yc_mfs(d',4,1,1,1);
s_cplot(d44')
xlabel('Inline') 
ylabel('Crossline') 
set (gcf,'Position')
set(gca, 'Position');

noise_d44 = d'-d44;
s_cplot(noise_d44')
xlabel('Inline') 
ylabel('Crossline') 
set (gcf,'Position')
set(gca, 'Position');
caxis([-0.1,0.1])
yc_snr(squeeze(dc(:,:,20))',squeeze(d44(:,:)))

% %%%  with  mf  面100
% d44=yc_mfs(d,4,1,1,1);
% s_cplot(d44)
% xlabel('Inline') 
% ylabel('Crossline') 
% set (gcf,'Position')
% set(gca, 'Position');
% 
% noise_d44 = d-d44;
% s_cplot(noise_d44')
% xlabel('Inline') 
% ylabel('Crossline') 
% set (gcf,'Position')
% set(gca, 'Position');
% caxis([-0.1,0.1])
% yc_snr(squeeze(dc(100,:,:)),squeeze(d44(:,:)))

% %% denoise by DRR
% flow=0;fhigh=125;dt=0.004;N=3;verb=1;
% d2222=fxydmssa(dn,flow,fhigh,dt,N,6,verb);
% s_cplot(squeeze(d2222(100,:,:)))
% % s_cplot(squeeze(d2222(:,:,20)))
% xlabel('Inline') 
% ylabel('Crossline') 
% set (gcf,'Position')
% set(gca, 'Position');
% 
% noise_d2222 = dn-d2222;
% s_cplot(squeeze(noise_d2222(100,:,:)))
% % s_cplot(squeeze(noise_d2222(:,:,20)))
% % yc_snr(squeeze(dc(:,:,20)),squeeze(d2222(:,:,20)))
% xlabel('Inline') 
% ylabel('Crossline') 
% set (gcf,'Position')
% set(gca, 'Position');
% caxis([-0.1,0.1])
% % % figure;imagesc(squeeze(noise_d2222(100,:,:)));
% % % figure;imagesc(squeeze(d2222(100,:,:)));title('DRR','Interpreter','none')
% yc_snr(squeeze(dc(100,:,:)),squeeze(d2222(100,:,:)))


























