clc;
clear all;

%% 기본 input, 3D ground
load('inputs.mat')
load("ground_3D.mat")

%% 사용할 행렬들의 기본 세팅
M=zeros(N_node,N_node);
S=zeros(N_node,N_node);
f=zeros(N_node,1);
BCT=zeros(1,N_node);

%% M, S matrix

x=room_input;

    for i=1:N_ele
         N=zeros(2,1); 
         N(1,1)=x(i,2); N(2,1)=x(i,3);
         
         A=x(i,4); U=x(i,5); L=x(i,6); CAP=x(i,7);
         Me=CAP*A*L*1/2*[1,0;0,1];
         
         if x(i,8)==1
             Se=U*A*[1,-1;-1,1];
             
         elseif x(i,8)==2
             Se=U*CAP*[1,-1;-1,1];
         end
     
         for g=1:2; h=1:2;
             M(N(g,1),N(h,1))=M(N(g,1),N(h,1))+Me(g,h);
             S(N(g,1),N(h,1))=S(N(g,1),N(h,1))+Se(g,h);
         end
    end
    
for i=1:max(size(BCN))
    M(BCN(1,i),BCN(1,i))=0;
    S(BCN(1,i),:)=0;
    S(BCN(1,i),BCN(1,i))=1;
end

M_indoorair=zeros(N_node,N_node);
M_indoorair(17,17)=1.29*1000/3600*3*3*5;
M=M+M_indoorair;
f=f+BCT';

for i=1:N_node
    if BCT(1,i)==0
        BCT(1,i)=T0_all;
    end
end

T0=BCT;

clearvars x;

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

%% warmup
T_preheating1=zeros(24*30,N_node);
T_preheating2=zeros(24*30,N_node);

tspan=[0:1];

T01=T0;
T02=T0;

if D1-30*24<0
    D01=N_weather+D1-30*24+1;
    for i=1:30*24-D1
        f(16,1)=weather(D01+i-1,4);
        [t,T]=unsteady(tspan,T01,M,S,f);
        T01=T(end,:);
        T_preheating1(i,:)=T01;
    end
    T02=T_preheating1(30*24-D1,:);
    for i=1:D1
        f(16,1)=weather(i,4);
        [t,T]=unsteady(tspan,T02,M,S,f);
        T02=T(end,:);
        T_preheating2(i,:)=T02;
    end
end
if D1-30*24>0
    for i=1:30*24
        f(16,1)=weather(D1-30*24+1,4);
        [t,T]=unsteady(tspan,T01,M,S,f);
        T01=T(end,:);
        T_preheating2(i,:)=T01;
    end
end
T00 = T_preheating2(end,:);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% M_g, S_g, f_g 행렬과 M, S, f 행렬 합쳐서 M_ult, S_ult, f_ult 만들기

clearvars x;
x = N_node_g2 + N_node;

M_ult = zeros(x, x);
S_ult = zeros(x, x);
f_ult = zeros(x, 1);

M_ult(1:N_node_g, 1:N_node_g) = M_g;
S_ult(1:N_node_g, 1:N_node_g) = S_g;
f_ult(1:N_node_g, 1) = f_g;

M_ult(N_node_g + n_type_4 + 1 : x, N_node_g + n_type_4 + 1 : x) = M;
S_ult(N_node_g + n_type_4 + 1 : x, N_node_g + n_type_4 + 1 : x) = S;
f_ult(N_node_g + n_type_4 + 1 : x, 1) = f;

%% M_ult 에 추가하기

%%% 새로 생긴 surface node 들에게 1/2 soil mass 만큼 추가해줌
for i = N_node_g + 1 : N_node_g + n_type_4
    M_ult(i, i) = 1/2 * soil_specific_heat * 1 * 1;
end
% 13번 노드 아래에 soil mass 1/2 추가해줌
M_ult(N_node_g2 + 13, N_node_g2 + 13) = M_ult(N_node_g2 + 13, N_node_g2 + 13) + 1/2 * soil_specific_heat * 1; 



%% S_ult 에 추가하기
clearvars x;
clearvars i;
clearvars j;
clearvars Se_g;

N_adj_now = zeros(2, 1);
x = N_adj_now;
    
%%% 76+16번 노드(T_out)와 대류 추가
for i = N_node_g + 1 : N_node_g + n_type_4
    x(1, 1) = i;
    x(2, 1) = N_node_g2 + 16;
    Se_g = soil_h_conv * 1 * [1, -1; -1, 1];
    
    for g=1:2; h=1:2;
        S_ult(x(g,1),x(h,1)) = S_ult(x(g,1),x(h,1)) + Se_g(g,h);
    end
end

