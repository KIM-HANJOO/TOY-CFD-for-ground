clc;
%clear all;
load('for_ground_simulate.mat')
%% 253번이 T_out, 254번이 T_sky

%% inputs needed

mesh = 6;
meshsize = 2;

% mesh numbers, consider T_sky + T_out later
N_node_go = mesh * mesh * (mesh + 1);
N_node_all = N_node_go + 2;
N_weather = max(size(weather(:, 1)));

M = zeros(N_node_go + 2, N_node_go + 2);
S = zeros(N_node_go + 2 + 1, N_node_go + 2 + 1);
f = zeros(N_node_go + 2, 1);

%% Material properties

soil_conductivity = 0.44;
soil_specific_heat = 1175.56; %733; % J/kg*degC
soil_solar_absorptance = 0.6;
soil_h_rad = 5.5; % W/m²K
soil_h_conv = 2.5; % W/m²K
soil_density = 1; %1600; %kg/m^3

m = soil_density * soil_specific_heat * meshsize * meshsize; % * [1, 0; 0, 1];
S_cond = 1/4 * soil_conductivity * meshsize * [1, -1; -1, 1];
S_conv = soil_h_conv * meshsize * meshsize * [1, -1; -1, 1];
S_rad = soil_h_rad * meshsize * meshsize * [1, -1; -1, 1];

%% not for now
floor_node = 1000;

%% matching numbers with coordinates
Node_info = zeros(N_node_go, 10);

for i = 1 : N_node_go
    for x = 0 : mesh - 1
        for y = 0 : mesh - 1
            for z = 0 : mesh
                if x + mesh * y + mesh * mesh * z == i - 1
                    Node_info(i, 2) = x;
                    Node_info(i, 3) = y;
                    Node_info(i, 4) = z;
                end
            end
        end
    end
end

clearvars x;
clearvars y;
clearvars z;

%% give nodes status including BC

for i = 1 : N_node_go
    if Node_info(i, 2) == 0 % x equals 0
        Node_info(i, 1) = 1;
    end
    
    if Node_info(i, 2) == mesh - 1 % x equals end
        Node_info(i, 1) = 1;
    end
    
    if Node_info(i, 3) == 0 % y값 0
        Node_info(i, 1) = 1;
    end
    
    if Node_info(i, 3) == mesh - 1 % y equals end
        Node_info(i, 1) = 1;
    end
    
    if Node_info(i, 4) == 0 % z equals 0
        Node_info(i, 1) = 3;
    end
    
    if Node_info(i, 4) == mesh % z equals end
        Node_info(i, 1) = 4;
    end
    
end


%% Count node types

n_type_0 = 0; % normal
n_type_1 = 0; % BC
n_type_3 = 0; % BC (floor)
n_type_4 = 0; % surface

for i = 1 : N_node_go
     if Node_info(i, 1) == 0
        n_type_0 = n_type_0 + 1;
     end
    
    if Node_info(i, 1) == 1
        n_type_1 = n_type_1 + 1;
    end
    
    if Node_info(i, 1) == 3
        n_type_3 = n_type_3 + 1;
    end
    
    if Node_info(i, 1) == 4
        n_type_4 = n_type_4 + 1;
    end
end

%% Deciding adjacent nodes


