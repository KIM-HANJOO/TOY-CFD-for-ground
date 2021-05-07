clc; 
clear all;
delete ground_3D.mat
load("inputs.mat")

%% 주의사항
% M 매트릭스 만들고 boundary conditions 해당하는 행 지워야 하는지?
% 파일 보낼 때 inputs.mat 파일과 ground_3D.mat 파일 같이 보내기. 안그러면 지울 수 없다고 뜸.
% S 매트릭스 만들 때, 발밑 노드와 cond 계수 얼마로 해야 할지

%% 미리 18번 노드 없애놓기

for i = 1 : N_ele_all
    if room_input(i, 2) == 18
        a = i;
    end
end

for i = 1 : N_ele_all
    if room_input(i, 3) == 18
        a = i;
    end
end

room_input(a, :) = [];
clearvars a;

%% 카운팅 다시

N_node = max(max(room_input( : , 2 )), max(room_input( : , 3 )));
N_ele = 0; N_ele_all = 0;
for i = 1 : max(size(room_input(:, 1)))
    if room_input(i, 8) ~= 3
        N_ele = N_ele + 1;
        N_ele_all = N_ele_all + 1;
    else
        N_ele_all = N_ele_all + 1;
    end 
end

%% BCN, BCT 새로 정의
clearvars BCN;
clearvars BCT;

BCT = zeros(N_node, 1);
BCN = BCN_g;
BCT(1 : max(size(BCT_g(1,:))), 1) = BCT_g';

clearvars BCN_g;
clearvars BCT_g;

%% T0 만들기
clearvars T0;
T0 = zeros(N_node, 1);

for i = 1 : N_node
    if BCT(i, 1) == 0
        BCT(i, 1) = T0_all;
    end
end

%% 새로운 3D 노드들 추가 (귀여운 64개로) %%%%%%%%%%%%%%%% 바꾸기
N_node_g = 4*4*4; %공간좌표 격자 갯수

%% 노드 번호를 x,y,z 좌표로  %%%%%%%%%%%%%%%% 다시 바꿔주기

info_g = zeros(N_node_g, 11); 

xyz = [0, 1, 2, 3];

for i = 1 : N_node_g
    for x = 1 : 4
        for y = 1 : 4
            for z = 1 : 4
                if xyz(1, x) + 4 * xyz(1, y) + 16 * xyz(1, z) == i-1
                    info_g(i, 2) = x - 1;
                    info_g(i, 3) = y - 1;
                    info_g(i, 4) = z - 1;
                end
            end
        end
    end
end
clearvars xyz;
clearvars x;
clearvars y;
clearvars z;

%% 바운더리 컨디션 지정 %%%%%%%%%%%%%%%% 3을 9로 바꿔주기

for i = 1 : N_node_g
    if info_g(i, 2) == 0 % x값 0
        info_g(i, 1) = 1;
    end
    
    if info_g(i, 2) == 3 % x값 3
        info_g(i, 1) = 1;
    end
    
    if info_g(i, 3) == 0 % y값 0
        info_g(i, 1) = 1;
    end
    
    if info_g(i, 3) == 3 % y값 3
        info_g(i, 1) = 1;
    end
    
    if info_g(i, 4) == 0 % z값 0
        info_g(i, 1) = 3;
    end
    
    if info_g(i, 4) == 3 % z값 3
        info_g(i, 1) = 4;
    end
    
end

clearvars x;
clearvars y;
clearvars z;

for i = 1 : N_node_g
    if info_g(i, 2 : 4) == [1, 1, 3]
            info_g(i, 1) = 2;
    end
    
    if info_g(i, 2 : 4) == [1, 2, 3]
            info_g(i, 1) = 2;
    end
    
    if info_g(i, 2 : 4) == [2, 1, 3]
            info_g(i, 1) = 2;
    end
    
    if info_g(i, 2 : 4) == [2, 2, 3]
            info_g(i, 1) = 2;
    end
end

%% 노드 타입 갯수 세주기

n_type_0 = 0; % 일반 큐브
n_type_1 = 0; % 기타 바운더리 컨디션
n_type_2 = 0; % 건물 밑 노드
n_type_3 = 0; % 바닥 노드
n_type_4 = 0; % surface 와 접한 노드

for i = 1 : N_node_g
     if info_g(i, 1) == 0
        n_type_0 = n_type_0 + 1;
    end
    if info_g(i, 1) == 1
        n_type_1 = n_type_1 + 1;
    end
    if info_g(i, 1) == 2
        n_type_2 = n_type_2 + 1;
    end
    if info_g(i, 1) == 3
        n_type_3 = n_type_3 + 1;
    end
    if info_g(i, 1) == 4
        n_type_4 = n_type_4 + 1;
    end