%%% 76+15번 노드(T_sky)와 복사 추가

for i = N_node_g + 1 : N_node_g + n_type_4
    x(1, 1) = i;
    x(2, 1) = N_node_g2 + 15;
    Se_g = soil_h_rad * 1 * [1, -1; -1, 1];
    
    for g=1:2; h=1:2;
        S_ult(x(g,1),x(h,1)) = S_ult(x(g,1),x(h,1)) + Se_g(g,h);
    end
end

%%% 76번 바로 아래 노드(n_type_4 차례로)와 전도 추가
for i = N_node_g + 1 : N_node_g + n_type_4
    for j = 1 : N_node_g
        if info_g(j, 11) == i
            x(1, 1) = i;
            x(2, 1) = j;
            Se_g = 1/6 * soil_conductivity * 1 /1 * [1, -1; -1, 1];
            for g=1:2; h=1:2;
                S_ult(x(g,1),x(h,1)) = S_ult(x(g,1),x(h,1)) + Se_g(g,h);
            end
        end
    end
end

%%% 건물 바로 밑 노드들과 76+13번 노드와 전도 추가
for i = 1 : N_node_g
    if info_g(i, 1) == 2
        x(1, 1) = i;
        x(2, 1) = N_node_g2 + 13;
        Se_g = 1/6 * soil_conductivity * 1 /1 * [1, -1; -1, 1];
        for g=1:2; h=1:2;
            S_ult(x(g,1),x(h,1)) = S_ult(x(g,1),x(h,1)) + Se_g(g,h);
        end
    end
end

%% f_ult 에 추가하기

%%% ODE 풀면서 업데이트 시켜줘야함

%% ODE



%% main ODE

clearvars x;
x = N_node_g2;
tspan = [0 : 1];

T002(1, N_node_g2 + 1 : N_node_g2 + N_node) = T00;
T_all = zeros(N_weather, N_node_g2 + N_node + 3);
T_all(:, 1:3) = weather(:, 1:3);

for i  = 1 : N_weather
    %%% f update
    f(x + 16) = weather(i, 4);
    f(x + south, 1) = ASHGC(1,1) * weather(i, 5);
    f(x + east, 1) = ASHGC(2, 1) * weather(i, 6);
    f(x + north, 1) = ASHGC(3, 1) * weather(i, 7);
    f(x + west, 1) = ASHGC(4, 1) * weather(i, 8);
    f(x + ceiling, 1) = ASHGC(5, 1) * weather(i, 9);
    if southwind ~= 0
    f(x + southwind, 1) = ASHGC(6, 1) * weather(i, 5);
    end
    if eastwind ~= 0
    f(x + eastwind, 1) = ASHGC(7, 1) * weather(i, 6);
    end
    if northwind ~= 0
    f(x + northwind, 1) = ASHGC(8, 1) * weather(i, 7);
    end
    if westwind ~= 0
    f(x + westwind, 1) = ASHGC(9, 1) * weather(i, 8);
    end
    if ceilingwind ~= 0
    f(x + ceilingwind, 1) = ASHGC(10, 1) * weather(i, 9);
    end
    
    for j = N_node_g + 1 : N_node_g + n_type_4
        f(j, 1) = f(j, 1) + soil_solar_absorptance * 1 * weather(i, 9);
    end
    
    [t,T]=unsteady(tspan, T002, M_ult, S_ult, f_ult);
    T002 = T(end, :);
    T_all(i, 4:N_node_g2 + N_node + 3) = T002;
end

plot(T_all(3 + x + 17, :))
%% 날짜 표기 및 플롯
% 
% ii = 3 + which_node;
% 
% % display startdate & enddate
% startdate = T_all(D1, 1:2)
% enddate = T_all(D2, 1:2)
% 
% % expressing date by decimal numbers
% DD1 = T_all(D1, 1) + T_all(D1, 2) * 1/100; 
% DD2 = T_all(D2, 1) + T_all(D2, 2) * 1/100;
% 
% % plotting
% n = D2 - D1 + 1; y = linspace(DD1, DD2, n);
% plot(y,T_all(D1:D2, [x + 16+3, x + 1+3,x +  2+3,x +  17+3]));
% xtickformat('%.2f');
% legend('Tout', 'Wall 1', 'Wall 2', 'Tin');
% Maxx=max(T_all(D1:D2,[x + 16+3, x + 1+3, x + 2+3, x + 17+3]));
% minn=min(T_all(D1:D2,[x + 16+3, x + 1+3, x + 2+3, x + 17+3]));
% axis([DD1 DD2 min(minn) max(Maxx)]);
% 
% % title('temp diff through days');
% xlabel('date'); ylabel('degC');
% grid on

