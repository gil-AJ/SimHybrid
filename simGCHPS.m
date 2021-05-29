function hs = simGCHPS(hs)
% Grid Connected Hybrid Power System GCHPS
%
% This function simulates a Grid Connected Hybrid Power System formed by a PV panel,
% a wind turbine and a battery. 
%
% Format: hs = simGCHPS(hs)
%
%
% Autor: Antonio J. Gil Mena
% Departamento de Ingeniería Eléctrica
% Universidad de Cádiz
% Derechos reservados (C) 2021 Antonio J. Gil Mena
%
% See also: simGCHPS.m

%% Updating powers
PWT = hs.WT.power(:,2);
PPV = hs.PV.power(:,2);
PREN = PWT+PPV;
PBATmax = hs.BATT.data.Wh;  % Discharge/charge rate = C1
%PLOAD = hs.LOAD.fix + sum(hs.LOAD.shift')';
PLOAD = hs.LOAD.power;
nc = hs.CONV.data.effi;
nb = hs.BATT.data.effi;
DoD = hs.BATT.data.DoD;
sigma = hs.BATT.data.sigma;
Tsim = hs.S.tsim;
%% Simulation
WBAT(1) = hs.BATT.data.Wh*hs.BATT.data.SOCini/100;
SOC(1) = 100*WBAT(1)/hs.BATT.data.Wh;
for k = 1:hs.S.n 
    if PREN(k) > PLOAD(k)/nc  
        if SOC(k) >= 100 
            PBATautoloss(k) = WBAT(k)*sigma/100;
            PBAT_NET(k) = 0;         
            PBATloss(k) = 0;             
            PBAT(k) = PBAT_NET(k) -PBATautoloss(k) -PBATloss(k);                       
            PCONVloss(k) = (PREN(k) - PBAT_NET(k))*(1-nc);
            PGRID(k) = PLOAD(k) - (PREN(k) - PBAT_NET(k))*nc;             
            estado(k) = 1; % Battery totally charged
        else 
            PBAT_WBAT_MAX = ( hs.BATT.data.Wh - WBAT(k) )/Tsim;
            PBAT_NOLIMIT = PREN(k) - PLOAD(k)/nc;
            PBAT_NET(k) = min([PBATmax, PBAT_WBAT_MAX, PBAT_NOLIMIT]);
            PBATautoloss(k) = WBAT(k)*sigma/100;
            PBATloss(k) = PBAT_NET(k)*(1-nb);
            PBAT(k) = PBAT_NET(k) - PBATloss(k) - PBATautoloss(k) ;            
            PCONVloss(k) = (PREN(k) - PBAT_NET(k))*(1-nc);
            PGRID(k) = PLOAD(k) - (PREN(k) - PBAT_NET(k))*nc;  
            estado(k) = 2; % Battery charging 
        end            
    else % PREN(k) < PLOAD(k)/nc 
        PBATtoDOD = ( WBAT(k) - hs.BATT.data.Wh*(1-0.01*DoD) )/Tsim; % Potencia a descargar de la bateria durante Tsim hasta llegar al DoD
        if PBATtoDOD < 0, PBATtoDOD = 0; end % Si PBATtoDOD < 0 implica que esta por debajo del SOC(DoD)       
        PBAT_NET_MAX = min(PBATmax,PBATtoDOD); % Potencia máxima que se puede extraer de la batería
        if PBAT_NET_MAX + PREN(k) >= PLOAD(k)/nc  % ¿Puede la batería y las renovables suministrar a la carga?  
            PBAT_NET(k) = PREN(k) - PLOAD(k)/nc; 
            PGRID(k) = PLOAD(k) - (PREN(k) - PBAT_NET(k))*nc;             
            PBATloss(k) = -PBAT_NET(k)*(1-nb)/nb; 
            PBATautoloss(k) = WBAT(k)*sigma/100;            
            PCONVloss(k) = (PREN(k) - PBAT_NET(k))*(1-nc);               
            PBAT(k) = PBAT_NET(k) - PBATautoloss(k) - PBATloss(k);
            PGRID(k) = 0;  
            estado(k) = 3; % Battery and renewable suply the load and grid
        else                     
            PBAT_NET(k) = 0;
            PBATloss(k) = 0; 
            PBATautoloss(k) = WBAT(k)*sigma/100;     
            PBAT(k) = PBAT_NET(k) - PBATautoloss(k) - PBATloss(k);    
            PGRID(k) = PLOAD(k) - (PREN(k) - PBAT_NET(k))*nc; 
            PCONVloss(k) = (PREN(k) - PBAT_NET(k))*(1-nc);                                     
            estado(k) = 4; % Renewable and Grid supply the load
        end
    end 
    WBAT(k+1) = WBAT(k) + PBAT(k)*Tsim; 
    SOC(k+1) = 100*WBAT(k)/hs.BATT.data.Wh;  
    % The following instructions are used only to test the power balance   
    balk = sum( (PREN(k)-PBAT_NET(k))*nc + PGRID(k) - PLOAD(k) );
    if abs(balk) > 1e-10, error('Balance is not met');end
end
% The last value is eliminated to size de vector to 288 entries
WBAT(end) = [];
hs.DG.power = [];
hs.BATT.power = [PBAT_NET',PBAT',PBATloss'+PBATautoloss'];
hs.BATT.energy = WBAT';
hs.CONV.power = PCONVloss';
hs.GRID.power = PGRID'; 
hs.S.estado = estado';
hs.S.powerDef = 0;
hs.S.powerExc = 0;

% Energies
hs.WT.energy = sum(hs.WT.power(:,2))*hs.S.tsim;
hs.PV.energy = sum(hs.PV.power(:,2))*hs.S.tsim;
hs.DG.energy = sum(hs.DG.power)*hs.S.tsim;
hs.GRID.energy = sum(hs.GRID.power)*hs.S.tsim;
hs.GRID.energyImp = sum(hs.GRID.power(hs.GRID.power>0))*hs.S.tsim;
hs.GRID.energyExp = sum(hs.GRID.power(hs.GRID.power<0))*hs.S.tsim;
hs.S.energyDef = 0;
hs.S.energyExc = 0;
hs.BATT.energyLoss = sum(hs.BATT.power(:,3))*hs.S.tsim;
hs.CONV.energyLoss = sum(hs.CONV.power)*hs.S.tsim;
hs.LOAD.energy = sum(hs.LOAD.power)*hs.S.tsim;



