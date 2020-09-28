function [data, trajectory,velocity_history,planning_time, rate_list, tag_list] = uav_ReqAdapt(num_map,num_condition, indextemp)
global env
global env_known
global configure
global eplison
global ratio
configure = Configure();
% eplison = [0,0,1e-6,1e-6,1e-6];
eplison = [1e-20,1e-20,1e-10,1e-20,0.005];
current_step = 1;
start_point = [configure.start_point(1),configure.start_point(2),configure.start_point(3),0];
end_point = [configure.end_point(1),configure.end_point(2),configure.end_point(3),0];

global current_point
current_point = start_point;
global trajectory
trajectory = [current_point];

global plan_x
global plan_con
global time
global information
global energy
global past_distance
global velocity_history
velocity_history=[];
time = 0;
information = 0;
energy = 0;
past_distance = 0;
global initial_N
initial_N = configure.N;
flag=[];
flag_relax=[];
f_lambda=[];
plan_con = zeros(100, 100);
plan_x = zeros(100, 100);
following_plan = []; %% the initial plan and update online
following_point = [start_point];
relax_num = 0;
plan_num = 0;
planning_time = [];
data = zeros(1,12);
rate_list = [];
tag_list = [];
no_solution_flag = 0;
env = Environment();
name = 'gridmap-' + string(num_map) + '.mat';
gridmap = load(name);
env = gridmap.map;
env_known = Environment();

name_con = 'condition' + string(num_condition) + '.mat';
cond = load(name_con);
cond = cond.condition;


index_cond = 1;



for k = 1: (configure.N+1) 
    for i = 1:3
        if configure.start_point(i) > configure.end_point(i)
            following_plan(k,i) = configure.velocity_min;
        else
            following_plan(k,i) = configure.velocity_max;
        end
    end
    following_plan(k,4) = 1;
end

for k = 2: configure.N
    following_point = [following_point;following_point(k-1,1)+following_plan(k-1,1)*configure.Time_step, following_point(k-1,2)+following_plan(k-1,2)*configure.Time_step, following_point(k-1,3)+following_plan(k-1,3)*configure.Time_step, following_point(k-1,4)];
end
following_point = [following_point; end_point];


while (1)
    if no_solution_flag == 1
        needplan = 1;
        no_solution_flag = 0;
    else
        needplan = 0;
    end
%     needplan = 1;
    
    if  index_cond <= length(indextemp) && current_step == indextemp(index_cond)        
        needplan = 1;
        if cond(index_cond,1) == 1
            configure = EnergyTarget(configure, cond(index_cond,2));
            elseif cond(index_cond,1) == 2
                configure = TimeTarget(configure, cond(index_cond,2));                       
            elseif cond(index_cond,1) == 3
                configure = AccuracyTarget(configure, cond(index_cond,2));
            elseif cond(index_cond,1) == 4
                configure = EnergyDisturbance(configure, cond(index_cond,2), cond(index_cond,3));
            elseif cond(index_cond,1) == 5
                configure = SpeedDisturbance(configure, cond(index_cond,2));
            elseif cond(index_cond,1) == 6
                configure = AccuracyDisturbance(configure, cond(index_cond,2));
        end
%         current_step, configure
        index_cond = index_cond+1;
    end
    
    fprintf(2,'uav_ReqAdapt: current step %d\n', current_step);
%     [SR_risk, PR_risk] =  caculate_risk_new(current_point, env);
%     SR_list = [SR_list;SR_risk];
%     PR_list = [PR_list;PR_risk];
%     acc_list = [acc_list;information];
%     energy_list = [energy_list;energy];
%     time_list = [time_list;time];
    
    fprintf(2,'uav_ReqAdapt: current step %d \n', current_step);
    
    if abs(current_point(1) - end_point(1))<1e-6 && abs(current_point(2) - end_point(2))<1e-6 && abs(current_point(3) - end_point(3))<1e-6
        fprintf(2,'reach the destination!\n')
        DS_i = [information, min(1,(information - configure.forensic_budget)/(configure.forensic_target - configure.forensic_budget))];
        DS_t = [time,min(1,(configure.Time_budget - time)/(configure.Time_budget - configure.Time_target))];
        DS_e = [energy,min(1,(configure.battery_budget - energy) /(configure.battery_budget - configure.battery_target))];
        [SR, DS_SR, PR, DS_PR, DS_acc] = caculate_risk(trajectory, env);