end

%% 인접한 노드 정의해주기
clearvars x;
clearvars y;
clearvars z;

for i = 1 : N_node_g
    for j = 1 : N_node_g
        
        %%%%%%%%%% x방향 인접 (x방향 +,- 1)
%         if info_g(j, 2) == info_g(i, 2) % x값 같은 경우
        if info_g(j, 3) == info_g(i, 3) % y값 같은 경우
        if info_g(j, 4) == info_g(i, 4) % z값 같은 경우
            
            if info_g(j, 2) == info_g(i, 2) - 1 % x방향 -1 인접
                info_g(i, 5) = j;
            elseif info_g(i, 2) - 1 < 0
                info_g(i, 5) = N_node_g + 1;
            end
            
            if info_g(j, 2) == info_g(i, 2) + 1 % x방향 +1인접
                info_g(i, 6) = j;
            elseif info_g(i, 2) + 1 > 3
                info_g(i, 6) = N_node_g + 1;
            end
            
        end
        end        
%         end
        
        %%%%%%%%%% y방향 인접 (y방향 +,- 1)
        if info_g(j, 2) == info_g(i, 2) % x값 같은 경우
%         if info_g(j, 3) == info_g(i, 3) % y값 같은 경우
        if info_g(j, 4) == info_g(i, 4) % z값 같은 경우
            
            if info_g(j, 3) == info_g(i, 3) - 1 % x방향 -1 인접
                info_g(i, 7) = j;
            elseif info_g(i, 3) - 1 < 0
                info_g(i, 7) = N_node_g + 1;
            end
            
            if info_g(j, 3) == info_g(i, 3) + 1 % x방향 +1인접
                info_g(i, 8) = j;
            elseif info_g(i, 3) + 1 > 3
                info_g(i, 8) = N_node_g + 1;
            end
        
        end
        end        
%         end
        
        %%%%%%%%%% z방향 인접 (z방향 +,- 1)
        if info_g(j, 2) == info_g(i, 2) % x값 같은 경우
        if info_g(j, 3) == info_g(i, 3) % y값 같은 경우
%         if info_g(j, 4) == info_g(i, 4) % z값 같은 경우

            if info_g(j, 4) == info_g(i, 4) - 1 % x방향 -1 인접
                info_g(i, 9) = j;
            elseif info_g(i, 4) - 1 < 0
                info_g(i, 9) = N_node_g + 1;
            end
            
            if info_g(j, 4) == info_g(i, 4) + 1 % x방향 +1인접
                info_g(i, 10) = j;
            elseif info_g(i, 4) + 1 > 3
                info_g(i, 10) = N_node_g + 1;
            end

        end
        end        
%         end
    end
end

clearvars x;
clearvars y;
clearvars z;

%% n_type_4 인 애들 머리 위에 surface node 추가해주기

%%% N_node_g + 1 부터 N_node_g + n_type_4 에 해당하는 노드들과
%%% n_type 이 4 인 애들을 엮어주기

clearvars a;
a = N_node_g + 1;
for i = 1 : N_node_g
    if info_g(i, 1) == 4
        info_g(i, 11) = a;
        a = a + 1;
    end
end


%% M_g, S_g, f_g 매트릭스 추가

%%% 64개의 노드를 추가해 줘야 함.
%%% 일단 만들고, 원래의 M, S, f 매트릭스랑 합쳐서 추가 열교환을 넣어줘야 함.

%% 기본 행렬 추가, 먼저 큐브 갯수 + 1 (휴지통)만큼 만듦

N_node_g2 = N_node_g + n_type_4;

M_g = zeros(N_node_g + 1, N_node_g + 1);
S_g = zeros(N_node_g + 1, N_node_g + 1);
f_g = zeros(N_node_g + 1, 1);

M_g_1 = zeros(N_node_g, N_node_g);
S_g_1 = zeros(N_node_g, N_node_g);
f_g_1 = zeros(N_node_g, 1);

%% M_g 매트릭스 만들기
m = soil_specific_heat * 1 * 1; % * [1, 0; 0, 1];
for i = 1 : N_node_g
            M_g(i, i) = m;
end

