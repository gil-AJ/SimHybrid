function printResults(hs)
% Prints the resultas of the simulation in two figures.
%
% Format: print_results(hs)
%
%
% Autor: Antonio J. Gil Mena
% Departamento de Ingeniería Eléctrica
% Universidad de Cádiz
% Derechos reservados (C) 2021 Antonio J. Gil Mena
%

if ~isempty(hs.GRID.power)
    power = hs.GRID.power; % GCHPS
    text = 'grid';
    ngraf = 2;
else
    power = hs.DG.power; % SAHPS
    text = 'fuel';
    ngraf = 3;
end
TIEMPO = [0:hs.S.tsim:24-hs.S.tsim]';
figure();
subplot(ngraf,1,1);stairs(TIEMPO,100*hs.BATT.energy/hs.BATT.data.Wh,'LineWidth',1.5); title('Estado de carga de la batería (SOC)');
axis([0 24 0 110]);
ax=gca;ax.XTick = 0:24;
subplot(ngraf,1,2);stairs(TIEMPO,[hs.PV.power(:,2)+hs.WT.power(:,2),...
                              hs.LOAD.fix+sum(hs.LOAD.shift')',...
                              hs.BATT.power(:,1),power],...
                              'LineWidth',1.5); title('Potencias');legend('renewable','load','battery',text,'Location','northwest');
axis([0 24 -Inf Inf]);
ax=gca;ax.XTick = 0:24;
if ngraf ==3
    subplot(ngraf,1,3);stairs(TIEMPO,[hs.S.powerDef,hs.S.powerExc],'LineWidth',1.5); title('Potencias');legend('Deficit','Excess','Location','northwest');
    axis([0 24 0 Inf]);
    ax=gca;ax.XTick = 0:24;
end

figure();
subplot(2,1,1);stairs(TIEMPO,hs.LOAD.shift,'LineWidth',1.5);title('Shiftable loads kW');
axis([0 24 0 Inf]);
ax=gca;ax.XTick = 0:24;
subplot(2,1,2);plot(TIEMPO,hs.S.estado,'o');title('Estado del sistema');
axis([0 24 -Inf Inf]);
ax=gca;ax.XTick = 0:24;

%% Presentacion de balance de energías
fprintf('\n\n BALANCE DE ENERGÍAS\n\n');
disp( array2table([hs.WT.energy,hs.PV.energy,hs.DG.energy,hs.GRID.energyImp,-hs.GRID.energyExp,hs.S.energyDef,...
                   hs.S.energyExc,hs.BATT.energyLoss,hs.CONV.energyLoss,hs.LOAD.energy,hs.BATT.energy(1),hs.BATT.energy(end)],...
    'VariableNames',{'WT' 'PV' 'DG' 'GRIDImp' 'GRIDExp' 'DEFICIT','EXCESS','LOSSbatt','LOSSconv','LOAD','BATTini','BATTend'}) );



%% Presentacion de soluciones de la optimizacion
if ~isempty(hs.opt.results.X)
    fprintf('\n\n SOLUCION DE LA OPTIMIZACION\n\n');
    switch hs.opt.type
        case{1}
            disp( array2table([hs.opt.results.X,hs.opt.results.OBJ],'VariableNames',{'x1' 'x2' 'x3' 'x4' 'x5' 'Objective'}) );
        case{2}
            disp( array2table([hs.opt.results.X,hs.opt.results.OBJ],'VariableNames',{'x1' 'x2' 'x3' 'x4' 'x5' 'WhBAT' 'Objective'}) );       
        case{3}
            disp( array2table([hs.opt.results.X,hs.opt.results.OBJ],'VariableNames',{'x1' 'x2' 'x3' 'x4' 'x5' 'kWpPV' 'Objective'}) ); 
        case{4}
            disp( array2table([hs.opt.results.X,hs.opt.results.OBJ],'VariableNames',{'x1' 'x2' 'x3' 'x4' 'x5' 'WhBAT' 'kWpPV' 'Objective'}) );
        case{5}
            disp( array2table([hs.opt.results.X,hs.opt.results.OBJ],'VariableNames',{'x1' 'x2' 'x3' 'x4' 'x5' 'WhBAT' 'kWpPV' 'kVAFuel' 'Objective'}) );        
        case{6}
            disp( array2table([hs.opt.results.X,hs.opt.results.OBJ],'VariableNames',{'x1' 'x2' 'x3' 'x4' 'x5' 'WhBAT' 'kWpPV' 'kWWT' 'Objective'}) );                    
        case{7}
            disp( array2table([hs.opt.results.X,hs.opt.results.OBJ],'VariableNames',{'x1' 'x2' 'x3' 'x4' 'x5' 'WhBAT' 'kWpPV' 'kWWT' 'kVAFuel' 'Objective'}) );     
    end
end