%         [SR_known, PR_known] = caculate_risk(trajectory,env_known);
        data = [DS_i, DS_t, DS_e, SR, DS_SR, PR, DS_PR, plan_num, relax_num, DS_acc];
%         name1 = 'planningtime.mat';
%         save(name1, 'planning_time');
%         name2 = 'trajectory.mat';
%         save(name2, 'trajectory');
%         name3 = 'velocity_history.mat';
%         save(name3, 'velocity_history');
        break
    end
    
    if current_step > configure.Time_budget/configure.Time_step
        fprintf(2,'no solution \n');
        break
    end
    
    fprintf('initial current point: [%f , %f, %f, %f]\n', current_point)
%     if current_point(1) > end_point(1) && current_point(2) > end_point(2) && current_point(3) > end_point(3)
%         break
%     end
%     following_plan, following_point
    if size(following_plan, 1) == 1
        fprintf(2,'the last step!\n')
        dis = sqrt((current_point(1)-end_point(1))^2 + (current_point(2)-end_point(2))^2 + (current_point(3)-end_point(3))^2);
        last_t = dis/sqrt(following_plan(1,1)^2 + following_plan(1,2)^2 + following_plan(1,3)^2);
%         information = (information * past_distance + following_plan(1,4) * dis) / (past_distance + dis);
        information = (information * time + following_plan(1,4) * last_t)/(time + last_t);
        time = time + last_t;
        %         energy = energy + configure.battery_per * dis;
        energy = energy + configure.battery_per * dis * following_plan(1,4);
        past_distance = past_distance + dis;
        current_point = [end_point(1), end_point(2), end_point(3), following_plan(1,4)];
        traj = [trajectory; current_point];
        trajectory = traj;
        velocity_history = [velocity_history; following_plan(1,1), following_plan(1,2), following_plan(1,3), following_plan(1,4)];
        
%         [SR_risk, PR_risk] =  caculate_risk_new(current_point, env);
%         SR_list = [SR_list;SR_risk];
%         PR_list = [PR_list;PR_risk];
%         acc_list = [acc_list;information];
%         energy_list = [energy_list;energy];
%         time_list = [time_list;time];
        
        continue
    end
           
    length_o = 0;
    width_o = 0;
    length_p = 0;
    width_p = 0;
    [length_o, width_o] = size(env.obstacle_list);
    [length_p, width_p] = size(env.privacy_list);

    env_known = remove_obstacle(env_known);
    env_known = remove_privacy(env_known);
    for oo = 1:length_o
        if sqrt((env.obstacle_list(oo, 1)-current_point(1)).^2+(env.obstacle_list(oo, 2)-current_point(2)).^2+(env.obstacle_list(oo, 3)-current_point(3)).^2) <=configure.viewradius
            needplan = 1;
            if isempty(env_known.obstacle_list) || isempty(find(env_known.obstacle_list==env.obstacle_list(oo,:)))               
                env_known = add_obstacle(env_known, env.obstacle_list(oo, 1), env.obstacle_list(oo, 2), env.obstacle_list(oo, 3));
            end
        end
    end
    
    for pp = 1:length_p
        if sqrt((env.privacy_list(pp, 1)-current_point(1)).^2+(env.privacy_list(pp, 2)-current_point(2)).^2+(env.privacy_list(pp, 3)-current_point(3)).^2) <=configure.viewradius
            needplan = 1;
            if isempty(env_known.privacy_list) || isempty(find(env_known.privacy_list==env.privacy_list(pp,:)))               
                env_known = add_privacy(env_known, env.privacy_list(pp, 1), env.privacy_list(pp, 2), env.privacy_list(pp, 3));
            end
        end
    end
%     name = 'env_known-' + string(current_step) + '.mat';
%     save(name, 'env_known');

    
%     %% 1122
%     if needplan == 1
%         plan_num = plan_num + 1;
%     end
    %% 1120