for i = 1 : N_node_go
    for j = 1 : N_node_go
        % x axis direction adjacent (2 nodes)
        if Node_info(j, 3) == Node_info(i, 3) % same x
        if Node_info(j, 4) == Node_info(i, 4) % same z
            
            if Node_info(j, 2) == Node_info(i, 2) - 1 % x direction -1
                Node_info(i, 5) = j;
            elseif Node_info(i, 2) - 1 < 0
                Node_info(i, 5) = N_node_go + 2 + 1;
            end
            
            if Node_info(j, 2) == Node_info(i, 2) + 1 % x direction +1
                Node_info(i, 6) = j;
            elseif Node_info(i, 2) + 1 > mesh - 1
                Node_info(i, 6) = N_node_go + 2 + 1;
            end
            
        end
        end        
        
        % y axis direction adjacent (2 nodes)
        if Node_info(j, 2) == Node_info(i, 2) % same x
        if Node_info(j, 4) == Node_info(i, 4) % same z
            
            if Node_info(j, 3) == Node_info(i, 3) - 1 % y direction -1
                Node_info(i, 7) = j;
            elseif Node_info(i, 3) - 1 < 0
                Node_info(i, 7) = N_node_go + 2 + 1;
            end
            
            if Node_info(j, 3) == Node_info(i, 3) + 1 % y direction +1
                Node_info(i, 8) = j;
            elseif Node_info(i, 3) + 1 > mesh - 1
                Node_info(i, 8) = N_node_go + 2 + 1;
            end
        
        end
        end        
        
        % z axis direction adjacent (2 nodes)
        if Node_info(j, 2) == Node_info(i, 2) % same x
        if Node_info(j, 3) == Node_info(i, 3) % same y

            if Node_info(j, 4) == Node_info(i, 4) - 1 % z direction -1
                Node_info(i, 9) = j;
            elseif Node_info(i, 4) - 1 < 0
                Node_info(i, 9) = N_node_go + 2 + 1;
            end
            
            if Node_info(j, 4) == Node_info(i, 4) + 1 % z direction +1
                Node_info(i, 10) = j;
            elseif Node_info(i, 4) + 1 > mesh
                Node_info(i, 10) = N_node_go + 2 + 1;
            end

        end
        end        
    end
end

clearvars x;
clearvars y;
clearvars z;

%% Making of M matrix

% M 
for i = 1 : N_node_go
    if Node_info(i, 1) == 4
        M(i, i) = m / 2;
    else
        M(i, i) = m;
    end
end

%% Making of S matrix

clearvars x;
clearvars y;

x = zeros(2, 1); % cond
y = zeros(2, 1); % conv
z = zeros(2, 1); % longwave

for i = 1 : N_node_go
    
    x(1, 1) = i;
    
    %%% ground nodes, only conduction
    if Node_info(i, 1) ~= 4
        for j = 5 : 10
            x(2, 1) = Node_info(i, j);
            for g = 1 : 2; h = 1 : 2;
                S(x(g,1), x(h,1)) = S(x(g,1), x(h,1)) + S_cond(g,h);
            end
        end
        
        %%% surface nodes
    elseif Node_info(i, 1) == 4
        % add **conduction between surface nodes and 5 other adjacent nodes
        for j = 5 : 9
            x(2, 1) = Node_info(i, j);
            for n1 = 1 : 2; n2 = 1 : 2;
                S(x(n1,1), x(n2,1)) = S(x(n1,1), x(n2,1)) + S_cond(n1, n2);
            end
        end
        
        % add **convection between surface nodes and T_out
        y(1, 1) = i;
        y(2, 1) = N_node_go + 1;
        for n3 = 1 : 2; n4 = 1 : 2;
            S(y(n3,1), y(n4,1)) = S(y(n3,1), y(n4,1)) + S_conv(n3, n4);
        end
        
        % add **longwave radiation between surface nodes and T_sky
        z(1, 1) = i; 
        z(2, 1) = N_node_go + 2;
        for n5 = 1 : 2; n6 = 1 : 2;
            S(z(n5,1), z(n6,1)) = S(z(n5,1), z(n6,1)) + S_rad(n5, n6);
        end
        
        %%% building nodes (excepted in this code)
    elseif Node_info(i, 1) == 2
        for j = 5 : 9
        x(2, 1) = Node_info(i, j);
        for n1 = 1 : 2; n2 = 1 : 2;
            S(x(n1,1), x(n2,1)) = S(x(n1,1), x(n2,1)) + S_cond(n1, n2);
        end
        end
        
        y(2, 1) = i;
        y(2, 2) = floor_node;
        for n1 = 1 : 2; n2 = 1 : 2;
            S(y(n1,1), y(n2,1)) = S(y(n1,1), y(n2,1)) + S_cond(n1, n2);
        end
    end   
