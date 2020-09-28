dataset = [];
dataoutput = [];
total = 1;
for i = 1:1:60
    filename = 'datalog_1_' + string(i)+'.mat';
    if exist(filename,'file')==0
        continue;
    end
%     filename = 'datalog_1_' + string(i);
    datalogname = load ('datalog_1_' + string(i));
    datalog = datalogname.datalog;
    len = length(datalog.system_state);
    dataset(total,1:len) = datalog.system_state;
    dataset(total,len+1) = datalog.configure.battery_budget;
    dataset(total,len+2) = datalog.configure.battery_target;
    dataset(total,len+3) = datalog.configure.battery_per;
    dataset(total,len+4) = datalog.configure.battery_per2;
    dataset(total,len+5) = datalog.configure.forensic_target;
    dataset(total,len+6) = datalog.configure.forensic_budget;
    dataset(total,len+7) = datalog.configure.Time_target;
    dataset(total,len+8) = datalog.configure.Time_budget;
    dataset(total,len+9) = datalog.configure.velocity_max;
    dataset(total,len+10) = datalog.configure.velocity_min;
    dataset(total,len+11) = datalog.configure.sensor_accuracy;
    dataset(total,len+12:len+16) = datalog.violation_flag;
    total = total+1;
end