clc;
clear all;
num_duct_now = 1;
length_done = 0;

while length_done == 0
clc;
load('set_up_for_airduct.mat')
load('duct_all.mat')

length_duct_now = length_duct(1, num_duct_now);
length_duct_end = length_duct(1, end);
disp('loaded set_up_for_airduct.mat')

X = ['now starting ', num2str(num_duct_now), 'th of ',num2str(num_duct), ', and length is ',num2str(length_duct_now), '. ends at', num2str(length_duct_end)];
disp(X)

%% 사용할 행렬들의 기본 세팅
wich_node = 17;
M = zeros(N_node, N_node);
S = zeros(N_node, N_node);
f = zeros(N_node, 1);
BCT = zeros(1, N_node);

%% M, S matrix

x = room_input;

    for i = 1 : N_ele
         N = zeros(2, 1); 
         N(1, 1) = x(i, 2); N(2, 1) = x(i, 3);
         
         A = x(i, 4); U = x(i, 5); L = x(i, 6); CAP = x(i, 7);
         Me = CAP * A * L * 1/2 * [1, 0; 0, 1];
         
         if x(i, 8) == 1
             Se = U * A * [1, -1; -1, 1];
             
         elseif x(i, 8) == 2
%              Se= U * CAP * [1, -1; -1, 1];
         end
     
         for g = 1 : 2; h = 1 : 2;
             M(N(g, 1), N(h, 1))=M(N(g, 1), N(h, 1)) + Me(g, h);
             S(N(g, 1), N(h, 1))=S(N(g, 1), N(h, 1)) + Se(g, h);
         end
    end
    
for i = 1 : max(size(BCN))
    M(BCN(1, i), BCN(1, i)) = 0;
    S(BCN(1, i), :) = 0;
    S(BCN(1, i), BCN(1,i)) = 1;
end

M_indoorair = zeros(N_node, N_node);
M_indoorair(17, 17) = 1.29 * 1000/3600 * 3 * 3 * 5;
M = M + M_indoorair;
f(15, 1) = 1;
f(18, 1) = 12;

%% Solar radiation(A * SHGC)
    ASHGC=zeros(10,1);
    for j=1 : N_ele_all
        %%% south
        if room_input(j,2:3)==[south,0]
                ASHGC(1,1)=room_input(j,4)*room_input(j,5);
        end
         %%% east
         if room_input(j,2:3)==[east,0]
                ASHGC(2,1)=room_input(j,4)*room_input(j,5);
        end
        %%% north
         if room_input(j,2:3)==[north,0]
                ASHGC(3,1)=room_input(j,4)*room_input(j,5);
        end
        %%% west
        if room_input(j,2:3)==[west,0]
                ASHGC(4,1)=room_input(j,4)*room_input(j,5);
        end
        %%% ceiling
        if room_input(j,2:3)==[ceiling,0]
                ASHGC(5,1)=room_input(j,4)*room_input(j,5);
        end
         %%%window
         %%% southwind
        if room_input(j,2:3)==[southwind,0]
                ASHGC(6,1)=room_input(j,4)*room_input(j,5);
        end
         %%% eastwind
         if room_input(j,2:3)==[eastwind,0]
                ASHGC(7,1)=room_input(j,4)*room_input(j,5);
        end
        %%% northwind
        if room_input(j,2:3)==[northwind,0]
                ASHGC(8,1)=room_input(j,4)*room_input(j,5);
        end
        %%% westwind
        if room_input(j,2:3)==[westwind,0]
                ASHGC(9,1)=room_input(j,4)*room_input(j,5);
        end
        %%% ceilingwind
        if room_input(j,2:3)==[ceilingwind,0]
                ASHGC(10,1)=room_input(j,4)*room_input(j,5);
        end
    end
    
disp('M, S, f matrix is done ...')

%%
N_node_all = N_node + length_duct_now * 3;

M_ult = zeros(N_node_all, N_node_all);
S_ult = zeros(N_node_all, N_node_all);
f_ult = zeros(N_node_all, 1);

M_unit = zeros(3, 3);
S_unit = zeros(3, 3);
f_unit = zeros(3, 1);

%%
M_unit(1, 1) = m_air;
M_unit(2, 2) = 40/41 * m_duct;
M_unit(3, 3) = 1/41 * m_duct + 40/41 * m_soil;

%%

for j = 1 : 2, k = 1 : 2;
    s_e = duct_conv;
    S_unit(j, k) = S_unit(j, k) + s_e(j, k);
end

