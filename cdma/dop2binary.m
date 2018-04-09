function[code3]=dop2binary(code1) %take code matrix & generate binary form
[r,w]=size(code1);
n=sum(code1(1,:));
for i=1:r
    for j=1:w
        if j==1
            code2(i,j)=1;
        end
        if j>1
            code2(i,j)=code2(i,j-1)+code1(i,j-1);
        end
    end
end
code2;
code3=zeros(r,n);
for k=1:r
    for l=1:w
        code3(k,code2(k,l))=1;
    end
end
clear r code1 i j code2 

