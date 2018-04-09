function[out]=multiplexer(in)%multiplexer
[r c]=size(in);
for i=1:r
    if i==1
        out=in(i,:);
    end
    if i>1
       out=or(out,in(i,:));
    end
end