end

%%
clearvars n1; clearvars n2; clearvars n3;
clearvars n4; clearvars n5; clearvars n6;
clearvars x; clearvars y; clearvars z;
clearvars g; clearvars h;
clearvars j; clearvars i;

%% delete the tail of S matrix

S_convert = zeros(N_node_all, N_node_all);
S_convert = S(1 : end - 1, 1 : end - 1);
clearvars S;
S = S_convert;
clearvars S_convert;

%% Boundary conditions

for i = 1 : N_node_go
    if Node_info(i, 1) == 3
        M(i, :) = 0;
        S(i, :) = 0;
        S(i, i) = 1;
    elseif Node_info(i, 1) == 1
        M(i, :) = 0;
        S(i, :) = 0;
        S(i, i) = 1;
    end
end

M(N_node_go + 1 : N_node_all, :) = 0;
S(N_node_go + 1 : N_node_all, :) = 0;
S(N_node_go + 1 : N_node_all, N_node_go + 1 : N_node_all) = 1;


%% Load Tdepth.xlsx
% load('update_initial_condition.mat')
T_depth = xlsread('Tdepth.xlsx');

%% Making of f matrix
f(N_node_go + 2, 1) = 1;

for i = 1 : N_node_go
    if Node_info(i, 1) ~= 0
        if Node_info(i, 1) ~= 4
            f(i, 1) = T_depth(2 * Node_info(i, 4) + 1, 2);
        end
    end
end

%% Set initial Temperature
T_00 = 25 * ones(N_node_all, 1);
% for i = 1 : N_node_go
%     T_00(i, 1) = T_depth(2 * Node_info(i, 4) + 1, 2);
% end
% T_00(N_node_go + 1, 1) = 25;
% T_00(N_node_go + 2, 1) = 1;
% 
% T_all = zeros(N_weather, 3 + N_node_all);
% T_all(:, 1:3) = weather(:, 1:3);

%% solve ODE

disp('solving ODE')

tspan = [0 : 1];

for i  = 1 : N_weather
    %%% f update
    f(N_node_go + 1, 1) = weather(i, 4);
    
    %%% update bc nodes
    %%%
    for j = 1 : N_node_go
        if Node_info(j, 1) == 4 % for surface nodes
            f(j, 1) = soil_solar_absorptance * meshsize * meshsize * weather(i, 9);
        end
    end
    
    [t,T]=unsteady(tspan, T_00, M, S, f);
    T_00 = T(end, :);
    T_all(i, 4:N_node_g2 + N_node + 3) = T_00;
    
    if i == round(N_weather * 1/10)
        disp('ODE is 10% solved ...')
    end
    
    if i == round(N_weather * 1/5)
        disp('ODE is 20% solved ...')
    end
    
    if i == round(N_weather * 3/10)
        disp('ODE is 30% solved ...')
    end
    
    if i == round(N_weather * 2/5)
        disp('ODE is 40% solved ...')
    end
    
    if i == round(N_weather * 5/10)
        disp('ODE is 50% solved ...')
    end
    
    if i == round(N_weather * 3/5)
        disp('ODE is 60% solved ...')
    end
    
    if i == round(N_weather * 7/10)
        disp('ODE is 70% solved ...')
    end
    
    if i == round(N_weather * 4/5)
        disp('ODE is 80% solved ...')
    end
    
    if i == round(N_weather * 9/10)
        disp('ODE is 90% solved ...')
    end
    
    if i == round(N_weather * 5/5)
        disp('ODE is 100% solved ...')
    end
end 

%% save result
save center_temp.mat

