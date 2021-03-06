clc; 
clear all;
delete set_up_for_airduct.mat
disp('set_up_for_airduct.mat deleted')

%% 불러오기
weather = xlsread('TMY3.xlsx');
disp('TMY3.xlsx loaded')
room_input = xlsread('room_input(2).xlsx');
disp('room_input(2).xlsx loaded')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%  settings  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% defining air duct

num_duct = 5;
length_duct = [40, 12, 14, 16, 18];

%%%
digging_cost = 1;
ductpart_cost = 1;

%% geomatrical properties
duct_rad = 0.5;
duct_volume = duct_rad * duct_rad * 3.141592 * 1;
duct_area = duct_rad * 2 * 3.141592;
duct_depth = 0.05;
room_volume = 3 * 3 * 5;

%% heat properties
duct_density = 1.38 * 1000;%kg/m3 from g/cm3, x1000
duct_specificheat = 0.840/3.6; % Wh/kg degC
duct_k_cond = 0.19;%W/(m K)

air_h_conv = 2.5; %W / m2 K
ACPH = 3;%/h
air_vent_q = ACPH * room_volume; %m3/h
% air_vent_q = 1.699 * 20; %m3/h
% air_vent_q = ACPH * duct_volume; %m3/h
air_density = 1.225;%density in kg/m3
air_specificheat = 1.005/3.6;%Wh/kg degC (Wh to kg, 1 : 3.6)

soil_k_cond = 0.44; % W/m K
soil_solar_absorptance = 0.6;
soil_h_rad = 5.5; % W/m²K
soil_h_conv = 2.5; % W/m²K
soil_density = 1600;%kg/m^3
soil_specific_heat = 0.800/3.6; %Wh/kg*degC

%% heat transfer

duct_conv = air_h_conv * duct_area * [1, -1; -1, 1];
duct_cond_duct = duct_k_cond * duct_area * 1/0.05 * [1, -1; -1, 1];
duct_cond_soil = soil_k_cond * duct_area * 1/1 * [1, -1; -1, 1];
duct_vent = air_vent_q * air_density * air_specificheat * [1, -1; -1, 1]; 
%duct_vent = 22.5 * 0.36 * [1, -1; -1, 1];
% duct_vent = 100 * 3.6 * [1, -1; -1, 1];

S_cond = 1/4 * soil_k_cond * [1, -1; -1, 1];

%Thermal mass =  density * specific heat * volume
m_duct = duct_density * duct_specificheat * duct_volume;
m_air = air_density * air_specificheat * duct_volume;
m_soil = soil_density * soil_specific_heat; 
% S_infiltration = 22.5 * 0.36 * [1, -1; -1, 1];


% U = 1;





%% all_saved_matrix
duct_all = zeros(max(size(weather(:, 1))) * num_duct, 3 + 18 + 2 * length_duct(1, end));
%T_diff_all = zeros(max(size(T_diff(:, 1))), max(size(length_all(1, :))));

save('duct_all.mat', 'duct_all')
disp('T_all_saved')

%% 시뮬레이션 할 기간 정하기

startmonth=1;%월
startday=1;%일

stopmonth=12;%월
stopday=31;%일

%% Boundary Condition 지정

BCN=[15,16,18];
BCT(1,15)=1;%도 (sky)
BCT(1,18)=12;%도 (ground)

%% 3D ground 일 때 boundary conditions

BCN_g = [15, 16];
BCT_g(1, 15) = 1;

%% constant temp of ground through days

const_temt = 12;%degC

%% 깊이에 따른 온도 변화
T_depth = xlsread('Tdepth.xlsx');




%% room info

                           north=5;
             %%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             %%%                                 %%%
west=1;                    ceiling=11;               east=9;
             %%%                                 %%%
             %%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           south=7;

             %%% 창문(없으면 0)
                westwind=3;
                southwind=0;    northwind=0;    eastwind=0; ceilingwind=0;
                
%% 14번 노드 별명 지어주기 (편의)
Node_13 = 13;

%%
disp('loading .xlsx files ...')


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%    done    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 기본 변수 세팅 (custom 값 아님)


%% 불러온 행렬 넘버링
N_node = max(room_input( : , 2 ));
N_weather = max(size(weather(:, 1)));

N_ele = 0; N_ele_all = 0;
for i = 1 : max(size(room_input(:, 1)))
    if room_input(i, 8) ~= 3
        N_ele = N_ele + 1;
        N_ele_all = N_ele_all + 1;
    else
        N_ele_all = N_ele_all + 1;
    end 
end

%% 초기 온도 설정
T0_all = 25;%도
T0 = T0_all * ones(1,N_node);

%% start date, stop date에 해당하는 행 찾기
T_all=zeros(N_weather,3+N_node);

for i=1:N_weather
    T_all(i,1:3)=weather(i,1:3);
end

for i=1:N_weather
    if T_all(i,1)==startmonth
        if T_all(i,2)==startday
            if T_all(i,3)==1
                D1=i;
            end
        end
    end
     if T_all(i,1)==stopmonth
        if T_all(i,2)==stopday
            if T_all(i,3)==24
                D2=i;
            end
        end
     end
end

%%
clearvars i;
clearvars startmonth; clearvars startday;
clearvars stopmonth; clearvars stopday;
save set_up_for_airduct.mat
disp('set_up_for_airduct.mat saved')

