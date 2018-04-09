function[out]=spreader(code,x)%spreader
y=x'*code;
out=reshape(y,1,numel(y));