%% this section is for plotting results on same graph with different colors

freshfigure=1;%  set this option 1 for fresh figure & 2 to plot fresh figure on previous plot

if freshfigure==1
    clear all
    close all
    plotcolor=['-b^';'-g*';'-ro';'-cx';'-ks';'-yd';'-mp';'-wh'];
    freshfigure=1;
    legname=[];
    marksize=10;
    linewidth=1;
    index=1;
    legname=[];
elseif freshfigure~=1
    clearvars -except legname marksize linewidth index ber1 ebn name plotcolor
    hold on
    freshfigure=1;
    marksize=marksize+2;
    linewidth=linewidth+1;
    index=index+1
end

%% this section is for plotting results on same graph with different colors end
clc

%% user defined variables for idma starts
block=1;
n=16;                %no.of users
m=1024;              %data length
sl=32;              %spread length
chiplen=m*sl;       %chip length
itnum=5;            %no of iteration
ebnostart=0;        %step iteration
ebnostep=3;
ebnonum=5;
M=2;% to start first while loop 
b=bitsrequired(M);%
useenergyprofile=0;%set useenergyprofile to one(1) to use useenergyprofile  else set it to 2
%% user defined variables for idma ends


if useenergyprofile==1% energy profile power for n users in ep
    ep=interleavor(energyprofile(n,1,3.4523),idmascramble(1,n));
end

modulationname='idma';
hk=ones(1,n);%assume we know h_k required for idma decoder

%% idma 
spreadingunipolar=spreadingsequece(sl,[1,0]);%spreading sequence producing {1,0,1,0--------}
spreading=2*spreadingunipolar-1;
scrambrule=idmascramble(n,chiplen); %interleaver design

channel=2; %% set it 2 for ofdm under water channel with awgn noise or 1 for simple awgn channel

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
    snr = 15; %The chosen SNR in dB for the channel -1 removes the noise
    impulseresponse = 0; %1: enable channel impulse response
    data_type=['random'];
    FS=192e3; %Sampling freq for under water channel
    fc = 38e3; %Carrier freq for under water channel
    N=numberofcarriers;
    M=numberofsymbols;
    
end
%% user defined variables for UW ofdm channel ends




%% the simulation process begins, this section repeats calculations for diferent snr for different blocks & then take average
for z=1:ebnonum
    ebno=ebnostart+z*ebnostep;
    snruw(z)=ebno;
    snr(z)=(10.^(ebno/10))/sl;
    sigma=sqrt(0.5/snr(z));
    error=0;    
    for bloc=1:block 
%% ========================================================================
%%      transmitter
        %% transmitter section begins
        data=randint(n,m,[1,0]);%generation of random bipolar data    
        chip=spreador(spreadingunipolar,data);   
        transmit1=interleavor(chip,scrambrule);%transmitting data interleavor   
        %% bpsk encoder to transmit & apply energy profile
            if useenergyprofile==1
                transmittemp=2*((transmit1)>0)-1;
                for zz=1:n
                    transmit2(zz,:)=ep(1,zz)*transmittemp(zz,:);
                end
            else
                transmit2=2*((transmit1)>0)-1;
            end
        %% idma multipleser (sum)
            tx3=sum(transmit2);
        %% normaliser & quantiser
            [tx4,lenq]=quantiser(tx3,n);
            
            

            
            
            
            
%% ========================================================================
%%                      channel
        %% select awgn channel or under water awgn channel
        switch channel
            case 1% awgn channel
                channelname=['awgn'];
                y0=channelnoise(tx4,ebno);
            otherwise 
                channelname=['uw awgn'];
                y1=[];
                ofdmdatain=tx4';
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
                y0=y1(1,1:(length(y1)-appendofdm));
        end
        
                





%% ========================================================================
%%                     reciever
        %% threshold,dequantiser & denormalizer
            y2=dequantiser(y0,n);
        %% idma decoder
        appllr=idmadecoderbpsk(sigma,hk,n,m,sl,itnum,chiplen,y2,spreading,scrambrule);
        e=0;
        appllrf=appllr>0;% decision whether 1 or 0 is recieved
        decodeddata=appllrf;
        [e,bertemp]=errortx(data,decodeddata);% check error
        error=error+e;       
        ber=(error/(n*m*bloc));
        
        %display progress stats
        [z,bloc,ebno,ber]
    end
    %store result for one iteration
    ebn(index,z)=ebno;
    ber1(index,z)=ber;
end

%% ========================================================================
%% plotting result start
%    semilogy(ebn(index,:),ber1(index,:),plotcolor(index,:),'LineWidth',2,...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor','c',...
%                 'MarkerSize',marksize)           
%     xlabel('Eb/No')
%     ylabel('Bit Error Rate')
%     grid on
%     hold on
%     if index==1
%        name=[channelname ' ' modulationname '_with_M=' num2str(M) ',no_of_users=' num2str(n) ',datalength=' num2str(m) ',spreadinglength=' num2str(sl) ',useenergyprofile=' num2str(useenergyprofile) ];
%        lname=[channelname  ',users=' num2str(n)];
%     elseif index>1
%        name=[' compare' channelname ' ' modulationname '_with_M=' num2str(M) ',no_of_users=' num2str(n) ',datalength=' num2str(m) ',spreadinglength=' num2str(sl) ',useenergyprofile=' num2str(useenergyprofile) name ];
%        lname=[channelname ',users=' num2str(n) ];
%     end
%     legname{index}=lname;%cat(1,legname,{[lname ',']})
%     legend(legname)
if sum(ber1(index,:)==0)==0
    a=[];
    b=[];
    a=polyfit([1:length(ber1(index,:))],ber1(index,:),2);
    b=polyval(a,[1:length(ber1(index,:))]);
    semilogy(ebn(index,:),b,plotcolor(index,:),'LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','c',...
            'MarkerSize',marksize)       
elseif sum(ber1(index,:)==0)>0
        semilogy(ebn(index,:),ber1(index,:),plotcolor(index,:),'LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','c',...
            'MarkerSize',marksize)  
end

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
 saveas(gcf,'compare idma awgn vs uw','jpg')
 saveas(gcf,'compare idma awgn vs uw','fig')
 save('tempdataidma')
%% plotting result ends



%display final result 
    ber1
    ebn

    
%% save figure & data 
    saveas(gcf,name,'jpg');
    save(name);