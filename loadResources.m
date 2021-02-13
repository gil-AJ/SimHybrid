function hs = loadResources(hs)
% hs: The struct file of the hybrid system
% Gfile: A mat file containing the Global Irradiance on fix plane (W/m2), on
%        sun-tracking plane (W/m2) and temperature (ºC). The variables
%        saved in Gfile are Gfix , Gtrack and Temp. If only one variable
%        is saved, it will suppose that is Gfix
% vfile: A mat file containing the wind speed in m/s. The name of the
%        variables must be ws
%
%
% Autor: Antonio J. Gil Mena
% Departamento de Ingeniería Eléctrica
% Universidad de Cádiz
% Derechos reservados (C) 2021 Antonio J. Gil Mena
%

load(hs.RES.GFile); % variables saved in Gfile must be Gfix, Gtrack and Temp
if exist('Gfix','var')
    hs.PV.resources = [Gfix]; 
    if exist('Gtrack','var')
        hs.PV.resources = [Gfix,Gtrack]; 
        if exist('Temp','var')
            hs.PV.resources = [Gfix,Gtrack,Temp];
        end
    end
else
    error(' Variable Gfix does not exist');
end

load(hs.RES.wsFile); % variable saved in vfile must be ws
if exist('ws','var')
    hs.WT.v = ws; 
else
    error(' Variable ws does not exist');
end