%% S_g 매트릭스 만들기
%%% 64개의 큐브들이 모두 인접한 노드들과 열교환을 하도록 만들어주면 됨
N_adj_now = zeros(2, 1);
x = N_adj_now;
clearvars i;
clearvars j;

for i = 1 : N_node_g
    x(1, 1) = i;
    for j = 1 : 6
        x(2, 1) = info_g(i, j+4);
        Se_g = 1/6 * soil_conductivity * 1 /1 * [1, -1; -1, 1];
        for g=1:2; h=1:2;
            S_g(x(g,1),x(h,1)) = S_g(x(g,1),x(h,1)) + Se_g(g,h);
        end
    end
end

clearvars x;
clearvars i;
clearvars j;
clearvars g;
clearvars h;

%%% 절반 잘라주기
S_g = 1/2 * S_g;


%% f_g 매트릭스 만들기
clearvars x;

for i = 1 : N_node_g
    %%% 온도가 일정한 깊이의 지하, 일정한 온도 정해주기
    if info_g(i, 1) == 3
        f_g(i, 1) = const_temt;
    end
    
    if info_g(i, 1) == 1
        x = max(info_g(:, 4)) - info_g(i, 4) + 1;
        f_g(i, 1) = T_depth(x, 2);
    end
    
end

%% 바운더리 컨디션 밀어주기

%%%  M 매트릭스

for i = 1 : N_node_g
    if info_g(i, 1) == 1
        M_g(i, i) = 0;
    end
    
    if info_g(i, 1) == 3
        M_g(i, i) = 0;
    end
end

%%%  S 매트릭스
for i = 1 : N_node_g
    if info_g(i, 1) == 1
        S_g(i, :) = 0;
        S_g(i, i) = 1;
    end
    
    if info_g(i, 1) == 3
        S_g(i, :) = 0;
        S_g(i, i) = 1;
    end
end

%% M_g, S_g, f_g 사이즈 돌리기(휴지통 없애기)

M_g_1 = M_g(1:N_node_g, 1:N_node_g);
S_g_1 = S_g(1:N_node_g, 1:N_node_g);
f_g_1 = f_g(1:N_node_g, 1);

clearvars M_g;
clearvars S_g;
clearvars f_g;

M_g = M_g_1;
S_g = S_g_1;
f_g = f_g_1;

clearvars M_g_1;
clearvars S_g_1;
clearvars f_g_1;

%% 변수 간소화
clearvars x;
clearvars i;
clearvars j;
clearvars g;
clearvars h;
clearvars m;
%% 결과 내보내기

save ground_3D.mat

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ODE 부분을 지우고 추가할 모듈 부분 

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
    M(i, i) = 1/2 * m;
end

M(N_node_g2 + 13, N_node_g2 + 13) = M(N_node_g2 + 13, N_node_g2 + 13) + 1/2 * m; % 13번 노드 아래에 soil mass 1/2 추가해줌


%% S_ult 에 추가하기
clearvars x;
clearvars i;
clearvars j;


N_adj_now = zeros(2, 1);
x = N_adj_now;
    
%%% 76+16번 노드(T_out)와 대류 추가
for i = N_node_g + 1 : N_node_g + n_type_4
    x(1, 1) = i;
    x(2, 1) = N_node_g2 + 16;
    Se_g = soil_h_conv * 1 * [1, -1; -1, 1];
    
    for g=1:2; h=1:2;
        S_g(x(g,1),x(h,1)) = S_g(x(g,1),x(h,1)) + Se_g(g,h);
    end
end

%%% 76+15번 노드(T_sky)와 복사 추가

for i = N_node_g + 1 : N_node_g + n_type_4
    x(1, 1) = i;
    x(2, 1) = N_node_g2 + 15;
    Se_g = soil_h_rad * 1 * [1, -1; -1, 1];
    
    for g=1:2; h=1:2;
        S_g(x(g,1),x(h,1)) = S_g(x(g,1),x(h,1)) + Se_g(g,h);
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
                S_g(x(g,1),x(h,1)) = S_g(x(g,1),x(h,1)) + Se_g(g,h);
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
            S_g(x(g,1),x(h,1)) = S_g(x(g,1),x(h,1)) + Se_g(g,h);
        end
    end
end

%% f_ult 에 추가하기

%%% ODE 풀면서 업데이트 시켜줘야함

