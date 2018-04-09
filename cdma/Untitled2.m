ofdmdatain=[]
tx=[];
y1=[];
txorig=multiplexer(y)'
ofdmdatain=multiplexer(y)'
appendofdm=0
[rof,cof]=size(ofdmdatain)
buffersize=2*M*N;
loop=rof/buffersize;
overhead=mod(rof,buffersize);
if overhead>0
    appendofdm=buffersize-mod(rof,buffersize);
    ofdmdatain=cat(1,ofdmdatain,zeros(appendofdm,1));
    [rof,cof]=size(ofdmdatain);
    loop=rof/buffersize;
end
range2=0;                    
for iof=1:loop
    if iof==1
        plots=0;
        if z==3
            if plotuw==1
                plots=1;
                plotuv=0;
            end
        end
    else
        plots=0;
    end
    range1=range2+1;
    range2=iof*rof/loop;
    DataIn=ofdmdatain(range1:range2,1);
    OFDMTX(symbollength, bandwidth, guard_time, 'random', numberofcarriers,numberofsymbols,FS,fc, plots,DataIn);
    OFDMchannel(channel_delay, ebno, phase_error, impulseresponse);
    [DataOut,beruw]=OFDMRX
    y1=cat(2,y1,DataOut');
end
tx=y1(1,1:(length(y1)-appendofdm));
[error,ber]=biterr(tx',txorig)