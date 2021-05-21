clc;
clear all;

%%
weather = xlsread('TMY3.xlsx');
disp("weather data loaded")
temp_depth = xlsread('Tdepth.xlsx');
disp("temperature difference by depth data loaded(initial temp condition)")

save for_ground_simulate.mat