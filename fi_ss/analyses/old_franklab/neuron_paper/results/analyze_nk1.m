function analyze_nk1

fprintf('Confusion matrix for juxta,ms2mn nk1\n');
CM=readmda('CM_juxta_ms2mn_nk1.mda');
[~,ii]=sort(CM(1,:),'descend');
CM(:,ii(1:10))
num_to_use=2;
a=sum(CM(1,:));
b=sum(CM(1,ii(1:num_to_use)));
c=sum(CM(2:end,ii(1:num_to_use)));
d=sum(CM(1,ii(num_to_use+1:end)));
e=sum(sum(CM(:,ii(1:num_to_use))));
fprintf('Using best %d clusters\n',num_to_use);
fprintf('Num juxta: %d\n',a);
fprintf('Num correct: %d (%g%%)\n',b,b/a*100);
fprintf('Total incorrect: %d (%g%%)\n',c,c/e*100);
fprintf('Total missed: %d (%g%%)\n',d,d/a*100);
fprintf('\n');

fprintf('Confusion matrix for juxta,ks256 nk1\n');
CM=readmda('CM_juxta_ks256_nk1.mda');
[~,ii]=sort(CM(1,:),'descend');
CM(:,ii(1:10))
num_to_use=1;
a=sum(CM(1,:));
b=sum(CM(1,ii(1:num_to_use)));
c=sum(CM(2:end,ii(1:num_to_use)));
d=sum(CM(1,ii(num_to_use+1:end)));
e=sum(sum(CM(:,ii(1:num_to_use))));
fprintf('Using best %d clusters\n',num_to_use);
fprintf('Num juxta: %d\n',a);
fprintf('Num correct: %d (%g%%)\n',b,b/a*100);
fprintf('Total incorrect: %d (%g%%)\n',c,c/e*100);
fprintf('Total missed: %d (%g%%)\n',d,d/a*100);
fprintf('\n');

fprintf('Confusion matrix for juxta,sc nk1\n');
CM=readmda('CM_juxta_sc_nk1.mda');
[~,ii]=sort(CM(1,:),'descend');
CM(:,ii(1:10))
num_to_use=1;
a=sum(CM(1,:));
b=sum(CM(1,ii(1:num_to_use)));
c=sum(CM(2:end,ii(1:num_to_use)));
d=sum(CM(1,ii(num_to_use+1:end)));
e=sum(sum(CM(:,ii(1:num_to_use))));
fprintf('Using best %d clusters\n',num_to_use);
fprintf('Num juxta: %d\n',a);
fprintf('Num correct: %d (%g%%)\n',b,b/a*100);
fprintf('Total incorrect: %d (%g%%)\n',c,c/e*100);
fprintf('Total missed: %d (%g%%)\n',d,d/a*100);
fprintf('\n');