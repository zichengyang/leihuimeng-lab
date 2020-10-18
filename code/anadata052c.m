%%%%%%%%%%%%%%%%%%%
% G.M. WU @CCMU
% Function: 
%% change the calcuim signal data from .csv to .xlsx
% Version: 0.2-7/16/2018-GM-initial version
% Version: 0.32-7/25/2018-GM-only handle CA signal data

%%%%%%%%%%%%%%%%%%%


fiberfile='D:\--\--.csv';
ofiberfile='D:\--\--.xlsx';
actfile = 'D:\--\--.lvm';

Fs = 100; 
Ts = 1/Fs;
correctCue = 2; 
pre_time = 3;
trial_time = 15;
ntrialpersess = 20;
cData = xlsread(fiberfile);
dntrials = gethinteddog(actfile);

podor1 = cData(:,1);
podor2 = cData(:,2);
podor = podor1+podor2;
pidx = find(diff(podor)==1);

pmarks = ones(size(cData,1),1);
pmarks(1:pidx(1)-pre_time*Fs) = 0;
for i=1:length(dntrials)
    if dntrials(i)<length(pidx)
        pmarks(pidx(dntrials(i)):pidx(dntrials(i)+1)-1) = 0;
    else
        pmarks(pidx(dntrials(i)):end) = 0;
    end    
end;

podor = podor&pmarks;
pidx = find(diff(podor)==1);
ntrials = length(pidx);
nsessions = floor(ntrials/ntrialpersess);

if (nsessions*ntrialpersess<length(pidx))
    pmarks(pidx(nsessions*ntrialpersess+1):end) = 0;
end;
    
cData = cData(pmarks>0,:);
xlswrite(ofiberfile,cData);