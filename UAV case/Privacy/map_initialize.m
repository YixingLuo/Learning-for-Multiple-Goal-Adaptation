%map initialize
function [map] = map_initialize(num,  num_p)
global configure
configure = Configure();
map = Environment();
name = 'gridmap-0.mat';
gridmap = load(name);
gridmap = gridmap.map;
obstacle_list = gridmap.obstacle_list;
map = map_initial_with_obstacle(map, num_p, obstacle_list);
% map = map_initial3(map, num_o, num_p);
name = 'gridmap-' + string(num) + '.mat';
save(name, 'map');



% map = Environment();
% map = map_initial3(map, 10, 0);
% name = 'gridmap-' + string(0) + '.mat';
% save(name, 'map');
% [data3, trajectory3,velocity_history,planning_time, rate_list, tag_list] = uav_relaxation(0);
% [data2, trajectory2,velocity_history,planning_time] = uav_relax(0);
% [data1, trajectory1,velocity_history,planning_time] = uav_normal(0);