x = zeros(2, 1);
x(1, 1) = 2;
x(2, 1) = 3;
for j = 1 : 2, k = 1 : 2;
    s_e = duct_cond_duct;
    S_unit(x(j, 1), x(k, 1)) = S_unit(x(j, 1), x(k, 1)) + s_e(j, k);
end

%%
%f unit is zeros;

%% sum ult

M_ult(1 : N_node, 1 : N_node) = M;
S_ult(1 : N_node, 1 : N_node) = S;
f_ult(1 : N_node, 1) = f;

for i = 1 : length_duct_now
    temp1 = N_node + 3 * (i - 1) + 1;
    temp2 = N_node + 3 * i ;
    
    M_ult(temp1 : temp2, temp1 : temp2) = M_unit;
    S_ult(temp1 : temp2, temp1 : temp2) = S_unit;
    f_ult(temp1 : temp2, 1) = f_unit;
end


%% %
startnums = zeros(length_duct_now, 1);
for i = 1 : length_duct_now
    startnums(i, 1) = N_node + 3 * (i - 1) + 1;
end

%% ventilation to S_ult

ventnums = zeros(length_duct_now + 2, 1);
ventnums(2 : length_duct_now + 1) = startnums;
ventnums(1, 1) = 16;
ventnums(end, 1) = 17;

x = zeros(2, 1);
for i = 1 : max(size(ventnums)) - 1
    x(1, 1) = ventnums(i, 1);
    x(2, 1) = ventnums(i + 1, 1);
    s_e = duct_vent;
    for j = 1 : 2, k = 1 : 2;
        S_ult(x(j, 1), x(k, 1)) = S_ult(x(j, 1), x(k, 1)) + s_e(j, k);
    end
end

%% conduction to S_ult(duct and ground)
condnums = startnums + 2 * ones(length_duct_now, 1);
x = zeros(2, 1);
for i = 1 : length_duct_now
    x(1, 1) = 18;
    x(2, 1) = condnums(i, 1);
    s_e = duct_cond_soil;
    for j = 1 : 2, k = 1 : 2;
        S_ult(x(j, 1), x(k, 1)) = S_ult(x(j, 1), x(k, 1)) + s_e(j, k);
    end
end

%% Clear boundary conditions
S_ult(15, :) = 0;
S_ult(15, 15) = 1;
S_ult(16, :) = 0;
S_ult(16, 16) = 1;
S_ult(18, :) = 0;
S_ult(18, 18) = 1;

M_ult(15, :) = 0;
M_ult(16, :) = 0;
M_ult(18, :) = 0;

%% initial T
T00 = 25 * ones(1, N_node_all);
T00(1, 15) = 1;
T00(1, 18) = 12;
T_all = zeros(max(size(weather(:, 1))), 3 + N_node_all);
T_all(:, 1 : 3) = weather(:, 1 : 3);

%% main ODE
tspan=[0:1];
for i=1:N_weather
    f_ult(16,1)=weather(i,4);
    
    %%% update solarradiation
    f_ult(south,1)=ASHGC(1,1)*weather(i,5);
    f_ult(east,1)=ASHGC(2,1)*weather(i,6);
    f_ult(north,1)=ASHGC(3,1)*weather(i,7);
    f_ult(west,1)=ASHGC(4,1)*weather(i,8);
    f_ult(ceiling,1)=ASHGC(5,1)*weather(i,9);
    if southwind ~= 0
        f_ult(southwind,1)=ASHGC(6,1)*weather(i,5);
    end
    if eastwind ~= 0
        f_ult(eastwind,1)=ASHGC(7,1)*weather(i,6);
    end
    if northwind ~= 0
        f_ult(northwind,1)=ASHGC(8,1)*weather(i,7);
    end
    if westwind ~= 0
        f_ult(westwind,1)=ASHGC(9,1)*weather(i,8);
    end
    if ceilingwind ~= 0
      f_ult(ceilingwind,1)=ASHGC(10,1)*weather(i,9);
    end
    
    [t,T]=unsteady(tspan,T00,M_ult,S_ult,f_ult);
    
    T00=T(end,:);
    T_all(i,4:3+N_node_all)=T00;
    
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

%%
%% end of the while loop
%%%%%
%%%%
load('duct_all.mat')
duct_all_num1 = N_weather * (num_duct_now - 1) + 1;
duct_all_num2 = N_weather * num_duct_now;
duct_all(duct_all_num1 : duct_all_num2, 1 : 3 + N_node_all) = T_all(:, 1 : end);

save('duct_all.mat', 'duct_all')
disp('result saved')


num_duct_now = num_duct_now + 1;
if num_duct_now > 1%num_duct
    length_done = 1;
end

end
