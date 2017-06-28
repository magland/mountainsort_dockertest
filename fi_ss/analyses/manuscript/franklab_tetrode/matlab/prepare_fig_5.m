function prepare_fig_5

close all;
addpath('../matlab');

pos1=[0,0,2000,1600];
pos2=[0,0,1400,1600];

CM=csvread('results/CM_ms2mn_ks64_tetrode.csv');
figure; conf_count_plot(CM,18,'');
set(gcf,'position',pos1);

CM=csvread('results/CM_ms2mn_sc_tetrode.csv');
figure; conf_count_plot(CM,18,'');
set(gcf,'position',pos2);