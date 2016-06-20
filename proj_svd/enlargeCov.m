function ret=enlargeCov(cov,incre)

[U,S,V]=svd(cov); % singular value decomposition

% enlarge with increment
S(1,1)=(sqrt(S(1,1))+incre)^2;
S(2,2)=(sqrt(S(2,2))+incre)^2;

ret=U*S*V;