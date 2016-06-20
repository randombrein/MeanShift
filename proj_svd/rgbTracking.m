function [x_0,y_0,Cov,BhattCoff,iterations,p_u]=rgbTracking(image,...
    imgWidth,imgHeight,centerX,centerY,...
    q_u,candidate_pos,candidateKernel,...
    omega,frameNo)

MAX_ITER=15;
EPSILON=0.05;

redBins=16;
greenBins=16;
blueBins=16;

rb=256/redBins;
gb=256/greenBins;
bb=256/blueBins;

iterations=0;

x_0=centerX;
y_0=centerY;

x_0r=centerX;
y_0r=centerY;

delta_x=0;
delta_y=0;
sum_p=0;

N=size(candidate_pos,1);
while 1

    %
    % calculate distribution
    %
    histo=zeros(redBins,greenBins,blueBins);
    for n=1:N
        %
        col=candidate_pos(n,1)+x_0;
        row=candidate_pos(n,2)+y_0;
        %
        if (row>=1 && row<=imgHeight && col>=1 && col<=imgWidth)
            R=floor(image(row,col,1)/rb)+1;
            G=floor(image(row,col,2)/gb)+1;
            B=floor(image(row,col,3)/bb)+1;
            histo(R,G,B)=histo(R,G,B)+candidateKernel(n);
        end
    end

    p_u=zeros(1,redBins*greenBins*blueBins);
    for i=1:redBins
        for j=1:greenBins
            for k=1:blueBins
                index=(i-1)*greenBins*blueBins+(j-1)*blueBins+k;
                p_u(index)=histo(i,j,k);
            end
        end
    end

    p_u=p_u/sum(p_u);

    %
    % calculate weights
    %
    w_i=zeros(1,N);
    x=zeros(2,N);
    for n=1:N
        col=candidate_pos(n,1)+x_0;
        row=candidate_pos(n,2)+y_0;

        if (row>=1 && row<=imgHeight && col>=1 && col<=imgWidth)
            R=floor(image(row,col,1)/rb)+1;
            G=floor(image(row,col,2)/gb)+1;
            B=floor(image(row,col,3)/bb)+1;
            u=(R-1)*greenBins*blueBins+(G-1)*blueBins+B;
            x(1,n)=col;
            x(2,n)=row;
            a=sqrt(q_u(u));
            b=sqrt(p_u(u));
            w_i(n)=a/b;
        end
    end

    y_1=x*w_i'/sum(w_i);
    delta_x=y_1(1)-x_0r;
    delta_y=y_1(2)-y_0r;

    % iteration limit
    iterations=iterations+1;
    if (sqrt(delta_x^2+delta_y^2)<EPSILON || iterations>MAX_ITER)
        break;
    end

    x_0r=y_1(1);
    y_0r=y_1(2);

    x_0=round(x_0r);
    y_0=round(y_0r);

    sum_p=0;

end % end-while

% calculate BhattCoff
BhattCoff=sqrt(q_u)*sqrt(p_u)';


% calculate covariance
sumW_i=sum(w_i(:));

Dxx=w_i*((x(1,:)-x_0)'.^2)/sumW_i;
Dyy=w_i*((x(2,:)-y_0)'.^2)/sumW_i;
Dxy=w_i*((x(1,:)-x_0)'.*(x(2,:)-y_0)')/sumW_i;

k=(BhattCoff-1)/omega;
c=exp(k);

area=sumW_i*c;

C=[Dxx,Dxy;Dxy,Dyy];
[U,S,V]=svd(C);
l1=sqrt(S(1,1));
l2=sqrt(S(2,2));

s2=area/(pi*l1*l2);

S=s2*S;
Cov=U*S*V;
return;
