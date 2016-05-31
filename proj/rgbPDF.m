function q_u=rgbPDF(image,cenX,cenY,indX,indY)

% default color quant sheme (fixed in this demo)
redBins=16;greenBins=16;blueBins=16;

rb=256/redBins;
gb=256/greenBins;
bb=256/blueBins;

fDist=(indX-cenX).^2+(indY-cenY).^2;
maxD=max(fDist)+1;
fDist=maxD-fDist;

N=size(indX,1);


histo=zeros(redBins,greenBins,blueBins); % feature spaces,quantifized bins are 16-16-16
for i=1:N
    R=floor(image(indY(i),indX(i),1)/rb)+1;
    G=floor(image(indY(i),indX(i),2)/gb)+1;
    B=floor(image(indY(i),indX(i),3)/bb)+1;
    histo(R,G,B)=histo(R,G,B)+fDist(i);
end

q_u=zeros(1, redBins*greenBins*blueBins);
for i=1:redBins
    for j=1:greenBins
        for k=1:blueBins
            idx=(i-1)*greenBins*blueBins+(j-1)*blueBins+k;
            q_u(idx)=histo(i,j,k);
        end
    end
end

q_u=q_u/sum(q_u);  % normalize
return;
