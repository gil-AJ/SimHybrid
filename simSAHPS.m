function hs = simSAHPS(hs)
% Stand Alone Hybrid Power System SAHPS
%
% This function simulates a stand alone hybrid system formed by a PV panel,
% a wind turbine, a diessel generator and a battery. 
%
% Format: hs = simSAHPS(hs)
%
%
% Author: Antonio J. Gil Mena
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
PGENKW = hs.DG.data.kVA;
nc = hs.CONV.data.effi;
nb = hs.BATT.data.effi;
DoD = hs.BATT.data.DoD;
sigma = hs.BATT.data.sigma;
Tsim = hs.S.tsim;
%% Simulation
WBAT(1) = hs.BATT.data.Wh*hs.BATT.data.SOCini/100;
SOC(1) = 100*WBAT(1)/hs.BATT.data.Wh;
for k = 1:hs.S.n 
    PDEFICIT(k)=0;
    if PREN(k) > PLOAD(k)/nc  
        if SOC(k) >= 100 
            PBATautoloss(k) = WBAT(k)*sigma/100;
            PBAT_NET(k) = 0;
            PGEN(k) = 0;            
            PBATloss(k) = 0;             
            PBAT(k) = PBAT_NET(k) -PBATautoloss(k) -PBATloss(k);                       
            PCONVloss(k) = PLOAD(k)*(1-nc)/nc;
            PEXCESS(k) = PREN(k) - PBAT_NET(k) + (PGEN(k) - PLOAD(k))/nc;             
            estado(k) = 1; % Battery totally charged
        else 
            PBAT_WBAT_MAX = ( hs.BATT.data.Wh - WBAT(k) )/Tsim;
            PBAT_NOLIMIT = PREN(k) - PLOAD(k)/nc;
            PBAT_NET(k) = min([PBATmax, PBAT_WBAT_MAX, PBAT_NOLIMIT]);
            PBATautoloss(k) = WBAT(k)*sigma/100;
            PBATloss(k) = PBAT_NET(k)*(1-nb);
            PBAT(k) = PBAT_NET(k) - PBATloss(k) - PBATautoloss(k) ;
            PGEN(k) = 0; 
            PEXCESS(k) = PREN(k) - PBAT_NET(k) + (PGEN(k) - PLOAD(k))/nc;   
            PCONVloss(k) = PLOAD(k)*(1-nc)/nc;                
            estado(k) = 2; % Battery charging 
        end            
    else % PREN(k) < PLOAD(k)/nc 
        PBATtoDOD = ( WBAT(k) - hs.BATT.data.Wh*(1-0.01*DoD) )/Tsim; % Potencia a descargar de la bateria durante Tsim hasta llegar al DoD
        if PBATtoDOD < 0, PBATtoDOD = 0; end % Si PBATtoDOD < 0 implica que esta por debajo del SOC(DoD)       
        PBAT_NET_MAX = min(PBATmax,PBATtoDOD); % Potencia máxima que se puede extraer de la batería
        if PBAT_NET_MAX + PREN(k) > PLOAD(k)/nc  % ¿Puede la batería y las renovables suministrar a la carga?
            PGEN(k) = 0;          
            PBAT_NET(k) = PREN(k) - PLOAD(k)/nc; % Es negativa: Descarga
            PBATloss(k) = -PBAT_NET(k)*(1-nb)/nb; 
            PBATautoloss(k) = WBAT(k)*sigma/100;            
            PCONVloss(k) = PLOAD(k)*(1-nc)/nc;               
            PBAT(k) = PBAT_NET(k) - PBATautoloss(k) - PBATloss(k);
            PEXCESS(k) = PREN(k) - PBAT_NET(k) + (PGEN(k) - PLOAD(k))/nc;  
            estado(k) = 3; % Battery and renewable suply the load
        else          
            if 1000*PGENKW/nc + PBAT_NET_MAX + PREN(k) > PLOAD(k)/nc % ¿Puede la bateria, el generador y las renovables con la carga?              
                PBAT_NET(k) = -PBAT_NET_MAX; % Es negativa o cero: Descarga
                PBATloss(k) = -PBAT_NET(k)*(1-nb)/nb; 
                PBATautoloss(k) = WBAT(k)*sigma/100;     
                PBAT(k) = PBAT_NET(k) - PBATautoloss(k) - PBATloss(k);                                                              
                PGEN(k) = PLOAD(k) + ( PBAT_NET(k) - PREN(k) )*nc; 
                PCONVloss(k) = (PLOAD(k)-PGEN(k))*(1-nc)/nc;                                   
                PEXCESS(k) = PREN(k) - PBAT_NET(k) + (PGEN(k) - PLOAD(k))/nc; % Es cero
                estado(k) = 4; % Battery, renewable and Generator supply the load
            else % There is no energy enough to supply the load
                PGEN(k) = 0;
                PBAT_NET(k) = min([PREN(k),PBATmax,(hs.BATT.data.Wh-WBAT(k))/Tsim]);                   
                PBATautoloss(k) = WBAT(k)*sigma/100;
                PBATloss(k) = PBAT_NET(k)*(1-nb); 
                PBAT(k) = PBAT_NET(k) -PBATautoloss(k) -PBATloss(k);                              
                PCONVloss(k) = 0;                    
                PEXCESS(k) = 0;                     
                PDEFICIT(k) = PLOAD(k) - 1000*PGENKW - (PREN(k) + PBAT_NET(k))*nc;  % This power has not been used in the balance.  
                estado(k) = 5;   % Collapse. Battery is being charged by the renewable energy               
            end
        end
    end 
    WBAT(k+1) = WBAT(k) + PBAT(k)*Tsim; 
    SOC(k+1) = 100*WBAT(k)/hs.BATT.data.Wh;  
    % The following instructions are used only to test the power balance
    % In case os state 5 the balance are not met so it is not evaluated
    balk = sum(PREN(k)+PGEN(k)/nc-PLOAD(k)/nc-PEXCESS(k)-PBAT_NET(k));
    if abs(balk) > 1e-10 && estado(k)~=5, error('Balance is not met');end
end
% The last value is eliminated to size de vector to 288 entries
WBAT(end) = [];
hs.DG.power = PGEN';
hs.BATT.power = [PBAT_NET',PBAT',PBATloss'+PBATautoloss'];
hs.BATT.energy = WBAT';
hs.CONV.power = PCONVloss';
hs.S.estado = estado';
hs.S.powerDef = PDEFICIT';
hs.S.powerExc = PEXCESS';
hs.GRID.power = []; 


% Energies
hs.WT.energy = sum(hs.WT.power(:,2))*hs.S.tsim;
hs.PV.energy = sum(hs.PV.power(:,2))*hs.S.tsim;
hs.DG.energy = sum(hs.DG.power)*hs.S.tsim;
hs.GRID.energy = sum(hs.GRID.power)*hs.S.tsim;
hs.GRID.energyImp = sum(hs.GRID.power(hs.GRID.power>0))*hs.S.tsim;
hs.GRID.energyExp = sum(hs.GRID.power(hs.GRID.power<0))*hs.S.tsim;
hs.S.energyDef = sum(hs.S.powerDef)*hs.S.tsim;
hs.S.energyExc = sum(hs.S.powerExc)*hs.S.tsim;;
hs.BATT.energyLoss = sum(hs.BATT.power(:,3))*hs.S.tsim;
hs.CONV.energyLoss = sum(hs.CONV.power)*hs.S.tsim;
hs.LOAD.energy = sum(hs.LOAD.power)*hs.S.tsim;



