%% 주의사항
% M 매트릭스 만들고 boundary conditions 해당하는 행 지워야 하는지?
% 파일 보낼 때 inputs.mat 파일과 ground_3D.mat 파일 같이 보내기. 안그러면 지울 수 없다고 뜸.
% S 매트릭스 만들 때, 발밑 노드와 cond 계수 얼마로 해야 할지

%%
clc;
clear all;
load('inputs.mat')

for i = 1 : max(size(weather(:, 1))); j = 1 : max(size(weather(1, :)));
    weather(i, j) = round(weather(i, j), 4);
end

for i = 1 : max(size(room_input(:, 1))); j = 1 : max(size(room_input(1, :)));
    room_input(i, j) = round(room_input(i, j), 4);
end

%% 사용할 행렬들의 기본 세팅
M=zeros(N_node,N_node);
S=zeros(N_node,N_node);
f=zeros(N_node,1);

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

T0 = BCT;

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

T00 = T_preheating2(end, :);

%% ground 3D module

%% 공간좌표의 격자 갯수
N_node_g = 10 * 10 * fix(depth); %공간좌표 격자 갯수

%% boundary condition 설정
BCN_g = zeros(N_node_g, 1);

for i = 1 : N_node_g
    if rem(i-1, 10) == 0 %x값 0
        BCN_g(i,1) = 1;
    end
    if rem(i-1, 10) == 9 %x값 9
        BCN_g(i,1) = 1;
    end
    
    if fix(rem((i-1) - rem((i-1), 10), 100)/10) == 0 %y값 0
         BCN_g(i,1) = 1;
    end
    if fix(rem((i-1) - rem((i-1), 10), 100)/10) == 9 %y값 9
         BCN_g(i,1) = 1;
         
    end
    if fix((i-1)/100) == 0 %z값 0
         BCN_g(i,1) = 3;
    end
    if fix((i-1)/100) == fix(depth)-1 %z값 마지막
         BCN_g(i,1) = 4;
    end
end

r = ((row_floor) - 1)/2;
c = ((column_floor) -1)/2;
for i = 1 : row_floor; j = 1 : column_floor;
    BCN_g(((5-(r+1)) + i)*1 + ((5-(c+1)) + j)*10 + 11*100, 1) = 2;
end

%% 노드 타입 갯수 세주기

n_type_0 = 0; % 일반 큐브
n_type_1 = 0; % 기타 바운더리 컨디션
n_type_2 = 0; % 건물 밑 노드
n_type_3 = 0; % 바닥 노드
n_type_4 = 0; % surface 와 접한 노드

for i = 1 : N_node_g
     if BCN_g(i, 1) == 0
        n_type_0 = n_type_0 + 1;
    end
    if BCN_g(i, 1) == 1
        n_type_1 = n_type_1 + 1;
    end
    if BCN_g(i, 1) == 2
        n_type_2 = n_type_2 + 1;
    end
    if BCN_g(i, 1) == 3
        n_type_3 = n_type_3 + 1;
    end
    if BCN_g(i, 1) == 4
        n_type_4 = n_type_4 + 1;
    end
end

%% surface node, T_sky, T_out 노드 추가
% T_sky = 1201, T_out = 1202
% 1203부터 surface node 85개 추가
N_node_g2 = N_node_g + 2 + n_type_4;

% 1203 - 1287 surface node랑 n_type_4랑 연결해주기
surface_node = zeros(n_type_4, 2);
a = 1;
for i = 1 : N_node_g
    if BCN_g(i, 1) == 4
            surface_node(a, 1) = a + N_node_g + 2;
            surface_node(a, 2) = i;
            a = a + 1;
    end
end
clearvars a;

%% 노드 넘버를 (x,y,z) 좌표로 바꾸기
coordinates = zeros(N_node_g2, 4);

for i = 1 : N_node_g
    coordinates(i, 1) = i ;
    coordinates(i, 2) = rem(i-1, 10);
    coordinates(i, 3) = fix(rem((i-1) - rem((i-1), 10), 100)/10);
    coordinates(i, 4) = fix((i-1)/100);
end

%% 행렬 설정
M_g = zeros(N_node_g2, N_node_g2);
S_g = zeros(N_node_g2, N_node_g2);
f_g = zeros(N_node_g2, 1);

%% M 설정

m = soil_specific_heat * 1 * 1; % * [1, 0; 0, 1];
for i = 1 : N_node_g
            M_g(i, i) = m;
end

for i = 1 : n_type_4
            M_g(surface_node(i, 1), surface_node(i, 1)) = 1/2 * m;       
end

%% 인접노드 정의
N_adjacent = zeros(N_node_g2, 7);

for i = 1 : N_node_g2
    N_adjacent(i, 1) = i;
end

