function [U, S, V] = takeSVDs(U,S,V,A,endI,runPar)
% U is 400*400*40
% S is 400*150*40
% V is 150*150*40
% A is 400*150*40
% endI is 21
% runPar is 0

if ~exist('runPar','var')
    runPar = false;
end
    
if ~runPar || parpool('size') == 0

    for i=1:endI
        [U1,S1,V1]=svd(A(:,:,i));
        % U1 is400*400
        % S1 is 400*150
        % V1 is 150*150
        U(:,:,i)=U1; S(:,:,i)=S1; V(:,:,i)=V1;
    end
else
    
    parfor i=1:endI
        [U1,S1,V1]=svd(A(:,:,i));
        U(:,:,i)=U1; S(:,:,i)=S1; V(:,:,i)=V1;
    end
end

end