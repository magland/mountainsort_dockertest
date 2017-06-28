function analyze_results

% run mountainlab_setup.m first

opts.show_labels=0;
opts.show_legend=1;

analyze_results2(15,opts);
analyze_results2(30,opts);
analyze_results2(60,opts);

function analyze_results2(K,opts1)

projpath=[fileparts(mfilename('fullpath')),sprintf('/../test1_K=%d',K)];
if (K==60)
    ks_num_clusters=64;
else
    ks_num_clusters=32;
end;
%projpath=[fileparts(mfilename('fullpath')),'/../project'];

noise_overlap_threshold=0.02;
isolation_score_threshold=0.99;
show_labels=opts1.show_labels;
show_legend=opts1.show_legend;

temppath=[projpath,'/tmpdata'];
resultspath=[projpath,'/results'];

mkdir(temppath);
mkdir(resultspath);

results={};
list=dir([projpath,'/output']);
for j=1:length(list)
    name0=list(j).name;
    if (~strcmp(name0(1),'.'))
        algname0=get_algname_from_output_folder_name(name0);
        K=get_K_from_output_folder_name(name0);
        dsname0=get_dsname_from_output_folder_name(name0);
        if (~strcmp(algname0,'truth'))
            oo=struct;
            oo.temppath=temppath;
            resultpath=[resultspath,'/',name0];
            ret=analyze_result(sprintf('%s/output/%s',projpath,name0),sprintf('%s/output/truth--%s',projpath,dsname0),resultpath,oo);            
            ret.algname=algname0;
            ret.dsname=dsname0;
            results{end+1}=ret;
        end;
    end;
end;

concat_output_ms2=zeros(4,0);
concat_output_ks32=zeros(4,0);
concat_output_sc=zeros(4,0);
for j=1:length(results)
    ret=results{j};
    if (strcmp(ret.algname,'ms2'))
        concat_output_ms2=cat(2,concat_output_ms2,ret.output);
    end;
    if (strcmp(ret.algname,sprintf('ks%d',ks_num_clusters)))
        concat_output_ks32=cat(2,concat_output_ks32,ret.output);
    end;
    if (strcmp(ret.algname,'sc'))
        concat_output_sc=cat(2,concat_output_sc,ret.output);
    end;
end;

writemda(concat_output_ms2,sprintf('%s/concat_output_ms2.mda',resultspath));
writemda(concat_output_ks32,sprintf('%s/concat_output_ks32.mda',resultspath));
writemda(concat_output_sc,sprintf('%s/concat_output_sc.mda',resultspath));

MS2=concat_output_ms2;
KS32=concat_output_ks32;
SC=concat_output_sc;

marker_size=20;
line_width=3;

% figure;
% h=plot(MS2(1,:),MS2(2,:),'bo','MarkerSize',marker_size);
% hold on;
% h=plot(KS32(1,:),KS32(2,:),'ro','MarkerSize',marker_size);
% legend('MountainSort','KiloSort');
% xlabel('Peak amplitude');
% ylabel('Unit accuracy');
% title('Accuracy vs. peak amplitude');

figure;
set(gcf,'Position',[200,200,1800,800]);

h_ks=plot(KS32(1,:),KS32(2,:),'o','MarkerSize',marker_size+4,'Color',[1,0,0],'LineWidth',line_width);
hold on;
h_sc=plot(SC(1,:),SC(2,:),'o','MarkerSize',marker_size+8,'Color',[0,0.7,0.3],'LineWidth',line_width);

h_ms=plot(MS2(1,:),MS2(2,:),'o','MarkerSize',marker_size,'Color',[0,0,1],'LineWidth',line_width); hold on;

noise_overlap=MS2(3,:);
isolation_score=MS2(4,:);
accepted_inds=find((noise_overlap<=noise_overlap_threshold)&(isolation_score>=isolation_score_threshold));
h_msa=plot(MS2(1,accepted_inds),MS2(2,accepted_inds),'o','MarkerSize',marker_size-line_width*4,'Color',[0,0,1],'MarkerFaceColor',[0,0,1]); hold on;

set(gca,'ylim',[0,1]);
%title('Accuracy vs. peak amplitude');
set(gca,'FontSize',40);
set(gca,'xtick',0:5:max(MS2(1,:)));
set(gca,'ytick',0:0.1:1);
set(gca,'gridalpha',1);
set(gca,'gridlinestyle','--');
set(gca,'gridcolor',[0.2,0.2,0.2]);
set(gca,'yticklabel',{0,'','','','',0.5,'','','','',1});
if (show_labels)
    ylabel('Accuracy');
    xlabel('Peak amplitude (# std devs)');
    title(sprintf('%d true clusters, around %d detectable',K,floor(K/2)),'FontSize',40);
