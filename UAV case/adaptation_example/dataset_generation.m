data = [];
label = [];
data = [];
train_label = [];
test_data = [];
test_label = [];
total = 0;
for j = 1:1:1000
    for i = 1:1:60
        filename = 'datalog_'+ string(j) + '_' + string(i)+'.mat';
        if exist(filename,'file')==0
            continue;
        end
        total = total+1;
        %% input variables
        datalogname = load (filename);
        datalog = datalogname.datalog;
        len = length(datalog.system_state);
        %%  system_state = [current_point(1),current_point(2),current_point(3),current_point(4),information, energy, time]
        data(total,1:len) = datalog.system_state;
        data(total,len+1) = datalog.configure.battery_budget;
        data(total,len+2) = datalog.configure.battery_target;
        data(total,len+3) = datalog.configure.battery_per;
        data(total,len+4) = datalog.configure.battery_per2;
        data(total,len+5) = datalog.configure.forensic_target;
        data(total,len+6) = datalog.configure.forensic_budget;
        data(total,len+7) = datalog.configure.Time_target;
        data(total,len+8) = datalog.configure.Time_budget;
        data(total,len+9) = datalog.configure.velocity_max;
        data(total,len+10) = datalog.configure.velocity_min;
        data(total,len+11) = datalog.configure.sensor_accuracy;
        %% environment state
        %% prediction
        label(:,total) = datalog.violation_flag';     
    end
end

train_num = floor(total*0.7);
test_num = total - train_num;
train_data = data(1:train_num,:);
test_data = data(train_num + 1:end,:);
train_label = label(:,1:train_num);
test_label = label(:,train_num + 1:end);

dataset = data;
for i = 1:size(data,1)
    predict = label(1,i)*2^0 + label(2,i)*2^1 + label(3,i)*2^2 + label(4,i)*2^3 + label(5,i)*2^4;
    dataset(i,19) = predict;
end



