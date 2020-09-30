Input:
Environment state: the class "env" contains the positions of obstacles and private regiosn within view radius in the format of [x,y,z]
环境状态应为当前UAV观测到的所有障碍物和隐私区域的位置信息，数组长度不固定，可能需要填充
System state: the variable "system_state" system_state = [x,y,z,ws,accuracy, energy consumption, time]
Configurations: the class "configure"
				More related: 
				Goals:
				datalog.configure.battery_budget, datalog.configure.battery_target, datalog.configure.battery_per, datalog.configure.forensic_target,datalog.configure.forensic_budget, datalog.configure.Time_target, datalog.configure.Time_budget, 
				System parameters:
				datalog.configure.battery_per2, datalog.configure.velocity_max, datalog.configure.velocity_min, datalog.configure.sensor_accuracy, 
				Missions:
				datalog.configure.start_point, datalog.configure.end_point
				Less related: datalog.configure.obstacle_radius, datalog.configure.privacy_radius, datalog.configure.obstacle_max, datalog.configure.privacy_max, datalog.configure.radius 
可以尝试依次增加输入变量的维度

Output: 
step1: violation_flag
step2: violation_degree
step3: behavior_plan: it is used as the initial value for the optimization problem, in the format of v_x,v_y,v_z,ws in the row, and time t=t0, t0+1,t0+2, t0+3 with predict horizon N=4


可以在文件"dataset_generation.m"预处理数据的基础上修改。