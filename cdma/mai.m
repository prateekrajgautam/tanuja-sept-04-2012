disp('this is to compare CDMA over awgn or UWawgn')
freshfigure=2;%  set this option 1 for fresh figure & 2 to plot fresh figure on previous plot
channel=2; %% set it 2 for ofdm under water channel with awgn noise or 1 for simple awgn channel


%% this section is for plotting results on same graph with different colors
if freshfigure==1
%     clear all
    close all
    plotcolor=['-b^';'-g*';'-ro';'-cx';'-ks';'-yd';'-mp';'-wh'];
    freshfigure=1;
    legname=[];
    marksize=10;
    linewidth=1;
    index=1;
    legname=[];
elseif freshfigure~=1
    clearvars -except legname marksize linewidth index ber1 ebn name plotcolor code channel
    hold on
    freshfigure=1;
    marksize=marksize+2;
    linewidth=linewidth+1;
    index=index+1
end

%% load date
name=['n=139,w=3,algo=1,dop=3151,jb=3151,la=1,lc=1,galgo=4,gsmax=23,gs=20,groups=2'];
[code]=loadcdmadata(name);


%% this section is for plotting results on same graph with different colors end
clc

%% user defined variables for idma starts
block=20;
n=16;                %no.of users
m=512;              %data length
itnum=5;            %no of iteration
ebnostart=0;        %step iteration
ebnostep=3;
ebnonum=8;
bits=m;




%% user defined variables for UW ofdm channel starts
if channel ==2
    %% uw ofdm channel parameters
    symbollength = 200e-3; %Length of the symbols
    bandwidth = 2560; %Bandwidth in Hz
    numberofcarriers = 512; %Number of carriers
    numberofsymbols = 20; %Number of OFDM symbols
    guard_time = 40e-3; %Guard_time in seconds
    plotuw = 0; %Plots figures if value is set to 1
    channel_delay = 0; %Delay in seconds
    phase_error = 0; %Phase error in radians
%     snr = 15; %The chosen SNR in dB for the channel -1 removes the noise
    impulseresponse = 0; %1: enable channel impulse response
    data_type=['random'];
    FS=192e3; %Sampling freq for under water channel
    fc = 38e3; %Carrier freq for under water channel
    N=numberofcarriers;
    M=numberofsymbols;
    
end
%% user defined variables for UW ofdm channel ends



%%



for z=1:ebnonum
    ebno=ebnostart+z*ebnostep;
    error=0;    
    for bloc=1:block 

        %% generate data
        % x=randint(users_max,bits);
        %% cdma
        block=2;
        % for n=8
        %     txdata=x(1:n,:);
            txdata=randint(n,bits);
            %% spreading
            for i=1:n
                y(i,:)=spreader(code(i,:),txdata(i,:));
            end
            %% multiplex
            txorig=+(multiplexer(y));



            %% select cnannel add awgn noise optional
            if channel==1
                channelname=['awgn']
                awgntx=awgn(txorig,ebno,'measured')>.5;
                tx=awgntx;
            elseif channel==2
                %% uw
                channelname=['uw awgn'];
                y1=[];
                ofdmdatain=[]
                tx=[];
                ofdmdatain=multiplexer(y)';
                [rof,cof]=size(ofdmdatain);
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
                    [DataOut,beruw]=OFDMRX;
                    y1=cat(2,y1,DataOut');
                end
                tx=y1(1,1:(length(y1)-appendofdm));
                [error,ber]=biterr(tx',txorig');
            end



            %% reciever end
            for j=1:n
                c=length(code(1,:));%we know the codelength at reciever end
                r=numel(tx)/c;
                rx1=reshape(tx,r,c);
            end

            %% despreading 
            for k=1:n
                rx(k,:)=zeros(1,bits);%initialize
                rx(k,:)=despreador(code(k,:),rx1);
            end

            %% check error & ber
            [error,ber]=biterr(txdata',rx')
%             [error,ber]=errortx(txdata,rx)
            ebn(index,z)=ebno;
            
        %display progress stats
        [z,bloc,ebno,ber]
    end
    ber1(index,z)=ber;
end

%% ========================================================================
%% plotting result start
   semilogy(ebn(index,:),ber1(index,:),plotcolor(index,:),'LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','c',...
                'MarkerSize',marksize)           
    xlabel('Eb/No')
    ylabel('Bit Error Rate')
    grid on
    hold on
    if index==1
       name=['cdma,no_of_users=' num2str(n) ',datalength=' num2str(m)];
       lname=[channelname  ',users=' num2str(n)];
    elseif index>1
       name=[' compare,cdma,no_of_users=' num2str(n) ',datalength=' num2str(m) ];
       lname=[channelname ',users=' num2str(n) ];
    end
    legname{index}=lname;%cat(1,legname,{[lname ',']})
    legend(legname)
     saveas(gcf,'compare cdma awgn vs uw','jpg')



    