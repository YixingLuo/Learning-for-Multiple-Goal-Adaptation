function f = obj_ReqAdapt(x)
y = [0,0,0,0,0];
for i = 1:5
    if (x(end-5+i)>0.5)
        y(i) = 1;
    end
end
global configure
global env_known
global initial_N
length_o = 0;
width_o = 0;
length_p = 0;
width_p = 0;
[length_o, width_o] = size(env_known.obstacle_list);
[length_p, width_p] = size(env_known.privacy_list);
bound_o = length_o * (initial_N+1);
bound_p = length_p * (initial_N+1);
dis_o = zeros(initial_N+1,length_o);
dis_p = zeros(initial_N+1,length_p);

temp_f = y(5)*x(end-5)/(configure.battery_budget-configure.battery_target) + y(4)*x(end-5-1)/(configure.Time_budget-configure.Time_target) + y(3)* x(end-5-2)/(configure.forensic_target-configure.forensic_budget);
f = temp_f;

sum_x = 0;
num_x = 0;
if bound_o > 0
    for j = 1: bound_o
        x_index = 4*(initial_N + 1) + j;
        sum_x = sum_x + x(x_index)/configure.obstacle_max;
        if x(x_index)>0
            num_x = num_x + 1;
        end
    end
    sum_x = sum_x/(bound_o * configure.obstacle_max);
    sum_x = y(1)*sum_x;
end

sum_y = 0;
num_y = 0;


if bound_p > 0
    for j = 1: bound_p
        x_index = 4*(initial_N + 1) + bound_o + j;
        sum_y = sum_y + x(x_index)/configure.privacy_max;
        if x(x_index)>0
            num_y = num_y + 1;
        end
    end
    sum_y = sum_y/(bound_p * configure.privacy_max);
    sum_y = y(2)*sum_y;
end

f = sum_x + sum_y + temp_f;
