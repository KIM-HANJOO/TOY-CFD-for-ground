clc;
load('vent_and_infilt.mat')
load('T_basic.mat')
load('T_airtube.mat')

T_compare = T_basic - T_airtube;



%% 3D 플롯할 시간 정하기
plottime_month = 8;%월
plottime_day = 1;%일
plottime_hour = 12;%시

%%
for i=1:N_weather
    if T_basic(i, 1) == plottime_month
        if T_basic(i, 2) == plottime_day
            if T_basic(i, 3) == plottime_hour
                D3 = i;
            end
        end
    end
end

%%
% display startdate & enddate
startdate = T_basic(D1, 1:2)
enddate = T_basic(D2, 1:2)
plotdate = T_basic(D3, 1:2)

% expressing date by decimal numbers
DD1 = T_basic(D1, 1) + T_basic(D1, 2) * 1/100; 
DD2 = T_basic(D2, 1) + T_basic(D2, 2) * 1/100;

%% subplot(2, 2, 1)
subplot(2, 2, 1)

x = N_node_g2;
n = D2 - D1 + 1; y = linspace(DD1, DD2, n);

plot(y, T_compare(D1:D2, [3 + x + 17]));
max(T_compare(:, 4:end))

axis([DD1 DD2 -1 +1]);
xtickformat('%.2f');
% pbaspect([1 1 1])
title('temp');
xlabel('date'); ylabel('degC');
grid on

%% subplot(2, 2, 3)
subplot(2, 2, 3)
clearvars X;
clearvars T_plot;
clearvars a;

tt = D3;
T_plot = zeros(mesh * (mesh + 1), 3);

a = 1;
b = mesh * mesh + 1;
for i = 1 : N_node_g2
    if i < N_node_g + 1    
        if info_g(i, 2) == mesh / 2 % x = 3일 때
            T_plot(a, 1) = info_g(i, 3) + 1; % y값 저장
            T_plot(a, 2) = info_g(i, 4) + 1; % z값 저장
            T_plot(a, 3) = T_all(tt, i + 3);
            a = a + 1;
        end
    elseif i > N_node_g
        for j = 1 : N_node_g
            if i == info_g(j, 11) % info_g 에 저장된 surface node값이랑 같은지
                if info_g(j, 2) == mesh / 2 % x = 3일 때
                    T_plot(b, 1) = info_g(j, 3) + 1; %y값 저장
                    T_plot(b, 2) = mesh + 1;
                    T_plot(b, 3) = T_all(tt, i + 3);
                    b = b + 1;
                end
            end
        end
    end
end



for i = 1 : N_node_g
    if info_g(i, 1) == 2 % 건물 밑 노드인지 확인
        if info_g(i, 2) == mesh / 2 % x값 3일 때
            info_g(i, 3)
             T_plot(b, 1) = info_g(i, 3) + 1; % y값 저장
             T_plot(b, 2) = info_g(i, 4) + 2; % z값 저장
             T_plot(b, 3) = T_all(tt, 3 + x + 13);
             b = b + 1;
        end
    end
end

TT = zeros(mesh + 1, mesh);

X = T_plot(:, 1); % 실제 y값
Y = T_plot(:, 2); % 실제 z값
Z = T_plot(:, 3); % 온도

for i = 1 : max(size(T_plot(:, 1)))
    TT(mesh + 2 - Y(i, 1), mesh + 1 - X(i, 1)) = Z(i, 1);
end

for i = 1 : mesh; j = 1 : mesh + 1;
    if TT(j, i) == 0
        TT(j, i) = T_all(tt, N_node_g2 + 1 + 3);
    end
end

imagesc(TT)
colorbar
pbaspect([6 7 1])

% title('');
% s = imagesc(TT);
% s.FaceColor = 'interp';
%% subplot(2, 2, 4)
subplot(2, 2, 4)
TT1 = interp2(TT,5);
imagesc(TT1)
colorbar
pbaspect([6 7 1])


