% MATLAB code to prepare 1st M=128 ch Neto-Kampff downloaded data for sorting.
% edited from ss_datasets/Kampff/convert_kampff_to_mda.m
% Barnett 4/6/17, fixed up for better alignment, 4/20/17

dir='/data/ahb/neuron/Kampff/2015_09_03_Pair_9_0'; % set to downloaded location

addpath ../../../../mountainlab/matlab/msutils/
addpath ../../../../mountainlab/matlab/processing/

% CREATE GEOMETRY...
% clean newlines from mac to unix:
% tr '\r' '\n' < 128-chgeom-reorg.csv > 128-chgeom-reorg_clean.csv
% put this in datasets/.../geom.csv
a=textread([dir '/2015_09_04_Pair_5_0/128-chgeom-reorg_clean.csv'],'','delimiter',',');
figure; plot(a(:,1),a(:,2),'.'); hold on; axis equal tight
for m=1:size(a,1), text(a(m,1),a(m,2),sprintf('%d',m)); end
% radius of 25 um gets neighbors
%jj=1:32; plot(a(jj,1),a(jj,2),'k.','markersize',20);  % highlight subset


M=128;   % # ch

% CREATE RAW DATA
fid=fopen([dir,'/amplifier2015-09-03T21_18_47-002.bin'],'r');       % raw MEA
Y = fread(fid,'uint16');  % size not given
fclose(fid);
N = numel(Y)/M
Y = reshape(Y,[M N]);
Y = (Y-32768); %*0.195;    % uV   % don't scale
%figure; plot(Y(1,1:1e4))
writemda16i(Y,[dir '/kampff128_1_raw.mda']); % 16bit signed
clear Y

% CREATE TRUE FIRINGS
fid=fopen([dir,'/adc2015-09-03T21_18_47.bin']);        % ADC = juxta
J = fread(fid,'uint16');
fclose(fid);
MJ = 8;   % # adc ch
N = numel(J)/MJ
J = reshape(J,[MJ N]);
used_channel = 0; J = J(used_channel+1,:);  % to 1-indexed channel #
J = J * (10/65536/100) * 1e6;     % uV
writemda32(J,[dir,'/juxta.mda']);
J = J-mean(J);
nw = 10; win = sin(pi*(1:nw-1)/nw).^2;
J = conv(J/sum(win),win,'same'); % smoothing, preserve scale
%mJ = mean(J); %trig = (mJ-0.5*(mJ-min(J)));   % trigger level
%times = find(diff(J<trig)==1);  % trigger on down-going % we find 5920
trig=-180;   % trigger level in uV
times = 1+find(J(2:end-1)<trig & J(1:end-2)>=J(2:end-1) & J(3:end)>=J(2:end-1));
numel(times)  % 4793
labels = 1+0*times;
writemda64([0*times;times;labels],[dir,'/firings_true.mda']);
figure; plot(J,'-'); hold on; v=axis; plot([times;times],[v(3)+0*times;v(4)+0*times],'r:');
plot([times(1);times(end)],trig*[1 1],'r--');
