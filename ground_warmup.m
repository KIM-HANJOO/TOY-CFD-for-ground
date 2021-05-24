clc;
clear all;
load('center_temp.mat')

T_ground = T_all;
T_ground_depth = zeros(N_weather, 3 + 7);

T_ground_depth(:, 1:3) = T_ground(:, 1:3);

for i = 1 : N_node_go
    if Node_info(i, 2) == 2
        if Node_info(i, 3) == 2
            for j = 0 : 6
                if Node_info(i, 4) == j
                    T_ground_depth(:, j + 4) = T_ground(:, i + 3);
                end
            end
        end
    end
end

save('T_ground3.mat','T_ground_depth')

% save update_initial_condition.mat