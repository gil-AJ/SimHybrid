function hs = case_base()
% Hybrid system data.
% Use the loadResources and updateHS functions before simulate or optimize
% the system.
%
%
% Autor: Antonio J. Gil Mena
% Departamento de Ingeniería Eléctrica
% Universidad de Cádiz
% Derechos reservados (C) 2021 Antonio J. Gil Mena
%
%% Simulation parameters
hs.S.n = 288;                   % Number of samples
hs.S.tsim = 24/hs.S.n;          % Time step expressed in hours
hs.S.estado = [];               % Different states of the hybrid system during the simulation (Five states. See simSHAPS.m file)
hs.S.powerDef = [];              % Deficit power of the simulation
hs.S.powerExc = [];               % Excess power of the simulation
%% Resources files
hs.RES.GFile = 'GfixFile';      % File with the information of the Irradiance(Global Irradiance on fix plane (W/m2), on sun-tracking plane (W/m2) and temperature (ºC)
hs.RES.wsFile = 'wsFile';       % File with the information of wind speed
%% PV panel
hs.PV.resources = [];           % Matrix of 3 colums [G, A, T] (Global Irradiance on fix plane (W/m2), on sun-tracking plane (W/m2) and temperature (ºC) and as many rows as samples
hs.PV.power = [];               % Matrix of 3 colums [Pgen, Pnet, Ploss] in W and as many rows as samples
hs.PV.data.kWp = 2;             % Rated kWp of the PV panel
hs.PV.data.type = 1;            % Type of PVpanel 1-> On fix plane,  2-> On sun-tracking plane
hs.PV.data.effi = 0.9;          % DC/DC Converter efficiency
hs.PV.data.kWpmax = 10;         % Upper limit used in optimization
hs.PV.data.kWpmin = 0;          % Lower limit used in optimization
hs.PV.data.invcost = 560;       % €/kWp Policristalino (314 €/kWp en Auto solar /
%% Wind turbine
hs.WT.power = [];               % Matrix of 3 colums [Pgen, Pnet, Ploss] in W and as many rows as samples
hs.WT.v = [];                   % Vector of wind speed in m/s. dimension = 1 x samples.
hs.WT.data.kW = 1;              % Rated power of the wind turbine
hs.WT.data.cuton = 2;           % Cut on wind speed of the wind turbine
hs.WT.data.cutoff = 20;         % Cut off wind speed of the wind turbine
hs.WT.data.model = 1;           % Model of the power curve of the wind turbine. 1-> Sigmoid function, 2-> Piece function, 3-> File defined function
hs.WT.data.effi = 0.9;          % DC/DC Converter efficiency
hs.WT.data.kWmax = 6;           % Upper limit used in optimization
hs.WT.data.kWmin = 0;           % Lower limit used in optimization
hs.WT.data.invcost = 1500;      % €/kW
%% Battery
hs.BATT.power = [];             % Matrix containing battery powers [PBAT_NET, PBAT, PBAT_LOSSES]
hs.BATT.energy = [];
hs.BATT.data.Wh = 2000;         % Rated capacity of the battery (Wh)
hs.BATT.data.effi = 0.9;        % Battery efficiency
hs.BATT.data.sigma = 0.004;     % Self-charge losses (%charge/h)
hs.BATT.data.SOCini = 50;       % State of charge (%)
hs.BATT.data.DoD = 80;          % Depth of discharge (%)
hs.BATT.data.Whmax = 8000;      % Upper limit used in optimization
hs.BATT.data.Whmin = 0000;      % Lower limit used in optimization
hs.BATT.data.invcost = 650;     % €/kWh Ion Litio
%% Diessel generator
hs.DG.power = [];               % Diessel generator power (W)
hs.DG.data.kVA = 0;             % Rated power (kVA)
hs.DG.data.fuelcost = 1.2;      % Fuel cost (€/l)
hs.DG.data.kVAmax = 6;          % Upper limit used in optimization
hs.DG.data.kVAmin = 0;          % Lower limit used in optimization
hs.DG.data.invcost = 200;       % €/kVA
hs.DG.data.fuelcons = ...       % l/h vs kW. Fuel consumption in litres per hour at x kW
                    @(x) 0.4*x;  
hs.DG.data.fuelprice = 1.2;     % €/litre of fuel
%% DC/AC converter
hs.CONV.power = [];             % Converter power losses (W)
hs.CONV.data.kW = 10;           % Rated power of the main converter DC/AC
hs.CONV.data.effi = 0.95;       % Converter efficiency
hs.CONV.data.invcost = 350;     % €/kW
%% Loads 
hs.LOAD.fix = [];               % Fix power demand in W. A vector of 1 x n samples
hs.LOAD.shift = [];             % Shiftable loads in W. A matrix of the number of shiftlable loads x n samples
hs.LOAD.power = [];             % Fix plus shiftable loads in W.  
hs.LOAD.energy = []; 
%                       NAME             RPOWER(kW)  ENABLE  SHIFTABLE  START                   END                             MIN_HOUR    MAX HOUR  HOURS      HOURLYD* 
hs.LOAD.appliances = {  'Washing machine'   0.450       1       1       [10]                    [12]                            [8]         [22]      [2]
                        'Dish water'        0.980       1       1       [16]                    [18]                            [8]         [22]      [2]
                        'Cloth Dryer'       1.500       1       1       [20]                    [21]                            [8]         [17]      [1]
                        'Vacuum cleaner'    1.300       1       1       [12]                    [12.5]                          [8]         [22]      [0.5]
                        'Iron'              1.500       1       1       [16]                    [16.25]                         [8]         [19]      [0.25]
                        'Refrigerator'      0.0625      1       0       [0]                     [24]                            []          []        [24]
                        'Standby'           0.030       1       0       [0]                     [24]                            []          []        [24]
                        'Light'             0.100       1       0       [7 19.5]                [8 23.5]                        []          []        [1 4]
                        'Ceramic stove'     1.500       1       0       [13 20]                 [13.5 20.20]                    []          []        [0.5 0.2]
                        'Microwave oven'    0.900       1       0       [13 17 19 21]           [13.15 17.15 19.15 21.15]       []          []        [0.15 0.15 0.15 0.15]
                        'TV+DSR'            0.090       1       0       [8 19]                  [10 23]                         []          []        [2 4]
                        'Computer'          0.100       1       0       [19]                    [22]                            []          []        [3]
                        'Air conditioned'   0.900       0       0       [15 16 17 ]             [15.5 16.5 17.5 ]               []          []        [0.5 0.5 0.5]
                        'Heating'           0.900       0       0       [18 19 20]              [18.5 19.5 20.5]                []          []        [0.5 0.5 0.5 ]
                        'Water pump'        9.000       0       1       [0]                     [8]                             []          []        [8 ]
                        'Electric Vehicle'  3.700       0       1       [0 23]                  [7 24]                          []          []        [7 1]   
                     };
%% Grid 
hs.GRID.price.paPot = 38.043426;% Peaje de acceso por potencia contratada. Coste en €/kW y por año
hs.GRID.price.ccPot = 3.113;    % Coste de comercialización del término de potencia. Coste en €/kW y por año
hs.GRID.price.paE = 0.044027;   % Peaje de acceso por energía consumida. Coste en €/kWh
hs.GRID.price.costE = prices;   % Matlab function file containing the prices of selling (.sell) and buying (.buy) for 24 hours of a day in €/kWh
hs.GRID.price.taxE = 5.11269632;% Impuesto especial de electricidad sobre el total de facturacion
hs.GRID.price.rent = 0.026571;  % Precio de alquiler de equipos de medida €/dia
hs.GRID.price.ContPower = 6.6;  % Potencia contratada en kW
hs.GRID.price.factura = [];     % [EnergyCost, EnergyToll, PowerTollyear, TradeCost, ElectricityTax, MeasurementRent, SellProfit]                               
hs.GRID.power = [];             % Power from/to the grid
%% Optimization 
hs.opt.objFile = 'objective';   % Objective function to be optimized
hs.opt.objIndex = 'COEg';       % Selection of the index to be optimized by the 'ojective' function.
                                % These indexes can be: COE,COG,BOG,COGE,NPC,LOLE,LOEE,LPSP and LLP
hs.opt.maxiter = 200;            % Maximun number of iterations for the optimization problem
hs.opt.popsize = 40;            % Population size of the state variables
hs.opt.runno = 1;               % The runno is the times that the algorithm runs (used for statistics)
hs.opt.penaltyValue = 1e12;     % High value in order to discard no feasible solutions
hs.opt.topology = 'connected';  % The system can be 'standalone' or 'connected' to grid
hs.opt.type = 6;                % Variables to optimize
                                % 1 Only Shiftable loads minimizing the end SOC of the battery
                                % 2 Shiftable loads plus sizing Battery
                                % 3 Shiftable loads plus sizing PV
                                % 4 Shiftable loads plus sizing Battery and PV
                                % 5 Shiftable loads plus sizing Battery, PV and Fuel Generator
                                % 6 Shiftable loads plus sizing Battery PV and WT
                                % 7 Shiftable loads plus sizing Battery, PV, WT and Fuel Generator                                              
hs.opt.results.x = [];          % Solution of the optimization algorithm (state variables)
hs.opt.results.obj = [];        % Solution of the optimization algorithm (objective function)
hs.opt.results.X = [];          % Solutions for all runs of the optimization algorithm (state variables)
hs.opt.results.OBJ = [];        % Solutions for all runs of the optimization algorithm (objective function)
hs.opt.data.endSOC = true;      % Constraint SOC at end equal or greater tha SOC at start
hs.opt.data.colapse = true;     % Constraint of colapse. If it is true indicates that is taken into acccount
hs.opt.data.nonIntRate = 1;     % Nominal interest rate in percent
hs.opt.data.inflation = 3;      % Inflation rate in percent
hs.opt.data.paybacktime = 15;   % Pay back time of the hybrid system in years
hs.opt.data.COE = [];           % Cost of energy of a standalone system (investment costs)
hs.opt.data.COEg = [];          % Cost of energy of a connected system (investment costs + cost of energy imported from the grid)
hs.opt.data.NPC = [];           % Net present cost of a standalone system
hs.opt.data.LOLE = [];          % Loss Of Load Expected
hs.opt.data.LOEE = [];          % Loss Of Energy Expected
hs.opt.data.LPSP = [];          % Loss of Power Supply Probability
hs.opt.data.LLP = [];           % Loss of Load Probability
hs.opt.stateVar = [];           % State variables to be optimized
hs.opt.stateVarObj = [];        % Value of the objective function evaluated at State variables
