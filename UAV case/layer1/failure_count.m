num_failure2 = 0;
for i = 1:100
    if data2(i,8)==-1 || data2(i,7)>1e-6 || data2(i,10)==-1 || data2(i,9)>1e-6 || data2(i,3)-15>1e-6 || 0.9-data2(i,1)>1e-6 || data2(i,1)==0
%      if data2(i,8)==-1  || data2(i,10)==-1 || data2(i,1)==0 
%         || data2(i,5) > 30
        num_failure2 = num_failure2 + 1; 
    end
end
num_failure2 

% num_failure3 = 0;
% for i = 1:100
%     if data3(i,8)==-1 || data3(i,10)==-1 || data3(i,3)>30 || data3(i,1)<0.8
%         num_failure3 = num_failure3 + 1;
%     end
% end
% num_failure3 