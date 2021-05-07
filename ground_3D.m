clc; 
clear all;
delete ground_3D.mat
load("inputs.mat")
N_node_g = 10 * 10 * fix(depth); %공간좌표 격자 갯수

%% 주의사항
% M 매트릭스 만들고 boundary conditions 해당하는 행 지워야 하는지?
% 파일 보낼 때 inputs.mat 파일과 ground_3D.mat 파일 같이 보내기. 안그러면 지울 수 없다고 뜸.

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
    N_adjacent(i, 3) = Node_14 + N_node_g2; % z방향 이후 (위에 추가)
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

for i = 1 : N_node_g2
    for j = 2 : 7
        if N_adjacent2(i, j) == 0
            N_adjacent2(i, j) = N_node_g2 + 1;
        end
    end
end

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
    
    if BCN_g2(i, 1) == 4
        for i = 1 : n_type_4
            x(1, 1) = surface_node(i, 1);
            x(1, 2) = 1201;
                    Se_g = soil_h_rad * 1 * [1, -1; -1, 1];
                for g=1:2; h=1:2;
                    S_g2(x(g,1),x(h,1)) = S_g2(x(g,1),x(h,1)) + Se_g(g,h);
                end
                
            x(1, 2) = 1202;
                    Se_g = soil_h_conv * 1 * [1, -1; -1, 1];
                for g=1:2; h=1:2;
                    S_g2(x(g,1),x(h,1)) = S_g2(x(g,1),x(h,1)) + Se_g(g,h);
                end
        end
    end
    
    if BCN_g2(i, 1) == 2
        
    end
end
clearvars x;

S_g2 = 1/2 * S_g2;
S_g = S_g2(1:N_node_g2, 1:N_node_g2);

clearvars S_g2;
clearvars N_adjacent2;
clearvars N_adj_now;

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

%% 변수 간소화
clearvars j;
clearvars i;
clearvars r;
clearvars c;
clearvars g;
clearvars h;
clearvars row_floor;
clearvars column_floor;
clearvars m;
clearvars N_adj_now;
clearvars Se_g;
clearvars x;

%% 결과 저장
save ground_3D.mat