%     if abs(following_plan(1,1) - 0) < 1e-6 && abs(following_plan(1,2) - 0) < 1e-6 && abs(following_plan(1,3) - 0) < 1e-6 
%         %|| (mod(current_step,configure.N) == 0)
%         needplan = 1;
%     end
    if length(env_known.obstacle_list) ~= 0 || length(env_known.privacy_list) ~= 0
        needplan = 1;
    end
    
    if needplan == 0
        nowp_x = [];
        nowp_y = [];
        nowp_z = [];
        ws = [];
        nowp_x(1) = current_point(1);
        nowp_y(1) = current_point(2);
        nowp_z(1) = current_point(3);
        ws(1) = current_point(4);
        for i = 1: size(following_plan,1) - 1
            nowp_x(i+1) = min(following_plan(i,1)*configure.Time_step + nowp_x(i), configure.grid_x-configure.radius);
            nowp_y(i+1) = min(following_plan(i,2)*configure.Time_step + nowp_y(i), configure.grid_y-configure.radius);
            nowp_z(i+1) = min(following_plan(i,3)*configure.Time_step + nowp_z(i), configure.grid_z-configure.radius);
            nowp_x(i+1) = max(nowp_x(i+1), 0);
            nowp_y(i+1) = max(nowp_y(i+1), 0);
            nowp_z(i+1) = max(nowp_z(i+1), 0);
            ws(i+1) = following_plan(i,4);
        end
        nowp_x = [nowp_x, configure.end_point(1)];
        nowp_y = [nowp_y, configure.end_point(2)];
        nowp_z = [nowp_z, configure.end_point(3)];
        ws = [ws, following_plan(end,4)];
        for i = 1 : length(nowp_x)
            following_point(i,:) = [nowp_x(i),nowp_y(i),nowp_z(i), ws(i)];
        end

        next_point = following_point(2,:);
        current_point = next_point;
        fprintf(2,'contiue the previous plan!!\n')
        fprintf('next point: [%f , %f, %f, %f]\n', current_point)
        traj = [trajectory; current_point];
        trajectory = traj;
        velocity_history = [velocity_history; following_plan(1,1), following_plan(1,2), following_plan(1,3), following_plan(1,4)];
        [a, b] = size(trajectory); %% to caculate the source used
        distance = 0;
        info = 0;
        engy = 0;
        for i = 1: a-1
             distance = distance + sqrt((trajectory(i+1,1)-trajectory(i,1)).^2+(trajectory(i+1,2)-trajectory(i,2)).^2+(trajectory(i+1,3)-trajectory(i,3)).^2);
             info = info + trajectory(i+1,4)*configure.Time_step;
             engy = engy + configure.battery_per *configure.Time_step * trajectory(i+1,4) + sqrt((trajectory(i+1,1)-trajectory(i,1)).^2+(trajectory(i+1,2)-trajectory(i,2)).^2+(trajectory(i+1,3)-trajectory(i,3)).^2);
        end
        for i = 1: size(velocity_history,1)-1
             engy = engy + configure.battery_per2 * sqrt((velocity_history(i+1,1)-velocity_history(i,1)).^2+(velocity_history(i+1,2)-velocity_history(i,2)).^2+(velocity_history(i+1,3)-velocity_history(i,3)).^2);
        end        
        energy = engy;
        past_distance = distance;
        time = configure.Time_step * (a-1);
        if time == 0
            information = 0;
        else
            information = info/time;
        end   
        current_step = current_step + 1;
        
        following_plan([1],:)=[]; %%update the following plan
        following_point([1],:)=[];
        
        tt = sqrt((nowp_x(end)-nowp_x(end-1)).^2+(nowp_y(end)-nowp_y(end-1)).^2+(nowp_z(end)-nowp_z(end-1)).^2) / sqrt(following_plan(end,1).^2+following_plan(end,2).^2+following_plan(end,3).^2);
        if tt > configure.Time_step           
            following_plan(end+1,:)=following_plan(end,:);
            following_point(end,:) = [min(following_point(end-1,1)+following_plan(end,1)*configure.Time_step, end_point(1)), min(following_point(end-1,2)+following_plan(end,2)*configure.Time_step, end_point(2)), min(following_point(end-1,3)+following_plan(end,3)*configure.Time_step,end_point(3)), following_point(end,4)];
        end
        if following_point(end,1) ~= end_point(1) || following_point(end,2) ~= end_point(2) || following_point(end,3) ~= end_point(3)
            following_point(end+1,:) = [end_point(1),end_point(2),end_point(3),following_point(end, 4)];
        end
        continue
    end
    %% time start
    t1=clock;
    exitflag = 0;
    exitflag_relax = 0;
    iternum = 0;
    while exitflag <=0 && iternum <= 10
%         iternum = iternum + 1;
%         infeasible = 1;
%         while infeasible
            lb=[];
            ub=[];
            x0=[];
    
            initial_N = size(following_plan,1)-1;
    
            for i = 1 : (initial_N+1) * 3
                lb(i) = configure.velocity_min; %% negative velocity
                ub(i) = configure.velocity_max;
                x0(i) = configure.velocity_max;
