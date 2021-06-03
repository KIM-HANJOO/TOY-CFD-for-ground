clc;
clear all;

load('vent_and_infilt.mat', 'T_all')
T_airtube = T_all;
save('T_airtube.mat', 'T_airtube')
