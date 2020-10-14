%%%%%%%%%%%%%%%%%%%
% G.M. WU @CCMU
%%Function:
%% change the behavior data from .lvm to .xlsx
%%%%%%%%%%%%%%%%
% Version: 0.2-7/16/2018-GM-initial version
% Version: 0.31-7/25/2018-GM-only handle behavior data

%%%%%%%%%%%%%%%%%%%

actfile = ' D:\--\--.lvm';
oactfile = 'D:\--\--.xlsx';


Fs = 100; 
Ts = 1/Fs;
correctCue = 1; 
pre_time = 3;
trial_time = 15;
ntrialpersess = 20;

rData = importdata(actfile);
rData=rData(:,2:6);
dntrials = gethinteddog(actfile);

odor1 = rData(:,1);
odor2 = rData(:,2);
odor = odor1+odor2;
idx = find(diff(odor)==1);

marks = ones(size(rData,1),1);
marks(1:idx(1)-pre_time*Fs) = 0;
for i=1:length(dntrials)
    if dntrials(i)<length(idx)
        marks(idx(dntrials(i)):idx(dntrials(i)+1)-1) = 0;
    else
        marks(idx(dntrials(i)):end) = 0;
    end
end;

odor = odor&marks;
idx = find(diff(odor)==1);
ntrials = length(idx);
nsessions = floor(ntrials/ntrialpersess);

if (nsessions*ntrialpersess<length(idx))
    marks(idx(nsessions*ntrialpersess+1):end) = 0;
end;
    
rData = rData(marks>0,:);

xlswrite(oactfile,rData);
