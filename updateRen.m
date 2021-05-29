function hs = updateRen(hs)
% This function updates the renewable powers as the loads of the system.
% This function might be called every time the parameters that affect to
% the powers are modified.
%
% Format: hs = updateRen(hs)
%
% hs: It is the struct where the hybrid system is defined.
%
%
% Autor: Antonio J. Gil Mena
% Departamento de Ingeniería Eléctrica
% Universidad de Cádiz
% Derechos reservados (C) 2021 Antonio J. Gil Mena
%

%% Update PV power [Pgen, Pnet, Ploss] 
hs.PV.power(:,1) = hs.PV.data.kWp*hs.PV.resources(:,hs.PV.data.type);   % Pgen (W)
hs.PV.power(:,2) = hs.PV.power(:,1)*hs.PV.data.effi;                    % Pnet (W)
hs.PV.power(:,3) = hs.PV.power(:,1) - hs.PV.power(:,2);                 % Plosses (W)
%% Update WT power [Pgen, Pnet, Ploss]
v = hs.WT.v;  
von = hs.WT.data.cuton;
voff = hs.WT.data.cutoff; 
ind=find(v<von | v>voff);
if hs.WT.data.model == 1   
    fvon = 0.040060840794242;
    fvoff = 0.999396261032933;
    b = (voff-von)/log( ((1-fvon)*fvoff) / ((1-fvoff)*fvon) );
    a = von + b*log(1/fvon-1);   
    hs.WT.power(:,1) = 1000*hs.WT.data.kW./(1+exp(-(v-a)/b));          % Pgen (W)
elseif hs.WT.data.model == 2
    hs.WT.power(:,1) = 1000*hs.WT.data.kW*(v-von)/(voff-von);
else
    error('This option is not implemented') 
end
hs.WT.power(ind,1) = 0;
hs.WT.power(:,2) = hs.WT.power(:,1)*hs.WT.data.effi;                    % Pnet (W)
hs.WT.power(:,3) = hs.WT.power(:,1) - hs.WT.power(:,2);                 % Plosses (W)



