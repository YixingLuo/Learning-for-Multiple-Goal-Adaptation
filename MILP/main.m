clc
clear
data1 = [];
data2 = [];
data3 = [];
data4 = [];
trajectory1 = [];
trajectory2 = [];
trajectory3 = [];
trajectory4 = [];
velocity_history1 = [];
velocity_history2 = [];
velocity_history3 = [];
velocity_history4 = [];
planningtime1 = zeros(100,100);
planningtime2 = zeros(100,100);
planningtime3 = zeros(100,100);
planningtime4 = zeros(100,100);
rate_list3 = zeros(100,100);



tag_list3 = zeros(100,100);
% index = [];

global eplison
eplison = [1e-20,1e-20,1e-10,1e-20,0.005];
iternum = 100;
num_o = [19];
num_p = [7];
    for np = 1:length(num_p)
        for no = 1:length(num_o)
            for i = 1 : iternum
                k = ceil(i/iternum);
                num_condition = i;
                map_initialize(i, num_o(no),num_p(np));
                [condition, indextemp] = randomsituation(num_condition,k);
                index(num_condition,:) =  indextemp;
                indextemp = index(i,:);
                iter = mod(num_condition,iternum);
                if iter == 0
                    iter = iternum;
                end          
                num_map = i;

                [data_1, trajectory,velocity_history,planning_time] = uav_normal(num_map,num_condition, indextemp);
                if data_1(1)> 0
                    data1(i,:) = data_1;
                    trajectory1 = [trajectory1; trajectory];
                    velocity_history1 = [velocity_history1; velocity_history];
                    planning_time =[planning_time; zeros(100-length(planning_time),1)];
                    planningtime1(:,i) = planning_time;                       
                end


                [data_2, trajectory,velocity_history,planning_time] = uav_relax(num_map, num_condition, indextemp);
                if data_2(1)> 0
                    data2(i,:) = data_2; 
                    trajectory2 = [trajectory2; trajectory];
                    velocity_history2 = [velocity_history2; velocity_history];
                    planning_time =[planning_time; zeros(100-length(planning_time),1)];                  
                    planningtime2(:,i) = planning_time;                      
                end


                [data_3, trajectory,velocity_history,planning_time,rate_list,tag_list] = uav_relaxation(num_map, num_condition, indextemp);
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

                [data_4, trajectory,velocity_history,planning_time] = uav_relax3(num_map, num_condition, indextemp);
                if data_4(1)> 0
                    data4(i,:) = data_4; 
                    trajectory4 = [trajectory4; trajectory];
                    velocity_history4 = [velocity_history4; velocity_history];
                    planning_time =[planning_time; zeros(100-length(planning_time),1)];                  
                    planningtime4(:,i) = planning_time;                      
                end
                
                if data_1(1)>0 && data_2(1)>0 && data_3(1)>0 && data_4(1)>0
                    data1 = [data1; data_1];
                    data2 = [data2; data_2];
                    data3 = [data3; data_3];
                    data4 = [data4; data_4];
                end

                if mod(num_condition,iternum)==0
                    data1(i + 1,:) = mean(data1(i-(iternum-1):i,:),1);
                    data2(i + 1,:) = mean(data2(i-(iternum-1):i,:),1);
                    data3(i + 1,:) = mean(data3(i-(iternum-1):i,:),1);
                    data4(i + 1,:) = mean(data4(i-(iternum-1):i,:),1);
                    time = datestr(now,30);
                    name = 'data' + string(time) + '_' + string(num_o(no))  + '_'+ string(num_p(np)) + '.mat';
                    save(name);
                    data1 = [];
                    data2 = [];
                    data3 = [];
                    data4 = [];
                    trajectory1 = [];
                    trajectory2 = [];
                    trajectory3 = [];
                    trajectory4 = [];
                    velocity_history1 = [];
                    velocity_history2 = [];
                    velocity_history3 = [];
                    velocity_history4 = [];
                    planningtime1 = zeros(100,100);
                    planningtime2 = zeros(100,100);
                    planningtime3 = zeros(100,100);
                    planningtime4 = zeros(100,100);
                    rate_list3 = zeros(100,100);
                    tag_list3 = zeros(100,100);
                    index = [];
                end
            end
        end
    end
% end

