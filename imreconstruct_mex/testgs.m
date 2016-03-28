% mex-compiling.....
mex vincent11.c;
mex vincent12.c;
%-----> have you saved  vincent11.c and vincent12.c ????

clear all;
dim=1024;
% mask
a=fix(2^8*rand(dim));
% marker
b=fix(2^8*rand(dim));
b=a-b;
minorezero=find(b<0);
b(minorezero)=0;

a=uint8(a);
b=uint8(b);
%-----> now a and b (a is the mask and b is the marker )
%       are two uint8 random matrices 
% NOTE
% a(ii,jj)>b(ii,jj) for every ii,jj
% this is the initial assumption of the algorithm

tic;
risultato=imreconstruct(b,a,8);  %--------> matlab implementation
t1=toc




tic;
a1=vincent11(a,b,8);%--------------> our implementation of Vincent's algorithm
t2=toc

% now I plot the difference beetwen the 2 results 
% to verify the accuracy
%       :-)
%    !!!!!!!!!!!!!!
% but I have to transorm the 2 matrices from 
% uint8 to double in order to perform calculations
% (in fact uint8 does not support all matlab's matrix functions
nnz(double(risultato)-double(a1))





