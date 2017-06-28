% Extract TRUE FIRINGS
% edited from ss_datasets/Kampff/convert_kampff_to_mda.m
% Barnett 4/6/17, fixed up for better alignment, 4/20/17
% jfm -- different file paths

thresh=150;
input_fname='datasets/nk1/adc2015-09-03T21_18_47.bin';
output_fname='datasets/nk1/firings_juxta_nk1_thr150.mda';
% afterwards do
% prv-create firings_juxta_nk1_thr???.mda firings_juxta.mda.prv
% and put in dataset folder

fid=fopen(input_fname);        % ADC = juxta
J = fread(fid,'uint16');
fclose(fid);
MJ = 8;   % # adc ch
N = numel(J)/MJ
J = reshape(J,[MJ N]);
used_channel = 0; J = J(used_channel+1,:);  % to 1-indexed channel #
J = J * (10/65536/100) * 1e6;     % uV
%writemda32(J,'juxta_nk1.mda');
J = J-mean(J);
nw = 10; win = sin(pi*(1:nw-1)/nw).^2;
J = conv(J/sum(win),win,'same'); % smoothing, preserve scale
%mJ = mean(J); %trig = (mJ-0.5*(mJ-min(J)));   % trigger level
%times = find(diff(J<trig)==1);  % trigger on down-going % we find 5920

% trig_trials=[20:10:400];
% count_trials=zeros(size(trig_trials));
% for j=1:length(trig_trials)
%     trig=-trig_trials(j);   % trigger level in uV
%     if (length(find(J<trig))>0)
%         times = 1+find(J(2:end-1)<trig & J(1:end-2)>=J(2:end-1) & J(3:end)>=J(2:end-1));
%         count_trials(j)=length(times);
%     end;
% end;
% figure; plot(trig_trials,count_trials);
% xlabel('Trigger threshold');
% ylabel('Num. events');

trig=-thresh;
times = 1+find(J(2:end-1)<trig & J(1:end-2)>=J(2:end-1) & J(3:end)>=J(2:end-1));

numel(times)  % 4793
labels = 1+0*times;
writemda64([0*times;times;labels],output_fname);
figure; plot(J,'-'); hold on; v=axis; plot([times;times],[v(3)+0*times;v(4)+0*times],'r:');
plot([times(1);times(end)],trig*[1 1],'r--');

