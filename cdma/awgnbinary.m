function[y2]=awgnbinary(y,s)
%y=awgnbinary(y,snr)
y2=awgn(y,s);
[r,c]=size(y2);
% th=sum(sum(y))/numel(y);
th=.5;
for i=1:r
    for j=1:c
        if y2(i,j)>th
            y2(i,j)=1;
        end
        if y2(i,j)<=th
            y2(i,j)=0;
        end
    end
end
end