end;
grid on;

if (show_legend)
    h_legend=legend([h_ms,h_msa,h_ks,h_sc],'MountainSort (All)','MountainSort (Accepted)',sprintf('KiloSort',ks_num_clusters),'Spyking Circus','Location','northwest');
    set(h_legend,'FontSize',40);
end;
drawnow;


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

function result=analyze_result(output_path,truth_output_path,result_path,opts)
mkdir(result_path);
firings=[output_path,'/firings.mda'];
firings_true=resolve_prv([truth_output_path,'/firings.mda.prv']);
waveforms_true=[truth_output_path,'/waveforms.mda'];
[CM,label_map]=compute_confusion_matrix(firings_true,firings,opts);
writemda64(CM,[result_path,'/confusion_matrix.mda']);
[accuracies]=compute_accuracies_from_confusion_matrix(CM);
peak_amplitudes=compute_peak_amplitudes_from_waveforms(readmda(waveforms_true));
K=length(peak_amplitudes);
cluster_metrics=[output_path,'/cluster_metrics.json'];
if (exist(cluster_metrics))
    json=fileread(cluster_metrics);
    obj=jsondecode(json);
    noise_overlaps0=get_cluster_metric(obj,length(accuracies),'noise_overlap',label_map);
    isolations0=get_cluster_metric(obj,length(accuracies),'isolation',label_map);
    noise_overlaps=zeros(1,K);
    isolations=zeros(1,K);
    for k=1:K
        if (label_map(k)>=1)&&(label_map(k)<=length(noise_overlaps0))
            noise_overlaps(k)=noise_overlaps0(label_map(k));
            isolations(k)=isolations0(label_map(k));
        else
            noise_overlaps(k)=nan;
            isolations(k)=nan;
        end;
    end;
else
    noise_overlaps=zeros(1,K);
    isolations=zeros(1,K);
end;



output=zeros(4,length(accuracies));
output(1,:)=peak_amplitudes;
output(2,:)=accuracies;
output(3,:)=noise_overlaps;
output(4,:)=isolations;

writemda64(output,[result_path,'/output.mda']);
csvwrite([result_path,'/output.csv'],output);
fprintf('%s\n',result_path);
output
result.output=output;
result.confusion_matrix=CM;

function ret=get_cluster_metric(obj,K,metric_name,label_map)
ret=zeros(1,0);
clusters=obj.clusters;
for j=1:length(clusters)
    cluster=clusters(j);
    k=cluster.label;
    if (k>0)
        ret(k)=cluster.metrics.(metric_name);
    end;
end;

function peak_amplitudes=compute_peak_amplitudes_from_waveforms(waveforms)
[M,T,K]=size(waveforms);
waveforms=reshape(waveforms,M*T,K);
peak_amplitudes=max(abs(waveforms),[],1)';

function [accuracies]=compute_accuracies_from_confusion_matrix(CM)
[N1,N2]=size(CM);
K1=N1-1; K2=N2-1;
numer=CM(1:K1,1:K2);
denom1=repmat(sum(CM(:,1:K2),1),K1,1);
denom2=repmat(sum(CM(1:K1,:),2),1,K2);
denom=denom1+denom2-numer;
denom(denom==0)=1;
ratio=numer./denom;

accuracies=max(ratio,[],2);


function fname=resolve_prv(prv_fname)
[~,str]=system(sprintf('prv-locate %s',prv_fname));
fname=strtrim(str);

function algname=get_algname_from_output_folder_name(name)
list=strsplit(name,'--');
if (length(list)>=2)
    algname=list(1);
end;

function dsname=get_dsname_from_output_folder_name(name)
list=strsplit(name,'--');
if (length(list)>=2)
    dsname=strjoin(list(2:end),'');
end;

function K=get_K_from_output_folder_name(name)
dsname=get_dsname_from_output_folder_name(name);
list=strsplit(dsname,'_');
list2=strsplit(list{2},'=');
K=str2num(list2{2});

function cmd=adjust_system_command(cmd)
cmd=sprintf('%s %s','LD_LIBRARY_PATH=/usr/local/lib',cmd);