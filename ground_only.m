clc; % clear all;

weather = xlsread('TMY3.xlsx');
disp("weather data loaded")

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

%% inputs needed

mesh = 6;
meshsize = 2;

% mesh numbers, consider T_sky + T_out later
N_node_go = mesh * mesh * (mesh + 1);

M = zeros(N_node_go + 2, N_node_go + 2);
S = zeros(N_node_go + 2 + 1, N_node_go + 2 + 1);
f = zeros(N_node_go + 2, 1);

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

    if Node_info(i, 1) ~= 4
        for j = 5 : 10
            x(2, 1) = Node_info(i, j);
            for g = 1 : 2; h = 1 : 2;
                S(x(g,1), x(h,1)) = S(x(g,1), x(h,1)) + S_cond(g,h);
            end
        end
        
    elseif Node_info(i, 1) == 4
        for j = 5 : 9
            x(2, 1) = Node_info(i, j);
            for n1 = 1 : 2; n2 = 1 : 2;
                S(x(n1,1), x(n2,1)) = S(x(n1,1), x(n2,1)) + S_cond(n1, n2);
            end
        end
        
        y(2, 1) = i;
        y(2, 2) = N_node_go + 1;
        for n3 = 1 : 2; n4 = 1 : 2;
            S(x(n3,1), x(n4,1)) = S(x(n3,1), x(n4,1)) + S_conv(n3, n4);
        end
        
        z(2, 1) = i;
        z(2, 2) = N_node_go + 2;
        for n5 = 1 : 2; n6 = 1 : 2;
            S(x(n5,1), x(n6,1)) = S(x(n5,1), x(n6,1)) + S_rad(n5, n6);
        end
    end   
end

clearvars n1;
clearvars n2;
clearvars n3;
clearvars n4;
clearvars n5;
clearvars n6;
clearvars x;
clearvars y;
clearvars z;
clearvars g;
clearvars i;
clearvars j;
clearvars h;


% f
