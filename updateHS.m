function hs = updateHS(hs)
% This function is needed for optimization.
% This function updates the hybrid system taken into account the new status
% variables, specially the shifable loads and the rated powers
% of the different equipments that forms the hybrid system. 
% All these variables depend on hs.opt.stateVar.
%
% Format: hs = updateHS(hs)
%
% hs: It is the struct where the hybrid system is defined.
%
%
% Autor: Antonio J. Gil Mena
% Departamento de Ingeniería Eléctrica
% Universidad de Cádiz
% Derechos reservados (C) 2021 Antonio J. Gil Mena
%
x = hs.opt.stateVar;

NAME = 1;       RPOWER = 2;     ENABLE = 3;     SHIFTABLE = 4;  START = 5;
END = 6;        MIN_HOUR = 7;   MAX_HOUR = 8;   HOURS = 9;      HOURLYD = 10;

sl = find([hs.LOAD.appliances{:,ENABLE}]==1 & [hs.LOAD.appliances{:,SHIFTABLE}]==1); % Enabled Shifable loads 
n = length(x);
X_sl = x(sl); % Shiftable variables
X = x(setdiff([1:n],sl)); % Sizing variables

% Update the shiftable variables, that is, the start times of shifable loads
for i=1:size(hs.LOAD.appliances,1)
    if hs.LOAD.appliances{i,ENABLE} == 1 & hs.LOAD.appliances{i,SHIFTABLE} == 1
        hs.LOAD.appliances{i,START} = X_sl(i);            
        hs.LOAD.appliances{i,END} =  X_sl(i) + hs.LOAD.appliances{i,HOURS};
    end
end
% Update Size variables (BATT, PV, WT, DG)
switch hs.opt.type           
    case {2}
        hs.BATT.data.Wh = X(1);       % Tamaño de la bateria en Wh (R.BAT_Wh)
    case {3} 
        hs.PV.data.kWp = X(1);        % X(c+2) = R.PV_kWp = kW para G = 1000 W/m2  
    case {4}
        hs.BATT.data.Wh = X(1);       % Tamaño de la bateria en Wh (R.BAT_Wh)
        hs.PV.data.kWp = X(2);        % X(c+2) = R.PV_kWp = kW para G = 1000 W/m2   
    case {5}
        hs.BATT.data.Wh = X(1);       % Tamaño de la bateria en Wh (R.BAT_Wh)
        hs.PV.data.kWp = X(2);        % X(c+2) = R.PV_kWp = kW para G = 1000 W/m2   
        hs.WT.data.kW = X(3);      
    case {6}
        hs.BATT.data.Wh = X(1);       % Tamaño de la bateria en Wh (R.BAT_Wh)
        hs.PV.data.kWp = X(2);        % X(c+2) = R.PV_kWp = kW para G = 1000 W/m2  
        hs.WT.data.kW = X(3);
    case {7}
        hs.BATT.data.Wh = X(1);       % Tamaño de la bateria en Wh (R.BAT_Wh)
        hs.PV.data.kWp = X(2);        % X(c+2) = R.PV_kWp = kW para G = 1000 W/m2  
        hs.WT.data.kW = X(3);
        hs.DG.data.kVA = X(4);             
end



