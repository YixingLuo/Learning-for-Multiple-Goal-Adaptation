Input:
Environment state: the class "env" contains the positions of obstacles and private regiosn within view radius in the format of [x,y,z]
空间大小为10*10*10, x,y,z的取值范围为[0,10].
环境状态应为当前UAV观测到的所有障碍物和隐私区域的位置信息，数组长度不固定，可能需要填充

System state: the variable "system_state" system_state = [x,y,z,ws,accuracy, energy consumption, time]
[x,y,z]的取值范围为[0,10]为UAV的坐标位置
ws的取值范围为[0,1]为UAV sensor accuracy
accuracy的取值范围为[0,1]，为UAV过去时间内平均的sensor accuracy
energy consumption的取值范围为[0,datalog.configure.battery_budget]，为UAV已经消耗的能量
time的取值范围为[0,datalog.configure.Time_budget]，为UAV已经飞行的时间

Configurations: the class "configure"
				More related: 
				和需求相关的变量：
				datalog.configure.battery_budget (fixed), datalog.configure.battery_target ([12, 20]), datalog.configure.forensic_target ([0.85, 1]),datalog.configure.forensic_budget(fixed), datalog.configure.Time_target ([9,15]), datalog.configure.Time_budget(fixed), 
				系统参数变量:
				datalog.configure.battery_per ([0.5,0.6]), datalog.configure.battery_per2 [0.2,0.24], datalog.configure.velocity_max ([0.8,1]), datalog.configure.velocity_min ([-1,-0.8]), datalog.configure.sensor_accuracy ([0.8,1]), 

				Less related: 
				Missions:
				datalog.configure.start_point (fixed [0,0,0]), datalog.configure.end_point (fixed [9,9,9])				
				datalog.configure.obstacle_radius (fixed), datalog.configure.privacy_radius (fixed), datalog.configure.obstacle_max (fixed), datalog.configure.privacy_max (fixed), datalog.configure.radius (fixed) 
可以尝试依次增加输入变量的维度

Output: 
step1: violation_flag (五维的布尔变量组成的向量)
step2: violation_degree (五维实数变量组成的向量，每个变量取值0~1)
step3: behavior_plan: it is used as the initial value for the optimization problem, in the format of v_x,v_y,v_z,ws in the column, and time t=t0, t0+1,t0+2, t0+3 with predict horizon N=5
v_x,v_y,v_z,ws的取值范围为[0,1], 每一列为一个时间下的 [v_x,v_y,v_z,ws]


可以在文件"dataset_generation.m"预处理数据的基础上修改。