%                 x0(i) = ub(i) - iternum * 2/5;
%                 x0(i) = unifrnd(lb(i),ub(i));
%                 bound_index = ceil(i/(initial_N+1));
%                 if current_point(bound_index)> configure.end_point(bound_index)
%                     x0(i) = unifrnd(lb(i),0);
%                 else                   
%                     x0(i) = unifrnd(0,ub(i));
%                 end
            end
        
            for i = 1: 3 %% velocity constraint for the last point
                index = (initial_N+1) * i;
                lb(index) = configure.velocity_min;
                ub(index) = configure.velocity_max;
                if (following_point(end,i)-following_point(end-1,i)) > 0
                    ub(index) = min(configure.velocity_max, (following_point(end,i)-following_point(end-1,i))/configure.Time_step);
                else
                    lb(index) = max(configure.velocity_min, (following_point(end,i)-following_point(end-1,i))/configure.Time_step);
                end
%                 lb(index) = max(configure.velocity_min, (following_point(end,i)-following_point(end-1,i))/configure.Time_step);
%                 ub(index) = configure.velocity_max;
%                 ub(index) = min(configure.velocity_max, (following_point(end,i)-following_point(end-1,i))/configure.Time_step);
                ub(index) = max(lb(index),ub(index)); 
%                 x0(index) = ub(index) - iternum * (ub(index)-lb(index))/30;
                x0(index) = max(lb(index),ub(index));
%                if current_point(i)> configure.end_point(i)
%                     x0(index) = unifrnd(lb(index),0);
%                else                   
%                     x0(index) = unifrnd(0,ub(index));
%                end
            end
        
            for i = (initial_N+1) * 3 + 1 : (initial_N+1) * 4
                lb(i) = 0;
                ub(i) = configure.sensor_accuracy;
                x0(i) = configure.sensor_accuracy;
%                 x0(i) = unifrnd(lb(i),ub(i));
            end
    
            length_o = 0;
            width_o = 0;
            length_p = 0;
            width_p = 0;
            [length_o, width_o] = size(env_known.obstacle_list);
            [length_p, width_p] = size(env_known.privacy_list);
            bound_o = length_o * (initial_N+1);
            bound_p = length_p * (initial_N+1);
    
            for i = 1:bound_o %% safe
                lb = [lb,0];
                ub = [ub,configure.obstacle_max];
                x0 = [x0,0];
            end
    
            for i = 1:bound_p %% privacy
                lb = [lb,0];
                ub = [ub,configure.privacy_max];
                x0 = [x0,0];
            end
            lb = [lb, 0, 0, 0];
            ub = [ub,configure.forensic_target-configure.forensic_budget, configure.Time_budget-configure.Time_target, configure.battery_budget-configure.battery_target];
            x0 = [x0,0, 0, 0];
            
        %%0925 alpha, beta, 
        lb = [lb,0,0,0,0,0];
        ub = [ub,1,1,1,1,1];
        x0 = [x0,1,1,1,1,1];

        options.Algorithm = 'sqp';
        options.Display = 'off';
        [x,fval,exitflag]=fmincon(@obj_ReqAdapt,x0,[],[],[],[],lb,ub,@mycon_ReqAdapt,options);
       
        tau = configure.Time_step;

        iternum = iternum + 1;
            
        if exitflag > 0 
            
            break
        end
    end

    if exitflag > 0
            plan_num = plan_num + 1;
            flag = [flag, exitflag];
            plan_x (current_step,1) = length(x);
            for k = 1:length(x)
                plan_x (current_step,k+1) = x(k);
            end
            system_state = [current_point(1),current_point(2),current_point(3),current_point(4),information, energy, time];
            behavior_plan = [];
            [violation_flag, violation_degree] = Violation_Analysis(x);
            x(end-5:end);
            for k = 1: (initial_N+1) 
                behavior_plan (k,:) = [x(k), x(k + initial_N + 1), x(k + 2 *(initial_N + 1)), x(k + 3 *(initial_N + 1))];
            end
            datalog = DataLog();
            datalog = InputLog(datalog, env_known, system_state, configure);
            datalog = OutputLog(datalog, behavior_plan, violation_flag, violation_degree, exitflag);
            filename = 'datalog_' + string(num_map) +'_' + string(current_step) + '.mat';
