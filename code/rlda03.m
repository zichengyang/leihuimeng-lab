%%%%%%%%%%%%%%%%%%%
%% G.M. WU @CCMU
%%%%%%%%%%%%%%%%
%% Function:
%% analysis four cases in the spercific training phase;
%% Version: 0.1-7/20/2018-GM-initial version



clear all;
close all;
% load files
actfile = 'D:\--\--.xlsx';
cafile ='D:\--\--.xlsx';


% parameters
Fs = 100; 
Ts = 1/Fs;
correctCue = 2; 
pre_time = 3;
trial_time = 15;
ntrialpersess = 20;
isoneodorcase = false;

aData = [];
[~,sheets] = xlsfinfo(actfile);
isheet = 1;
nsheet = length(sheets);
while(isheet<=nsheet)
    tmp = xlsread(actfile,isheet);
    if(isempty(tmp)) break; end;
    aData = [aData; tmp];
    isheet = isheet+1;
end;
cData = [];
[~,sheets] = xlsfinfo(cafile);
isheet = 1;
nsheet = length(sheets);
while(isheet<=nsheet)
    tmp = xlsread(cafile,isheet);
    if(isempty(tmp)) break; end;
    cData = [cData; tmp];
    isheet = isheet+1;
end;

odor1 = aData(:,1);
odor2 = aData(:,2);
lick = aData(:,3);
pump = aData(:,4);
action = aData(:,5);
odor = odor1+odor2; 
idx1 = find(diff(odor1)==1);
idx2 = find(diff(odor2)==1);
idx = find(diff(odor)==1)+1;

podor1 = cData(:,1);
podor2 = cData(:,2);
podor = podor1+podor2;
pidx = find(diff(podor)==1)+1;

ntrials = length(idx);
nsessions = floor(ntrials/ntrialpersess);
ncadatapnts = 18*Fs;
cas = zeros(ncadatapnts,ntrials);

lickdata = [];
lickrate = [];
for i=1:ntrials
    if(correctCue==1)
        cueids(i) = odor1(idx(i))==1;
    else
        cueids(i) = odor2(idx(i))==1;
    end;

    bidx = max(1,idx(i));
    atriallick = lick(bidx:bidx+15*Fs-1);
    lickdata = [lickdata; atriallick'];
    licktime = find(diff(atriallick)==-1)*Ts;
    lickratees(i) = ~isempty(licktime);
    lickrate = [lickrate;gaus_smooth(licktime,0:0.1:trial_time,0.5)/2];
    islicked(i) = sum(atriallick(1:8*100))>0;
    islickedinwnd(i) = sum(lick(idx(i)+3*100:idx(i)+5*100))>0;
    
    bidx = max(1,pidx(i)-pre_time*Fs);
    cas(:,i) = cData(bidx:bidx+(pre_time+trial_time)*Fs-1,4);
end;

if correctCue==1
    cue1ids = cueids;
else
    cue1ids = ~cueids;
end;


Voffset = --;
F0 = squeeze(mean(cas(1*Fs+1:3*Fs,:)));
fca = zeros(size(cas));
for j=1:ntrials
    fca(:,j) = (cas(:,j)-F0(j))/(F0(j)-Voffset);
end;
fca = fca(1*Fs+1:end,:);
mca = mean(fca,2)';
vca = std(fca,0,2)';

%%%%%%%%%%%%%%%%%%%
%% PLOT DATA
noc = 10;
if isoneodorcase
    noc = 20;
end;
hits = islickedinwnd&cueids;
for i=1:nsessions
    shits(i) = sum(hits((i-1)*20+1:i*20));
    crate(i) = shits(i)/noc;
end;
misses = (~islickedinwnd)&cueids;
for i=1:nsessions
    smisses(i) = sum(misses((i-1)*20+1:i*20));
    crate(i) = smisses(i)/noc;
end;
crejects = (~islicked)&(~cueids);
for i=1:nsessions
    screjects(i) = sum(crejects((i-1)*20+1:i*20));
    crate(i) = screjects(i)/noc;
end;
falsealarms = islicked&(~cueids);
for i=1:nsessions
    sfalsealarms(i) = sum(falsealarms((i-1)*20+1:i*20));
    crate(i) = sfalsealarms(i)/noc;
end;

%% FOUR CASES
tca = fca(:,hits);
mca = mean(tca,2)';
vca = std(tca,0,2)';
mcahits=mca;
vcahits=vca;
figure('color',[1 1 1]); imagesc(lickdata(hits,:));
xlabel('Time (s)');
ylabel('trail');
set(gca,'XTick',500:500:1500);
set(gca,'XTickLabel', 5:5:15);
title('Hit cases');
cmap=[ones(63,3);zeros(1,3)];
colormap(cmap);
plotHeatmap(-1.99:Ts:15,1:size(tca,2),tca','Time (s)','#Trial','Hit cases',false); 
figure('color',[1 1 1]); drawErrorLine(-1.99:Ts:15,mca*100,vca/sqrt(suhits-1)*100,'b');
xlabel('Time (s)');
ylabel('dF/F (%)');
title('Hit cases');

tca = fca(:,misses);
mca = mean(tca,2)';
vca = std(tca,0,2)';
mcamisses=mca;
vcamisses=vca;
figure('color',[1 1 1]); imagesc(lickdata(misses,:));
xlabel('Time (s)');
ylabel('trail');
set(gca,'XTick',500:500:1500);
set(gca,'XTickLabel', 5:5:15);
title('Miss cases');
cmap=[ones(63,3);zeros(1,3)];
colormap(cmap);
plotHeatmap(-1.99:Ts:15,1:size(tca,2),tca','Time (s)','#Trial','Miss cases',false); 
figure('color',[1 1 1]); drawErrorLine(-1.99:Ts:15,mca*100,vca/sqrt(sumisses-1)*100,'b');
xlabel('Time (s)');
ylabel('dF/F(%)');
title('Miss cases');

tca = fca(:,crejects);
mca = mean(tca,2)';
vca = std(tca,0,2)';
mcacrejects=mca;
vcacrejects=vca;
figure('color',[1 1 1]); imagesc(lickdata(crejects,:));
xlabel('Time (s)');
ylabel('trail');

set(gca,'XTick',500:500:1500);
set(gca,'XTickLabel', 5:5:15);
title('Correct reject cases');
cmap=[ones(63,3);zeros(1,3)];
colormap(cmap);
plotHeatmap(-1.99:Ts:15,1:size(tca,2),tca','Time (s)','#Trial','Correct reject cases',false); 
figure('color',[1 1 1]); drawErrorLine(-1.99:Ts:15,mca*100,vca/sqrt(sucrejects-1)*100,'b');   
xlabel('Time (s)');
ylabel('dF/F(%)');
title('Correct reject cases');

tca = fca(:,falsealarms);
mca = mean(tca,2)';
vca = std(tca,0,2)';
mcafalsealarms=mca;
vcafalsealarms=vca;
figure('color',[1 1 1]); imagesc(lickdata(falsealarms,:));
xlabel('Time (s)');
ylabel('trail');
set(gca,'XTick',500:500:1500);
set(gca,'XTickLabel', 5:5:15);
title('False alarm cases');
cmap=[ones(63,3);zeros(1,3)];
colormap(cmap);
plotHeatmap(-1.99:Ts:15,1:size(tca,2),tca','Time (s)','#Trial','False alarm cases',false); 
figure('color',[1 1 1]); drawErrorLine(-1.99:Ts:15,mca*100,vca/sqrt(sufalsealarms-1)*100,'b');
xlabel('Time (s)');
ylabel('dF/F(%)');
title('False alarm cases');


