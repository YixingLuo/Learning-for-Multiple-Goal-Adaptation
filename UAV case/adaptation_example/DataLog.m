classdef DataLog
    properties 
        %% input
        env;
        system_state;
        configure;
        %% output
        behavior_plan;
        violation_flag;
        violation_degree;
        exitflag;
    end
     methods
        function datalog = DataLog()
            datalog.env=[];
            datalog.system_state=[];
            datalog.configure = [];
            datalog.behavior_plan = [];
            datalog.violation_flag = [];
            datalog.violation_degree = [];
            datalog.exitflag = [];
        end
        function datalog = InputLog(datalog, env, systen_state, configure)
            datalog.env = env;
            datalog.system_state = systen_state;
            datalog.configure = configure;
        end 
        function datalog = OutputLog(datalog, behavior_plan, violation_flag, violation_degree, exitflag)
            datalog.behavior_plan = behavior_plan;
            datalog.violation_flag = violation_flag;
            datalog.violation_degree = violation_degree;
            datalog.exitflag = exitflag;
        end 
     end
end