for i = 1 : N_node_g
    N_adjacent(i, 2) = (i-1) - 100 +1;  % z방향 이전
    N_adjacent(i, 3) = (i-1) + 100 +1;  % z방향 이후
    N_adjacent(i, 4) = (i-1) - 10 +1;   % y방향 이전
    N_adjacent(i, 5) = (i-1) + 10 +1;   % y방향 이후
    N_adjacent(i, 6) = (i-1) - 1 +1;    % x방향 이전
    N_adjacent(i, 7) = (i-1) + 1 +1;    % x방향 이후
    
    % x좌표 확인
    if coordinates(i, 2) == 0
        N_adjacent(i, 6) = 0;
    end
    if coordinates(i, 2) == 9
        N_adjacent(i, 7) = 0;
    end
    
    % y좌표 확인
    if coordinates(i, 3) == 0
        N_adjacent(i, 4) = 0;
    end
    if coordinates(i, 3) == 9
        N_adjacent(i, 5) = 0;
    end
    
    % z좌표 확인
    if coordinates(i, 4) == 0
        N_adjacent(i, 2) = 0;
    end
    if coordinates(i, 4) == 9
        N_adjacent(i, 3) = 0;
    end
end

clearvars i;
x = surface_node;
for j = 1 : n_type_4
    i = x(j, 2);
    N_adjacent(i, 2) = (i-1) - 100 +1;  % z방향 이전
    N_adjacent(i, 3) = x(j, 1);         % z방향 이후 (위에 추가)
    N_adjacent(i, 4) = (i-1) - 10 +1;   % y방향 이전
    N_adjacent(i, 5) = (i-1) + 10 +1;   % y방향 이후
    N_adjacent(i, 6) = (i-1) - 1 +1;    % x방향 이전
    N_adjacent(i, 7) = (i-1) + 1 +1;    % x방향 이후
end
clearvars i;

for j = 1 : n_type_2
    i = x(j, 2);
    N_adjacent(i, 2) = (i-1) - 100 +1;  % z방향 이전
    N_adjacent(i, 3) = Node_13 + N_node_g2; % z방향 이후 (위에 추가)
    N_adjacent(i, 4) = (i-1) - 10 +1;   % y방향 이전
    N_adjacent(i, 5) = (i-1) + 10 +1;   % y방향 이후
    N_adjacent(i, 6) = (i-1) - 1 +1;    % x방향 이전
    N_adjacent(i, 7) = (i-1) + 1 +1;    % x방향 이후
end

clearvars x;
clearvars i;


%% S matrix
N_adj_now = zeros(2, 1);
S_g2 = zeros(N_node_g2 + 1, N_node_g2 + 1);
N_adjacent2 = N_adjacent;
BCN_g2 = zeros(N_node_g2, 1);
BCN_g2(1:N_node_g, 1) = BCN_g(1:N_node_g, 1);

%%% N_adjacent 의 0을 전부 1288으로 바꾼 N_adjacent2 정의
%%% 자동으로 S-matrix 만들 때, 인접 노드가 없는 경우 열 교환 1288 노드랑 함
%%% 1288 노드는 휴지통 노드로 작용

for i = 1 : N_node_g2
    for j = 2 : 7
        if N_adjacent2(i, j) == 0
            N_adjacent2(i, j) = N_node_g2 + 1;
        end
    end
end

%%% 자동으로 S 매트릭스 만들어주기

%%% 지표면, 건물밑 노드 제외하고 전부 전도 열교환으로 통일

x = N_adj_now;
for i = 1 : N_node_g2
    if BCN_g2(i, 1) ~= 4
        if BCN_g2(i, 1) ~= 2
            for j = 2 : 7
                x(1, 1) = i;
                x(2, 1) = N_adjacent2(i, j);
                for g=1:2; h=1:2;
                    Se_g = 1/6 * soil_conductivity * 1 /1 * [1, -1; -1, 1];
                    S_g2(x(g,1),x(h,1)) = S_g2(x(g,1),x(h,1)) + Se_g(g,h);
                end
            end
        end
    end
end

%%% node 1 -> node 2에서도, node 2 -> node 1에서도 한 번씩 더해져서 겹친 상태
S_g2 = 1/2 * S_g2;

%%% 지표면 노드는 지표, 발밑과 1대1 열교환. type 4에 대해서.
for i = 1 : n_type_4
        x(1, 1) = surface_node(i, 1);
        
        %%% T_sky (longwave)
        x(1, 2) = 1201;
               Se_g = soil_h_rad * 1 * [1, -1; -1, 1];
           for g=1:2; h=1:2;
               S_g2(x(g,1),x(h,1)) = S_g2(x(g,1),x(h,1)) + Se_g(g,h);
           end
                
        %%% T_out (conv)
        x(1, 2) = 1202;
               Se_g = soil_h_conv * 1 * [1, -1; -1, 1];
           for g=1:2; h=1:2;
               S_g2(x(g,1),x(h,1)) = S_g2(x(g,1),x(h,1)) + Se_g(g,h);
           end
           
        %%% T_발밑 (cond)
        x(1, 2) = surface_node(i, 2);
        Se_g = soil_conductivity * 1 /0.5 * [1, -1; -1, 1];
        for g=1:2; h=1:2;            
            S_g2(x(g,1),x(h,1)) = S_g2(x(g,1),x(h,1)) + Se_g(g,h);
        end
