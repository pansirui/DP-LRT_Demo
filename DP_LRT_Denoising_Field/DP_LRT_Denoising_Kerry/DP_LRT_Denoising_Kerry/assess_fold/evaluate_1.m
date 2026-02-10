function [PSNRvector] = evaluate_1(OriData3,output_image)
p = size(OriData3,3);
PSNRvector=zeros(1,p);
for i=1:1:p
    J=OriData3(:,:,i);

    I=output_image(:,:,i);

      PSNRvector(1,i)=csnr (J, I, 0,0);
end
end