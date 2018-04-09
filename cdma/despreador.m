function[out]=despreador(code1,rx2)
%despreador(code,recieved_stream)
a=[];
[r,c]=size(rx2);
w=sum(code1);
for i=1:r
    aa=and(code1,rx2(i,:));
    a(i,1)=sum(aa);
end
b=a';
out=zeros(1,r);
for i=1:r
    if b(1,i)>=w
        out(1,i)=1;
    end
end