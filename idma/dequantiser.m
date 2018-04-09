function[y2]=dequantiser(y1,n)
lenq=bitsrequired(2*n+1);
x=reshape(y1,lenq,numel(y1)/lenq)';
% x1=bin2dec(x>.5);
x1=bin2dec(num2str(x>.5));
y2=(x1-n)';