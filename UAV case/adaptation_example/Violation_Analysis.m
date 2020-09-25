function [violation_flag, violation_degree] = Violation_Analysis(x)
y = [0,0,0,0,0];
for i = 1:5
    if (x(end-5+1)>0.5)
        y(i) = 1;
    end
end
violation_flag = zeros(1,5);
% violation_degree = zeros(1,5);
global env_known
global initial_N
global configure
% info_variance = x(end-2);
% time_variance = x(end-1);
% energy_variance = x(end);


for i = 3:1:5
    if x(end-5-(5-i))* y(i)>0
        violation_flag (i) = 1;
    end
end

length_o = 0;
width_o = 0;
length_p = 0;
width_p = 0;
[length_o, width_o] = size(env_known.obstacle_list);
[length_p, width_p] = size(env_known.privacy_list);
bound_o = length_o * (initial_N+1);
bound_p = length_p * (initial_N+1);
num_o = 0;
num_p = 0;
safety_variance = 0;
privacy_variance = 0;

for i = 1:bound_o
    safety_variance = safety_variance + x(4*(initial_N + 1) + i);
    if x(4*(initial_N + 1) + i) > 0
        num_o = num_o + 1;
    end
    if y(1)*safety_variance > 0
        violation_flag (1) = 1;
    end
end

for i = 1:bound_p
    privacy_variance = privacy_variance + x(4*(initial_N + 1) + bound_o + i);
    if x(4*(initial_N + 1) + bound_o + i) > 0
        num_p = num_p + 1;
    end
    if y(2)*privacy_variance > 0
        violation_flag (2) = 1;
    end
end

safety_ratio = 0;
privacy_ratio = 0;
info_ratio = y(3)*x(end-5-2) /(configure.forensic_target-configure.forensic_budget);
time_ratio = y(4)*x(end-5-2) /(configure.Time_budget-configure.Time_target);
energy_ratio = y(5)*x(end-5-2) /(configure.battery_budget-configure.battery_target);
if bound_o > 0
    safety_ratio = y(1)*safety_variance/(configure.obstacle_max * bound_o);
end
if bound_p > 0
    privacy_ratio = y(2)*privacy_variance/(configure.privacy_max * bound_p);
end

violation_degree = [safety_ratio, privacy_ratio, info_ratio, time_ratio, energy_ratio];