%             new_folder = 'C:\Users\lenovo\Documents\GitHub\Learning-for-Multiple-Goal-Adaptation\UAV case\adaptation_example\Datalog' + string(date);
%             mkdir(new_folder);
%             pathname = 'C:\Users\lenovo\Documents\GitHub\Learning-for-Multiple-Goal-Adaptation\UAV case\adaptation_example\Datalog\';
%             filename = pathname + filename;
            save(filename, 'datalog');
            
            fprintf(2,"there is a solution!!%d, %d\n",exitflag,current_step)

            for k = 1: (initial_N+1) 
                following_plan (k,:) = [x(k), x(k + initial_N + 1), x(k + 2 *(initial_N + 1)), x(k + 3 *(initial_N + 1))];
            end
            nowp_x = [];
            nowp_y = [];
            nowp_z = [];
            ws = [];
            nowp_x(1) = current_point(1);
            nowp_y(1) = current_point(2);
            nowp_z(1) = current_point(3);
            ws(1) = current_point(4);
            for i = 1: size(following_plan,1) - 1
                nowp_x(i+1) = min(following_plan(i,1)*configure.Time_step + nowp_x(i), configure.grid_x-configure.radius);
                nowp_y(i+1) = min(following_plan(i,2)*configure.Time_step + nowp_y(i), configure.grid_y-configure.radius);
                nowp_z(i+1) = min(following_plan(i,3)*configure.Time_step + nowp_z(i), configure.grid_z-configure.radius);
                nowp_x(i+1) = max(nowp_x(i+1), 0);
                nowp_y(i+1) = max(nowp_y(i+1), 0);
                nowp_z(i+1) = max(nowp_z(i+1), 0);
                ws(i+1) = following_plan(i,4);
            end
            nowp_x = [nowp_x, configure.end_point(1)];
            nowp_y = [nowp_y, configure.end_point(2)];
            nowp_z = [nowp_z, configure.end_point(3)];
            ws = [ws, following_plan(end,4)];
            for i = 1 : length(nowp_x)
                following_point(i,:) = [nowp_x(i),nowp_y(i),nowp_z(i), ws(i)];
            end
            next_point = following_point(2,:);

            current_point = next_point;
            fprintf('next point: [%f , %f, %f, %f]\n', current_point)
            traj = [trajectory; current_point];
            trajectory = traj;
            velocity_history = [velocity_history; following_plan(1,1), following_plan(1,2), following_plan(1,3), following_plan(1,4)];
            [a, b] = size(trajectory); %% to caculate the source used
            distance = 0;
            info = 0;
            engy = 0;
            for i = 1: a-1
                distance = distance + sqrt((trajectory(i+1,1)-trajectory(i,1)).^2+(trajectory(i+1,2)-trajectory(i,2)).^2+(trajectory(i+1,3)-trajectory(i,3)).^2);
                info = info + trajectory(i+1,4)*configure.Time_step;
                engy = engy + configure.battery_per *configure.Time_step * trajectory(i+1,4) + sqrt((trajectory(i+1,1)-trajectory(i,1)).^2+(trajectory(i+1,2)-trajectory(i,2)).^2+(trajectory(i+1,3)-trajectory(i,3)).^2);
            end
            for i = 1: size(velocity_history,1)-1
                engy = engy + configure.battery_per2 * sqrt((velocity_history(i+1,1)-velocity_history(i,1)).^2+(velocity_history(i+1,2)-velocity_history(i,2)).^2+(velocity_history(i+1,3)-velocity_history(i,3)).^2);
            end
            energy = engy;
            past_distance = distance;
            time = configure.Time_step * (a-1);
            if time == 0
                information = 0;
            else
                information = info/time;
            end 
            current_step = current_step + 1;
            
            following_plan([1],:)=[]; %%update the following plan
            following_point([1],:)=[];
            tt = sqrt((nowp_x(end)-nowp_x(end-1)).^2+(nowp_y(end)-nowp_y(end-1)).^2+(nowp_z(end)-nowp_z(end-1)).^2) / sqrt(following_plan(end,1).^2+following_plan(end,2).^2+following_plan(end,3).^2);
            if tt > configure.Time_step           
                following_plan(end+1,:) = following_plan(end,:);
                following_point(end,:) = [min(following_point(end-1,1)+following_plan(end,1)*configure.Time_step, end_point(1)), min(following_point(end-1,2)+following_plan(end,2)*configure.Time_step, end_point(2)), min(following_point(end-1,3)+following_plan(end,3)*configure.Time_step,end_point(3)), following_point(end,4)];
            end
            if following_point(end,1) ~= end_point(1) || following_point(end,2) ~= end_point(2) || following_point(end,3) ~= end_point(3)
                following_point(end+1,:) = [end_point(1),end_point(2),end_point(3),following_point(end, 4)];
            end
            
    elseif exitflag <= 0
           plan_num = plan_num + 1;
           fprintf(2,'no solution for relax \n');
           no_solution_flag = 1;