%% ODE


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% %% 사용할 행렬들의 기본 세팅
% 
% M=zeros(N_node, N_node);
% S=zeros(N_node, N_node);
% f=zeros(N_node, 1);
% 
% %% 원래의 M, S, f 매트릭스 만들기
% 
% x = room_input;
% 
%     for i = 1 : N_ele
%          N = zeros(2, 1); 
%          N(1, 1) = x(i, 2); N(2, 1) = x(i, 3);
%          
%          A = x(i, 4); U = x(i, 5); L = x(i, 6); CAP = x(i, 7);
%          Me = CAP * A * L * 1/2 * [1,0;0,1];
%          
%          if x(i, 8) == 1
%              Se = U * A * [1,-1;-1,1];
%              
%          elseif x(i, 8) == 2
%              Se = U * CAP * [1,-1;-1,1];
%          end
%      
%          for g = 1 : 2; h = 1 : 2;
%              M(N(g,1), N(h,1)) = M(N(g,1), N(h,1)) + Me(g,h);
%              S(N(g,1), N(h,1)) = S(N(g,1), N(h,1)) + Se(g,h);
%          end
%     end
% 
% for i = 1 : max(size(BCN))
%     M(BCN(1, i), BCN(1, i)) = 0;
%     S(BCN(1, i), :) = 0;
%     S(BCN(1, i), BCN(1, i)) = 1;
% end
% 
% %% f 매트릭스 만들기
% f = BCT;
% clearvars BCT;
% %%% ODE solve 할 때 16번 노드는 업데이트
% 
% %% Solar radiation(A * SHGC)
%     ASHGC = zeros(10, 1);
%     for j = 1 : N_ele_all
%         %%% south
%         if room_input(j, 2:3) == [south, 0]
%                 ASHGC(1, 1) = room_input(j, 4) * room_input(j, 5);
%         end
%          %%% east
%          if room_input(j, 2:3) == [east, 0]
%                 ASHGC(2, 1) = room_input(j, 4) * room_input(j, 5);
%         end
%         %%% north
%          if room_input(j,2:3) == [north,0]
%                 ASHGC(3,1)=room_input(j,4)*room_input(j,5);
%         end
%         %%% west
%         if room_input(j, 2:3) == [west, 0]
%                 ASHGC(4, 1) = room_input(j, 4) * room_input(j, 5);
%         end
%         %%% ceiling
%         if room_input(j, 2:3) == [ceiling, 0]
%                 ASHGC(5, 1) = room_input(j, 4) * room_input(j, 5);
%         end
%          %%%window
%          %%% southwind
%         if room_input(j, 2:3) == [southwind,0]
%                 ASHGC(6, 1) = room_input(j, 4) * room_input(j, 5);
%         end
%          %%% eastwind
%          if room_input(j, 2:3) == [eastwind, 0]
%                 ASHGC(7, 1) = room_input(j, 4) * room_input(j, 5);
%         end
%         %%% northwind
%         if room_input(j, 2:3) == [northwind, 0]
%                 ASHGC(8, 1) = room_input(j, 4) * room_input(j, 5);
%         end
%         %%% westwind
%         if room_input(j,2:3)==[westwind,0]
%                 ASHGC(9,1)=room_input(j,4)*room_input(j,5);
%         end
%         %%% ceilingwind
%         if room_input(j, 2:3) == [ceilingwind, 0]
%                 ASHGC(10, 1) = room_input(j, 4) * room_input(j, 5);
%         end
%     end
% 
% %% warmup
% T_preheating1 = zeros(24*30, N_node);
% T_preheating2 = zeros(24*30, N_node);
% 
% tspan = [0 : 1];
% 
% T01 = T0;
% T02 = T0;
% 
% if D1 - 30*24 < 0
%     D01 = N_weather + D1 - 30*24 + 1;
%     for i = 1 : 30*24 - D1
%         f(16, 1) = weather(D01 + i - 1, 4);
%         [t, T] = unsteady(tspan, T01, M, S, f);
%         T01 = T(end, :);
%         T_preheating1(i, :) = T01;
%     end
%     T02 = T_preheating1(30*24 - D1, :);
%     for i = 1 : D1
%         f(16, 1) = weather(i, 4);
%         [t,T] = unsteady(tspan, T02, M, S, f);
%         T02 = T(end, :);
%         T_preheating2(i, :) = T02;
%     end
% end
% if D1 - 30*24 > 0
%     for i = 1 : 30*24
%         f(16, 1) = weather(D1- 30*24 + 1, 4);
%         [t, T] = unsteady(tspan, T01, M, S, f);
%         T01 = T(end, :);
%         T_preheating2(i, :) = T01;
%     end
% end
% T00 = T_preheating2(end, :);
% 
% %%



 