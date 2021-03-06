function [fpars,t,strain,F,L,rob,chain,dsPts, vel]=analyzeEntangleFileMM(fold,fname,FTfreq,varargin)
%fpars = params from files [type,strain,width,del,spd,its,version
%time in seconds
%strain, unitless
%F in newtons
%L in meters
%chain end pts in meters
%dsPts [time1,strain1,idx1;time2,strain2,idx2] strain start and endpts

smartWidth=5.3; %5.4 cm for center link width
%6.4 cms from back to arm tip in u-shape
mag=0;
if [varargin{:}]
    if(varargin{1})
     mag=1;
    end
end
    
    
% ftFreq=1000;
ft=importdata(fullfile(fold,fname));
[t_op,z_op]= getOptiDataMM(fullfile(fold,['OPTI_',fname]));
t=[1:length(ft(:,2))]'./FTfreq;
F=ft(:,3);%y+ is backwards

z_op=fillmissing(z_op,'linear');
F=fillmissing(F,'linear');

%fix timing between scripts optitrack starts slightly first
dd=t_op(end)-t(end);

%old way of doing thiss
% dd_ind=find(dd<t_op,1,'first');
% t_op=t_op(dd_ind:end)-t_op(dd_ind);
% z_op=z_op(dd_ind:end,:);


% %fix timing between scripts optitrack starts slightly first
% dd=t_op(end)-t(end);
% if dd>0 %op runs longer
% %cut beginning off op
% dd_ind=find(abs(dd)<t_op,1,'first');
% t_op=t_op(dd_ind:end)-t_op(dd_ind);
% z_op=z_op(dd_ind:end)-z_op(dd_ind);
% else %ft runs longer
% dd_ind=find(abs(dd)<t,1,'first');
% t=t(dd_ind:end)-t(dd_ind);
% F=F(dd_ind:end)-F(dd_ind);
% end


%interpolate chain opti to length of FT data
chain=interp1(t_op,z_op(:,1),t,'linear','extrap');
chain(:,2)=interp1(t_op,z_op(:,2),t,'linear','extrap');

%interpolate robot opti dat to length of FT data
rob=interp1(t_op,z_op(:,3),t,'linear','extrap')/smartWidth;

%get initial length of chain
L=diff(chain,1,2);
L0=L(1);

strain=[(L-L0)/L0]';


%get parameters from file
[~,fpars]=parseFileNames(fname);
fpars(2)=fpars(2)/1000; %put strain in meters
fpars(3)=fpars(3); %put system (H) width in smart widths
figure(1000);
clf;
hold on;
h=plot(t,rob);
%[strainT,strainY,~,idx]
dsPts=zeros(fpars(6)*2,3); %time1,strain1,idx1
% [dsPts(:,1),dsPts(:,2),~,dsPts(:,3)]=MagnetGInput(h,fpars(6)*2,1);
if(mag)
[dsPts(:,1),dsPts(:,2),~,dsPts(:,3)]=MagnetGInput(h,fpars(6)*2,1);
else
    np=fpars(6)*2;
    x=linspace(0,1,length(t))';
    expMult=1.5;
    peakdisk=1.9;
    peakProm=.005;
    totalPts=fpars(6)*2;
    pys=rob.*exp(1-(expMult*x)); % fpars(6)/2
    pys=pys./max(pys);
    
    pye=rob.*exp(expMult*x);%fpars(6)/2
    pye=pye./max(pye);
    
    
    ns=rob-nanmean(rob);
    mys=-ns.*exp(1-(expMult*x));%fpars(6)/2+1
    mys=mys+-1*min(mys);
    mys=mys./max(mys);
    
    pts(fname);
    
    mye=-ns.*exp(expMult*x);%fpars(6)*2-(fpars(6)*3/2+1) mye(10
    mye=mye./max(mye);%fpars(6)*2-(fpars(6)*3/2+1) mye(10
    check=0;
    
    dsPts(1,3)=1;
    
    [~,a]=findpeaks(pys,'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*peakdisk);
    if(length(a)~=fpars(6)/2)
        warning('didn''t find enough points in pys')
    end
    dsPts(2:4:np,3)=a;
    
    % if(check)
    % findpeaks(pys,'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*1.05);
    % pause;
    % clf;
    % end
    
    
    [~,b]=findpeaks(pye,'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*peakdisk);
    dsPts(3:4:np,3)=b;
    if(length(b)~=fpars(6)/2)
        warning('didn''t find enough points in pye')
    end
    % if(check)
    % pause;
    % clf;
    % end
    
%     if ismember(fpars(end),[112])
%         [~,c]=findpeaks(mys(2000:end),'minpeakprominence',0.015,'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*peakdisk,'threshold',.001);
%     elseif ismember(fpars(end),[169])
%         [~,c]=findpeaks(mys(2000:end),'minpeakprominence',0.016,'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*peakdisk,'maxPeakHeight',.9);
%     else
        [~,c]=findpeaks(mys(2000:end),'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*peakdisk);
        
%     end
    
    dsPts(4:4:np,3)=c+1999;
    % pause;
    if(length(c)~=fpars(6)/2)
        warning('didn''t find enough points in mys')
    end
    % clf;
    
    if(check)
        
        findpeaks(pys,'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*peakdisk);
        pause;
        clf;
        
        findpeaks(pye,'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*peakdisk);
        pause;
        clf;
        
        findpeaks(mys,'minpeakprominence',peakProm,'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*peakdisk);
        pause;
        clf;
        
    end
    if(np>4)
        
        [~,d]=findpeaks(mye(1:end-1000),'minpeakheight',mye(1)*1.05,'npeaks',fpars(6)*2-(fpars(6)*3/2+1),'minpeakdistance',length(t)/fpars(6)*peakdisk,'minpeakprominence',peakProm);
        dsPts(5:4:(np-1),3)=d;
        if(length(d)~=(fpars(6)*2-(fpars(6)*3/2+1)))
            warning('didn''t find enough points in mys')
        end
        
        if(check)
            findpeaks(mye(1:end-1000),'minpeakheight',mye(1)*1.05,'npeaks',fpars(6)*2-(fpars(6)*3/2+1),'minpeakdistance',length(t)/fpars(6)*peakdisk,'minpeakprominence',peakProm);
            pause;
            clf;
            
        end
        
        %     pause
    end
    
    
    
    
    dsPts(:,2)=strain(dsPts(:,3));
    dsPts(:,1)=t(dsPts(:,3));
end
% hold on;
%
% plot(dsPts(2:4:np,1),dsPts(2:4:np,2),'o')
% plot(dsPts(3:4:np,1),dsPts(3:4:np,2),'o')
% plot(dsPts(4:4:np,1),dsPts(4:4:np,2),'o')
% if(np>4)
%     plot(dsPts(5:4:(np-1),1),dsPts(5:4:(np-1),2),'o')
% end

plot(dsPts(:,1),rob(dsPts(:,3)),'o')
pause
%get indices between first two points
ptSpan=dsPts(1:2,3);
d=diff(ptSpan)/4;
%get middle range of points
ptSpan=[ptSpan(1)+floor(d),ptSpan(1)+2*floor(d)];
vel=diff(strain(ptSpan))/diff(t(ptSpan));
%%%%%%%%%%%%%%%%%%%%%%%
