clc
clear
data3 = [];
trajectory3 = [];
velocity_history3 = [];
planningtime3 = zeros(100,100);
rate_list3 = zeros(100,100);
tag_list3 = zeros(100,100);

global eplison
eplison = [0,0,1e-6,1e-6,1e-6];
iternum = 1000;
num_o = [38];
num_p = [14];
    for np = 1:length(num_p)
        for no = 1:length(num_o)
            for i = 1 : iternum
                k = ceil(i/iternum);
                num_condition = i;
                map_initialize(i, num_o(no),num_p(np));
                [condition, indextemp] = randomsituation(num_condition,k);
                index(num_condition,:) =  indextemp;
    %             indextemp = index(num,:);
                iter = mod(num_condition,iternum);
                if iter == 0
                    iter = iternum;
                end          
                num_map = i;


                [data_3, trajectory,velocity_history,planning_time,rate_list,tag_list] = uav_ReqAdapt(num_map, num_condition, indextemp);
                if data_3(1)> 0
                    data3(i,:) = data_3;
                    trajectory3 = [trajectory3; trajectory];
                    velocity_history3 = [velocity_history3; velocity_history];
                    planning_time =[planning_time; zeros(100-length(planning_time),1)];               
                    planningtime3(:,i) = planning_time;
                    rate_list_ = [rate_list, zeros(5,100-size(rate_list,2))];
                    tag_list_ =  [tag_list, zeros(5,100-size(tag_list,2))];
                    rate_list3((iter-1)*5+1:iter*5,:) = rate_list_;
                    tag_list3((iter-1)*5+1:iter*5,:) = tag_list_;                       
                end


                if mod(num_condition,iternum)==0
                    data3(i + 1,:) = mean(data3(i-(iternum-1):i,:),1);
                    time = datestr(now,30);
                    name = 'data' + string(time) + '_' + string(num_o(no))  + '_'+ string(num_p(np)) + '.mat';
                    save(name);
                    data3 = [];
                    trajectory3 = [];
                    velocity_history3 = [];
                    planningtime3 = zeros(100,100);
                    rate_list3 = zeros(100,100);
                    tag_list3 = zeros(100,100);
                    index = [];
                end
            end
        end
    end


