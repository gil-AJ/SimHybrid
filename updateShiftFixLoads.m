function hs = updateShiftFixLoads(hs)
% This function updates the fix and shiftable loads of the system and also 
% the total power as a sumation of fix and shiftable loads based on the 
% following parameters:
%
% RPOWER: rated power of the load
% ENABLE: The load is taken into account
% SHIFTABLE: The loads is considered as shiftable
% START: This is the start time of the shiftable load
% END: This is the end time of the shiftable load
%
% Format: hs = updateLoads(hs)
%
% hs: It is the struct where the hybrid system is defined.
%
%
% Autor: Antonio J. Gil Mena
% Departamento de Ingeniería Eléctrica
% Universidad de Cádiz
% Derechos reservados (C) 2021 Antonio J. Gil Mena
%

if hs.S.simtime ~= 1
	error(' The simulation time for residential loads are expected to be 24 hours');
end

Ts = hs.S.tsim;
%% Constants to ease the access to the columns of the appliances cell
NAME = 1;       RPOWER = 2;     ENABLE = 3;     SHIFTABLE = 4;  START = 5;
END = 6;        MIN_HOUR = 7;   MAX_HOUR = 8;   HOURS = 9;      HOURLYD = 10;
%% Check if the HOUR column is in accordance with START and END columns
for i=1:size(hs.LOAD.appliances,1)    
    if abs(sum(hs.LOAD.appliances{i,HOURS} - hs.LOAD.appliances{i,END} + hs.LOAD.appliances{i,START}))>1e-9
        error(' Data in column HOURS must be END - START times in shifable loads');
    end
end
%% Update the vectors of the each appliance based on the START, END and tsim times and saves it in  the colum HOURLYD
j = 0; 
for i=1:size(hs.LOAD.appliances,1)    
    if hs.LOAD.appliances{i,ENABLE} == 1 % Cargas habilitadas (Enable=1)		
        P_ON = zeros(24/hs.S.tsim,1);
        j = j + 1;
        for k = 1:length(hs.LOAD.appliances{i,START})
            t_ini = hs.LOAD.appliances{i,START}(k);
            t_fin = hs.LOAD.appliances{i,END}(k);
            P_ON( uint32(1 + t_ini/Ts) : uint32(t_fin/Ts) ) = 1;
        end 
        hs.LOAD.appliances{i,HOURLYD} = P_ON*hs.LOAD.appliances{i,RPOWER}';
    end
end
%% Calculate the shiftable and fix loads based on HOURLYD for a day
P_SHIFT = []; P_FIX = 0;
for i=1:size(hs.LOAD.appliances,1)
    if hs.LOAD.appliances{i,ENABLE} == 1 & hs.LOAD.appliances{i,SHIFTABLE} == 1
        P_SHIFT = [P_SHIFT , 1000*hs.LOAD.appliances{i,HOURLYD}];            
    end
    if hs.LOAD.appliances{i,ENABLE} == 1 & hs.LOAD.appliances{i,SHIFTABLE} == 0
        P_FIX = P_FIX + 1000*hs.LOAD.appliances{i,HOURLYD};            
    end
end

hs.LOAD.fix = P_FIX;           
hs.LOAD.shift = P_SHIFT;  
hs.LOAD.power = hs.LOAD.fix + sum(hs.LOAD.shift')';
