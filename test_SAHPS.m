%% TEST the Stand alone Hybrid power system
% This file is used to test the software. 
% These files allow to do a simulation of a standalone hybrid system 
%
close all;
clear all; clc;
%% Data
% Load the hybrid system
hs = base_case;
% Load the resources (Irradiance and wind speed) saved in mat files
hs = loadResources(hs);
% Update the powers (PV,WT,LOAD) of the system
hs = updateRen(hs);
hs = updateShiftFixLoads(hs);  % This file is used to define fix and shifable residential loads
%% Simulation of the Hybrid System
hs = simSAHPS(hs);
% Print the results of the simulation
printResults(hs);

