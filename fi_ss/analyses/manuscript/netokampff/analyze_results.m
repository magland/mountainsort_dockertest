function analyze_results

fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
CM=csvread('results/CM_juxta_ms2mn.csv');
report_stats(CM,2);

fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MS3 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
CM=csvread('results/CM_juxta_ms3.csv');
report_stats(CM,2);

fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ KS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
CM=csvread('results/CM_juxta_ks256.csv');
report_stats(CM,2);


fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
CM=csvread('results/CM_juxta_sc.csv');
report_stats(CM,1);


function report_stats(CM,num)
[~,ii]=sort(CM(1,:),'descend');
ii(1:10)
CM(:,ii(1:10))

fprintf('Sensitivity:\n')
numer=sum(CM(1,ii(1:num)));
denom=sum(sum(CM(1,2:end)));
fprintf('Num correct: %d\n',numer);
fprintf('Total true: %d\n',denom);
fprintf('False negative rate: %g\n',1-numer/denom);

fprintf('Specificity:\n')
numer=sum(CM(1,ii(1:num)));
denom=sum(sum(CM(1:end-1,ii(1:num))));
fprintf('Num correct: %d\n',numer);
fprintf('Total detected: %d\n',denom);
fprintf('False positive rate: %g\n',1-numer/denom);