end

clearvars x;


S_g = S_g2(1:N_node_g2, 1:N_node_g2);

clearvars S_g2;

%% S 행렬 중 바운더리 컨디션 밀어버리기

for i = 1 : N_node_g2
    if BCN_g2(i, 1) == 1
        S_g(i, :) = 0;
        S_g(i, i) = 1;
    end
    
    if BCN_g2(i, 1) == 3
        S_g(i, :) = 0;
        S_g(i, i) = 1;
    end
    
    S_g(1201, :) = 0;
    S_g(1201, 1201) = 1;
    
    S_g(1202, :) = 0;
    S_g(1202, 1201) = 1;
end    


%% f-matrix

f_g(N_node_g + 1, 1) = BCT(1,15); %T_sky : 1도 

for i = 1 : N_node_g2
    if BCN_g2(i, 1) == 3
         f_g(i, 1) = BCT(1,18); %T_out : 12도 
    end
    
    if BCN_g2(i, 1) == 1
         f_g(i, 1) = T_depth(12 - coordinates(i, 3), 2);
    end
end

% surface_node 에 해당하는 1203 부터 1287까지의 노드들은 바운더리 컨디션이 아님
% 대신 그 노드들은 태양열 추가 해줘야함.
for i = surface_node(1, 1) : surface_node(end, 1)
    f_g(i, 1) = soil_solar_absorptance * 1 * weather(9,9); % 1을 i로 바꿔서 업데이트
end

%% 기존의 M, S, f 매트릭스와 합치기
clearvars i;
i = N_node_g2 + N_node;

M_alt = zeros(i, i);
S_alt = zeros(i, i);
f_alt = zeros(i, 1);

M_alt(1 : N_node_g2, 1 : N_node_g2) = M_g;
M_alt(N_node_g2 + 1 : i, N_node_g2 + 1 : i) = M;

S_alt(1 : N_node_g2, 1 : N_node_g2) = S_g;
S_alt(N_node_g2 + 1 : i, N_node_g2 + 1 : i) = S;

f_alt(1 : N_node_g2, 1) = f_g;
f_alt(N_node_g2 + 1 : i, 1) = f;

%% 18번 노드(지하)와 13번 노드 관계 제외
x=room_input;

 for i=1:N_ele
     if x(i, 2) == 18
         N=zeros(2,1); 
         N(1,1)=x(i,2); N(2,1)=x(i,3);
         
         A=x(i,4); U=x(i,5); L=x(i,6); CAP=x(i,7);
         Me=CAP*A*L*1/2*[1,0;0,1];
         Se=U*A*[1,-1;-1,1]; 
         
            for g=1:2; h=1:2;
                M(N(g,1), N(h,1)) = M(N(g,1), N(h,1)) - Me(g,h);
                S(N(g,1), N(h,1)) = S(N(g,1), N(h,1)) - Se(g,h);
            end
     end
     
     if x(i, 3) == 18
         N(1,1)=x(i,2); N(2,1)=x(i,3);
            for g=1:2; h=1:2;
                M(N(g,1), N(h,1)) = M(N(g,1), N(h,1)) - Me(g,h);
                S(N(g,1), N(h,1)) = S(N(g,1), N(h,1)) - Se(g,h);
            end
     end
 end

%% 건물 밑 노드 (13번)와 지하 노드 15개 연결해주기.

%%%% M 매트릭스부터 봉합
%%% M_alt 에서 14번 노드(1287 + 13)에 해당하는 cap 값 찾음
%%% 그 값이 1/2 * 바닥 thermal mass 값이니까, 그거에다가 1/2 * soil_specific_heat * 1 * 1

New_13 = N_node_g2 + 13;
New_14 = N_node_g2 + 14;

M_alt(New_13, New_13) = 1/2 * M_alt(New_14, New_14) + 1/2 * soil_specific_heat * 1 * 1;

%%%% S 매트릭스 봉합

x = N_adj_now;
Se_g = soil_conductivity * 1 /0.5 * [1, -1; -1, 1];

for i = 1 : N_node_g2
    if BCN_g2(i, 1) == 2
        x(1, 1) = i;
        x(2, 1) = N_adjacent2(i, j);
        
        for g=1:2; h=1:2;            
            S_alt(x(g,1), x(h,1)) = S_alt(x(g,1), x(h,1)) + Se_g(g, h);
        end
        
    end
