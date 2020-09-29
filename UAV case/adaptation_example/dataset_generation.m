train_data = [];
train_label = [];
total = 1;
for j = 1:1:1
    for i = 1:1:60
        filename = 'datalog_'+ string(j) + '_' + string(i)+'.mat';
        if exist(filename,'file')==0
            continue;
        end
        %% input variables
        datalogname = load (filename);
        datalog = datalogname.datalog;
        len = length(datalog.system_state);
        %%  system_state = [current_point(1),current_point(2),current_point(3),current_point(4),information, energy, time]
        train_data(total,1:len) = datalog.system_state;
        train_data(total,len+1) = datalog.configure.battery_budget;
        train_data(total,len+2) = datalog.configure.battery_target;
        train_data(total,len+3) = datalog.configure.battery_per;
        train_data(total,len+4) = datalog.configure.battery_per2;
        train_data(total,len+5) = datalog.configure.forensic_target;
        train_data(total,len+6) = datalog.configure.forensic_budget;
        train_data(total,len+7) = datalog.configure.Time_target;
        train_data(total,len+8) = datalog.configure.Time_budget;
        train_data(total,len+9) = datalog.configure.velocity_max;
        train_data(total,len+10) = datalog.configure.velocity_min;
        train_data(total,len+11) = datalog.configure.sensor_accuracy;
        %% environment state
        %% prediction
        train_label(:,total) = datalog.violation_flag';
        total = total+1;
    end
end