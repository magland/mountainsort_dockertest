function compare_algs_for_tetrode

resultspath=[fileparts(mfilename('fullpath')),'/../results'];
firings1=[resultspath,'/firings_ms2mn_tetrode.mda'];
firings2=[resultspath,'/firings_ks64_tetrode_unofficial.mda'];
firings3=[resultspath,'/firings_sc_tetrode_unofficial.mda'];

mkdir('tmpdata');
cm_opts.temppath='tmpdata';
CM12=compute_confusion_matrix(firings1,firings2,cm_opts);
CM13=compute_confusion_matrix(firings1,firings3,cm_opts);
CM23=compute_confusion_matrix(firings2,firings3,cm_opts);

ms_accepted=[4:12,14:19,21,23:25,27:32];
ks64_accepted=[1:3,6:8,10:12,14,16,17,23,24,29,36,40,48,54,55,60,62];
sc_accepted=[2,6,7,8,11,12,14,15,16,18,21,22,23];

CM12=extract_sub_confusion_matrix(CM12,ms_accepted,ks64_accepted);
CM13=extract_sub_confusion_matrix(CM13,ms_accepted,sc_accepted);
CM23=extract_sub_confusion_matrix(CM23,ks64_accepted,sc_accepted);



function CM_sub=extract_sub_confusion_matrix(CM,k1s,k2s)
K1=size(CM,1)-1;
K2=size(CM,2)-1;
k1s_complement=setdiff(1:K1,k1s);
k2s_complement=setdiff(1:K2,k2s);
CM_sub=zeros(length(k1s)+1,length(k2s)+1);
CM_sub(1:end-1,1:end-1)=CM(k1s,k2s);
CM_sub(end,1:end-1)=sum(CM(k1s_complement,k2s),1)+CM(end,k2s);
CM_sub(1:end-1,end)=sum(CM(k1s,k2s_complement),2)+CM(k1s,end);

function [CM_sub,k1s,k2s]=get_minimal_sub_confusion_matrix(CM,k1s,k2s,thresh)
CMb=CM(1:end-1,1:end-1);
K1=size(CMb,1);
K2=size(CMb,2);
while (1)
    something_changed=0;
    for i1=1:length(k1s)
        k1=k1s(i1);
        k2s_complement=setdiff(1:K2,k2s);
        num_excluded=sum(CMb(k1,k2s_complement));
        if (num_excluded>sum(CMb(k1,:))*thresh)
            [~,jj]=max(CMb(k1,k2s_complement));
            k2s=[k2s,k2s_complement(jj)];
            something_changed=1;
        end;
    end;
    for i2=1:length(k2s)
        k2=k2s(i2);
        k1s_complement=setdiff(1:K1,k1s);
        num_excluded=sum(CMb(k1s_complement,k2));
        if (num_excluded>sum(CMb(:,k2))*thresh)
            [~,jj]=max(CMb(k1s_complement,k2));
            k1s=[k1s,k1s_complement(jj)];
            something_changed=1;
        end;
    end;
    if (~something_changed) break; end;
end;

CM_sub=extract_sub_confusion_matrix(CM,k1s,k2s);

function agreement=compute_agreement(CM,k)
row_sum=sum(CM(k,:));
col_sums=sum(CM,1);
numerators=CM(k,:);
denominators=row_sum+col_sums-numerators;
denominators(denominators==0)=1;
agreements=numerators./denominators;
agreement=max(agreements);

function [CM,label_map]=compute_confusion_matrix(firings1,firings2,opts)
CM_fname=sprintf('%s/CM_tmp.mda',opts.temppath);
label_map_fname=sprintf('%s/label_map_tmp.mda',opts.temppath);
delete(CM_fname);
cmd=sprintf('mp-run-process mountainsort.confusion_matrix --firings1=%s --firings2=%s --relabel_firings2=false --max_matching_offset=30 --confusion_matrix_out=%s --label_map_out=%s',...
            firings1,firings2,CM_fname,label_map_fname);
cmd=adjust_system_command(cmd);
disp(['Running ',cmd]);
system(cmd);
CM=readmda(CM_fname);
label_map=readmda(label_map_fname);

function cmd=adjust_system_command(cmd)
cmd=sprintf('%s %s','LD_LIBRARY_PATH=/usr/local/lib',cmd);