end
clearvars x;

%% 건물 밑 노드들과 13번 노드 봉합 (S 매트릭스)
x = N_adj_now;
for i = 1 : N_node_g2
    if BCN_g2(i, 1) == 2 
         for j = 2 : 7
             x(1, 1) = i;
             x(2, 1) = N_adjacent2(i, j);
             for g=1:2; h=1:2;
                 Se_g = 1/6 * soil_conductivity * 1 /1 * [1, -1; -1, 1];
                 S_alt(x(g,1),x(h,1)) = S_alt(x(g,1),x(h,1)) + Se_g(g,h);
             end
         end
    end
end
%% M, S 행렬 중 바운더리 컨디션 밀어버리기

for i = 1 : N_node_g2
    if BCN_g2(i, 1) == 1
        S_alt(i, :) = 0;
        S_alt(i, i) = 1;
        M_alt(i, i) = 0;
    end
    
    if BCN_g2(i, 1) == 3
        S_alt(i, :) = 0;
        S_alt(i, i) = 1;
        M_alt(i, i) = 0;
    end
end    
 
S_alt(1201, :) = 0;
S_alt(1201, 1201) = 1;
M_alt(1201, 1201) = 0;
    
S_alt(1202, :) = 0;
S_alt(1202, 1201) = 1;
M_alt(1201, 1201) = 0;

%% 18번 노드 없애기

clearvars i;
i = N_node_g2 + N_node;
j = i;

M = zeros(i - 1, i - 1);
S = zeros(i - 1, i - 1);
f = zeros(i - 1, 1);

M = M_alt(1 : i-1, 1 : i-1);
S = S_alt(1 : i-1, 1 : i-1);
f = f_alt(1 : i-1, 1);

%% 단위 맞춰보기

for i = 1 : j-1, k = 1 : j-1;
    M(i, k) = round(M(i, k), 4);
    S(i, k) = round(S(i, k), 4);
    f(i, 1) = round(f(i, 1), 4);
end

%% main ODE
clearvars x;
x = N_node_g2;

%%% update T00
T002 = zeros(1, j - 1);
T002(1, N_node_g2 + 1 : j - 1) = T00(1, 1 : 17);

tspan=[0:1];
for i=1 :N_weather
    %%% update outdoor
    f(16 + x,1) = weather(i,4);
    f(1202,1) = weather(i,4);
    
    %%% update solarradiation
    f(south + x, 1) = ASHGC(1, 1) * weather(i, 5);
    f(east + x, 1) = ASHGC(2, 1) * weather(i, 6);
    f(north + x, 1) = ASHGC(3, 1) * weather(i, 7);
    f(west + x, 1) = ASHGC(4, 1) * weather(i, 8);
    f(ceiling + x,1) = ASHGC(5, 1) * weather(i, 9);
    
    if southwind ~= 0
        f(southwind + x, 1) = ASHGC(6, 1) * weather(i, 5);
    end
    if eastwind ~= 0
        f(eastwind + x, 1) = ASHGC(7, 1) * weather(i, 6);
    end
    if northwind ~= 0
        f(northwind + x, 1) = ASHGC(8, 1) * weather(i, 7);
    end
    if westwind ~= 0
        f(westwind + x, 1) = ASHGC(9, 1) * weather(i, 8);
    end
    if ceilingwind ~= 0
        f(ceilingwind + x, 1) = ASHGC(10, 1) * weather(i, 9);
    end
    
    [t,T] = unsteady(tspan, T002, M, S, f);
    
%     T002 = T(end, :);
%     T_all(i, 4 : 3 + max(size(T002(1 , :)))) = T002;
end

%% 날짜 표기 및 플롯

ii=3+which_node;

% display startdate & enddate
startdate = T_all(D1,1:2)
enddate = T_all(D2,1:2)

% expressing date by decimal numbers
DD1 = T_all(D1, 1) + T_all(D1, 2) * 1/100; 
DD2 = T_all(D2, 1) + T_all(D2, 2) * 1/100;

% plotting
n = D2 - D1 + 1; y = linspace(DD1, DD2, n);
plot(y,T_all(D1:D2, [16+3, 1+3, 2+3, 17+3]));
xtickformat('%.2f');
legend('Tout', 'Wall 1', 'Wall 2', 'Tin');
Maxx=max(T_all(D1:D2,[16+3, 1+3, 2+3, 17+3]));
minn=min(T_all(D1:D2,[16+3, 1+3, 2+3, 17+3]));
axis([DD1 DD2 min(minn) max(Maxx)]);

% title('temp diff through days');
xlabel('date'); ylabel('degC');
grid on
disp(M(17,17)*1.27)
