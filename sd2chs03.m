%%%%%%%%%%%%%%%%%%%
%% G.M. WU @CCMU
%% Function:
%% seperate data for multiple-channel record
%% Version: 0.1-10/5/2018-GM-initial version
%%%%%%%%%%%%%%%%%%%


% input files
bh_file = 'D:\--/--.csv';
ca_file = 'D:\--/--.csv';

% output files
m1_file = 'D:\--\--.csv';
m2_file = 'D:\--\--.csv';

% channel setting
nch_M1CAS =2;
nch_M2CAS = 5;
nch_M1CUES = [1 2];
nch_M2CUES = [3 4];
sfreq_bh = 1000; %>=100
sfreq_ca = 50; %<=100

sfreq_std = 100;
npersheet = 770000;
alen = sfreq_bh/sfreq_std;


bhdata = csvread(bh_file);
cadata = csvread(ca_file);
npnts = size(bhdata,1)/alen;

M1data = zeros(npnts,4);
for i=1:2
    tmp = bhdata(:,nch_M1CUES(i));
    tmp = reshape(tmp, [alen npnts]);
    tmp = mean(tmp)>=0.5;
    M1data(:,i) = tmp';
end
tmp = resample(cadata(:,nch_M1CAS),sfreq_std,sfreq_ca);
M1data(:,4) = tmp;

M2data = zeros(npnts,4);
for i=1:2
    tmp = bhdata(:,nch_M2CUES(i));
    tmp = reshape(tmp,  [alen npnts]);
    tmp = mean(tmp)>=0.5;
    M2data(:,i) = tmp';
end
tmp = resample(cadata(:,nch_M2CAS),sfreq_std,sfreq_ca);
M2data(:,4) = tmp;

csvwrite(m1_file, M1data);
csvwrite(m2_file, M2data);