%            break;
        nowp_x = [];
        nowp_y = [];
        nowp_z = [];
        ws = [];
        nowp_x(1) = current_point(1);
        nowp_y(1) = current_point(2);
        nowp_z(1) = current_point(3);
        ws(1) = current_point(4);
        for i = 1: size(following_plan,1) - 1
            nowp_x(i+1) = min(following_plan(i,1)*configure.Time_step + nowp_x(i), configure.grid_x-configure.radius);
            nowp_y(i+1) = min(following_plan(i,2)*configure.Time_step + nowp_y(i), configure.grid_y-configure.radius);
            nowp_z(i+1) = min(following_plan(i,3)*configure.Time_step + nowp_z(i), configure.grid_z-configure.radius);
            nowp_x(i+1) = max(nowp_x(i+1), 0);
            nowp_y(i+1) = max(nowp_y(i+1), 0);
            nowp_z(i+1) = max(nowp_z(i+1), 0);
            ws(i+1) = following_plan(i,4);
        end
        nowp_x = [nowp_x, configure.end_point(1)];
        nowp_y = [nowp_y, configure.end_point(2)];
        nowp_z = [nowp_z, configure.end_point(3)];
        ws = [ws, following_plan(end,4)];
        for i = 1 : length(nowp_x)
            following_point(i,:) = [nowp_x(i),nowp_y(i),nowp_z(i), ws(i)];
        end
        next_point = following_point(2,:);
        current_point = next_point;
        fprintf(2,'contiue the previous plan!!\n')
        fprintf('next point: [%f , %f, %f, %f]\n', current_point)
        traj = [trajectory; current_point];
        trajectory = traj;
        velocity_history = [velocity_history; following_plan(1,1), following_plan(1,2), following_plan(1,3), following_plan(1,4)];
        [a, b] = size(trajectory); %% to caculate the source used
        distance = 0;
        info = 0;
        engy = 0;
        for i = 1: a-1
             distance = distance + sqrt((trajectory(i+1,1)-trajectory(i,1)).^2+(trajectory(i+1,2)-trajectory(i,2)).^2+(trajectory(i+1,3)-trajectory(i,3)).^2);
             info = info + trajectory(i+1,4)*configure.Time_step;
             engy = engy + configure.battery_per *configure.Time_step * trajectory(i+1,4) + sqrt((trajectory(i+1,1)-trajectory(i,1)).^2+(trajectory(i+1,2)-trajectory(i,2)).^2+(trajectory(i+1,3)-trajectory(i,3)).^2);
        end
        for i = 1: size(velocity_history,1)-1
             engy = engy + configure.battery_per2 * sqrt((velocity_history(i+1,1)-velocity_history(i,1)).^2+(velocity_history(i+1,2)-velocity_history(i,2)).^2+(velocity_history(i+1,3)-velocity_history(i,3)).^2);
        end        
        energy = engy;
        past_distance = distance;
        time = configure.Time_step * (a-1);
        if time == 0
            information = 0;
        else
            information = info/time;
        end   
        current_step = current_step + 1;
        following_plan([1],:)=[]; %%update the following plan
        following_point([1],:)=[];
        
        tt = sqrt((nowp_x(end)-nowp_x(end-1)).^2+(nowp_y(end)-nowp_y(end-1)).^2+(nowp_z(end)-nowp_z(end-1)).^2) / sqrt(following_plan(end,1).^2+following_plan(end,2).^2+following_plan(end,3).^2);
        if tt > configure.Time_step           
            following_plan(end+1,:)=following_plan(end,:);
            following_point(end,:) = [min(following_point(end-1,1)+following_plan(end,1)*configure.Time_step, end_point(1)), min(following_point(end-1,2)+following_plan(end,2)*configure.Time_step, end_point(2)), min(following_point(end-1,3)+following_plan(end,3)*configure.Time_step,end_point(3)), following_point(end,4)];
        end
        if following_point(end,1) ~= end_point(1) || following_point(end,2) ~= end_point(2) || following_point(end,3) ~= end_point(3)
            following_point(end+1,:) = [end_point(1),end_point(2),end_point(3),following_point(end, 4)];
        end        
    end    
end