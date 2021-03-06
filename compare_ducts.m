%%
clc;
clear all;
load('set_up_for_airduct.mat')
load('duct_all.mat')

%% 3D 플롯할 시간 정하기
plottime_month = 6;%월
plottime_day = 21;%일
plottime_hour = 13;%시

%%
for i=1:N_weather
    if T_all(i,1)==plottime_month
        if T_all(i,2)==plottime_day
            if T_all(i,3)==plottime_hour
                D3=i;
            end
        end
    end
end
%%
nums = zeros(num_duct, 3);
for i = 1 : num_duct
    nums(i, 1) = N_weather * (i - 1) + 1;
    nums(i, 2) = N_weather * i;
    nums(i, 3) = 18 + length_duct(1, i) * 3;
end

i = 1;
T_duct1 = duct_all(nums(i, 1) : nums(i, 2), 1 : nums(i, 3) + 3);
% i = 2;
% T_duct2 = duct_all(nums(i, 1) : nums(i, 2), 1 : nums(i, 3) + 3);
% i = 3;
% T_duct3 = duct_all(nums(i, 1) : nums(i, 2), 1 : nums(i, 3) + 3);
% i = 4;
% T_duct4 = duct_all(nums(i, 1) : nums(i, 2), 1 : nums(i, 3) + 3);
% i = 5;
% T_duct5 = duct_all(nums(i, 1) : nums(i, 2), 1 : nums(i, 3) + 3);

%%
load('basic_T_all.mat')
load('basic_T_all_novent.mat')
disp('result comparing')
T_diff1 = T_duct1(: , 17 + 3) - basic_T_all(:, 17 + 3);
% T_diff2 = basic_T_all(:, 17 + 3) - T_duct2(: , 17 + 3);
% T_diff3 = basic_T_all(:, 17 + 3) - T_duct3(: , 17 + 3);
% T_diff4 = basic_T_all(:, 17 + 3) - T_duct4(: , 17 + 3);
% T_diff5 = basic_T_all(:, 17 + 3) - T_duct5(: , 17 + 3);

T_diff_all = zeros(N_weather, num_duct);
T_diff_all(:, 1) = T_diff1;
% T_diff_all(:, 2) = T_diff2;
% T_diff_all(:, 3) = T_diff3;
% T_diff_all(:, 4) = T_diff4;
% T_diff_all(:, 5) = T_diff5;
subplot(1, 3, 1)
% plot(1 : N_weather, basic_T_all(:, 17 +3)); hold on;
% legend('basic model');
% plot(1 : N_weather, T_duct1(:, 17 + 3)); hold on;
% legend('AEHE');
% plot(1 : N_weather, T_diff1);hold on;



% plot(1 : N_weather, basic_T_all_novent(:, 3 + 17), 'r');hold on;
% plot(1 : N_weather, basic_T_all(:, 17 + 3), 'b'); hold on;
% plot(1 : N_weather, T_duct1(:, 17 + 3), 'g');
%%
plot(1 : N_weather, basic_T_all_novent(:, 3 + 17), 'r', 1 : N_weather, basic_T_all(:, 17 + 3), 'b', 1 : N_weather, T_duct1(:, 17 + 3), 'g');
legend({'basic without infilt', 'basic with infilt', 'EAHE'},'Location','northwest')
axis([1 N_weather -5 +30]);


% plot( 1 : N_weather, basic_T_all(:, 16 + 3), 'g', 1 : N_weather, basic_T_all_novent(:, 3 + 17), 'r', 1 : N_weather, basic_T_all(:, 17 + 3), 'b');
% legend({'Tout', 'basic without vent', 'basic with vent'},'Location','northwest')
% axis([1 N_weather -5 +30]);
%%
% legend('AEHE - basic');

subplot(1, 3, 2)
plot(1 : N_weather, T_diff1);
axis([1 N_weather -5 +10]);

subplot(1, 3, 3)

duct_air_1 = zeros(1, length_duct(1, 1));
for i = 1 : length_duct(1, 1)
    duct_air_1(1, i) = 18 + 3 * (i - 1) + 1;
end

temp_duct_air_1 = zeros(N_weather, length_duct(1, 1));
for i = 1 : length_duct(1, 1)
    temp_duct_air_1(:, i) = T_duct1(:, 3 + duct_air_1(1, i));
end
temp_duct_air_1(:, length_duct(1, 1) + 1) = T_duct1(:, 3 + 17);
% temp_duct_air_1(:, length_duct(1, 1) + 2) = basic_T_all(:, 3 + 17);
% temp_duct_air_1(:, length_duct(1, 1) + 3) = basic_T_all_novent(:, 3 + 17);
x = temp_duct_air_1(D3, :);
imagesc(x)
c = colorbar("northoutside");
% colorbar
pbaspect([11 1 1])



% 1 : N_weather
% a = 2000;
% plot(a, temp_duct_air_1(a, 1)); hold on;
% plot(a, temp_duct_air_1(a, 2)); hold on;
% plot(a, temp_duct_air_1(a, 3)); hold on;
% % plot(1 : N_weather, temp_duct_air_1(:, 4)); hold on;
% % plot(1 : N_weather, temp_duct_air_1(:, 5)); hold on;
% % 
% % plot(1 : N_weather, temp_duct_air_1(:, 6)); hold on;
% % plot(1 : N_weather, temp_duct_air_1(:, 7)); hold on;
% % plot(1 : N_weather, temp_duct_air_1(:, 8)); hold on;
% % plot(1 : N_weather, temp_duct_air_1(:, 9)); hold on;
% % plot(1 : N_weather, temp_duct_air_1(:, 10)); hold on;
% 
% % plot(1 : N_weather, T_duct2); hold on;
% % plot(1 : N_weather, T_duct3); hold on;
% % plot(1 : N_weather, T_duct4); hold on;
% % plot(1 : N_weather, T_duct5); hold on;

%% result


% %% defining the effeciency
% 
% cost_airduct = (digging_per_unit + unit_cost) * duct_length;
% effi = zeros(1, num_length);
% effi(1,length_num_now) = 1 / cost_airduct * sum(T_diff(D1 : D2, 1));
% 
% save('length_all_effi.mat', 'length_all', 'effi')