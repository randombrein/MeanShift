function [Ind,Dist]=cov2Ellipse(cov)

icov=inv(cov);  % inverse covariance       

[U,S,V]=svd(cov);

len=round(sqrt(S(1,1)))+2;  


% inverse covariance kernel trick?
k=0;
for i=-len:len              
    for j=-len:len
        t=[i,j]*icov*[i,j]';  % eigen vectors?
        if t<=1
            k=k+1;
            Ind(k,1)=i;            
            Ind(k,2)=j;            
            Dist(k)=t;             
        end
    end
end

% normalize
maxDist=max(Dist(:));
Dist=(maxDist-Dist)/maxDist;       

minDist=min(Dist(find(Dist~=0)));  

ind=find(Dist==0);                  
Dist(ind)=minDist;         