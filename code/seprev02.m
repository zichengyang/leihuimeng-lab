%%%%%%%%%%%%%%%%%%%
% G.M. WU @CCMU
% Function: 
%     Separate the entire reversal stage into early and late stage reversal;
% Version: 0.1-7/29/2018-GM-initial version

%%%%%%%%%%%%%%%%%%%
clear all;

%% NOTE: Loadfiles;
fiberfile='D:\--\--.xlsx';
actfile = 'D:\--\--.xlsx';
esfiberfile='D:\--\--.xlsx';
ssfiberfile='D:\--\--.xlsx';
esactfile = 'D:\--\--.xlsx';
ssactfile = 'D:\--\--.xlsx';

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
[~,sheets] = xlsfinfo(fiberfile);
isheet = 1;
nsheet = length(sheets);
while(isheet<=nsheet)
    tmp = xlsread(fiberfile,isheet);
    if(isempty(tmp)) break; end;
    cData = [cData; tmp];
    isheet = isheet+1;
end;

Fs = 100; 
Ts = 1/Fs;
correctCue = 2; 
pre_time = 3;
trial_time = 15;
ntrialpersess = 20;


odor1 = aData(:,1);
odor2 = aData(:,2);
lick = aData(:,3);
odor = odor1+odor2;
idx = find(diff([0; odor])==1);

podor1 = cData(:,1);
podor2 = cData(:,2);
podor = podor1+podor2;
pidx = find(diff([0; podor])==1);

ntrials = length(idx);
nsessions = floor(ntrials/ntrialpersess);

lickdata = [];
lickrate = [];
for i=1:ntrials
    if(correctCue==1)
        cueids(i) = odor1(idx(i))==1;
    else
        cueids(i) = odor2(idx(i))==1;
    end;

    bidx = max(1,idx(i));
    atriallick = lick(bidx:bidx+trial_time*Fs-1);
    lickdata = [lickdata; atriallick'];
    licktime = find(diff(atriallick)==1)*Ts;
    lickratees(i) = ~isempty(licktime);
    lickrate = [lickrate;gaus_smooth(licktime,0:0.1:trial_time,0.5)/2];
    islicked(i) = sum(atriallick(1:8*100))>0;
    islickedinwnd(i) = sum(lick(idx(i)+3*100:idx(i)+5*100))>0;
end;

noc = 10;
hits = islickedinwnd&cueids;
for i=1:nsessions
    shits(i) = sum(hits((i-1)*20+1:i*20));
    crate(i) = shits(i)/noc;
end;

crejects = (~islicked)&(~cueids);
for i=1:nsessions
    screjects(i) = sum(crejects((i-1)*20+1:i*20));
    crate(i) = screjects(i)/noc;
end;

for i=1:nsessions
    scorrects(i) = screjects(i)+shits(i);
    scorrectrate(i) = scorrects(i)/20;
end;
sn = find(scorrectrate>=0.7,1);
sntrial = 20*sn;

npersheet = 770000;
aData_es = aData(1:idx(sntrial+1)-1,:);
j = ceil(size(aData_es,1)/npersheet);
bidx = 1; i = 1;
while(i<j)
    xlswrite(esactfile,aData_es(bidx:i*npersheet,:),i);
    bidx = i*npersheet+1;
    i = i+1;
end;
xlswrite(esactfile,aData_es(bidx:end,:),i);

aData_ss = aData(idx(sntrial+1)-pre_time*Fs:end,:);
j = ceil(size(aData_ss,1)/npersheet);
bidx = 1; i = 1;
while(i<j)
    xlswrite(ssactfile,aData_ss(bidx:i*npersheet,:),i);
    bidx = i*npersheet+1;
    i = i+1;
end;
xlswrite(ssactfile,aData_ss(bidx:end,:),i);

cData_es = cData(1:pidx(sntrial+1)-1,:);
j = ceil(size(cData_es,1)/npersheet);
bidx = 1; i = 1;
while(i<j)
    xlswrite(esfiberfile,cData_es(bidx:i*npersheet,:),i);
    bidx = i*npersheet+1;
    i = i+1;
end;
xlswrite(esfiberfile,cData_es(bidx:end,:),i);

cData_ss = cData(pidx(sntrial+1)-pre_time*Fs:end,:);
j = ceil(size(cData_ss,1)/npersheet);
bidx = 1; i = 1;
while(i<j)
    xlswrite(ssfiberfile,cData_ss(bidx:i*npersheet,:),i);
    bidx = i*npersheet+1;
    i = i+1;
end;
xlswrite(ssfiberfile,cData_ss(bidx:end,:),i);