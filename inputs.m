clc; 
clear all;
delete inputs.mat
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 시뮬레이션 할 기간 정하기

startmonth=3;%월
startday=1;%일

stopmonth=3;%월
stopday=30;%일

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
                

%% Boundary Condition 지정

BCN=[15,16,18];
BCT(1,15)=1;%도 (sky)
BCT(1,18)=12;%도 (ground)

%% 3D ground 일 때 boundary conditions
BCN_g = [15, 16];
BCT_g(1, 15) = 1;

%% 플롯 정보 지정
which_node=17;%indoorair
see_interval=4;%온도 확인할 시간간격

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ground node 의 3D Heat transfer에 필요한 변수 설정
%% 온도가 일정해지는 깊이, 그 때의 온도 설정
depth = 12;%m
const_temt = 12;%degC

%% 깊이에 따른 온도 변화
T_depth = xlsread('Tdepth.xlsx');

%% 바닥의 가로 * 세로
row_floor = 5;%m
column_floor = 3;%m

%% 기본 가정 (soil)
soil_conductivity = 0.44;
soil_specific_heat = 733; % J/kg*degC
soil_solar_absorptance = 0.6;
soil_h_rad = 5.5; % W/m²K
soil_h_conv = 15; % W/m²K
U = 1;

%% 14번 노드 별명 지어주기
Node_13 = 13;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 기본 변수 세팅 (custom 값 아님)
%% 불러오기
weather = xlsread('TMY3.xlsx');
room_input = xlsread('room_input(2).xlsx');

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

clearvars i;
clearvars startmonth; clearvars startday;
clearvars stopmonth; clearvars stopday;

save inputs.mat

