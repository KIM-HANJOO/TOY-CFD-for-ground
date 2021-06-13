%%
load('duct_all.mat')
load('set_up_for_airduct.mat')

nums = zeros(num_duct, 3);
for i = 1 : num_duct
    nums(i, 1) = N_weather * (i - 1) + 1;
    nums(i, 2) = N_weather * i;
    nums(i, 3) = 18 + length_duct(1, i) * 2;
end

i = 1;
T_duct1 = duct_all(nums(i, 1) : nums(i, 2), 1 : nums(i, 3) + 3);

i = 2;
T_duct2 = duct_all(nums(i, 1) : nums(i, 2), 1 : nums(i, 3) + 3);

i = 3;
T_duct3 = duct_all(nums(i, 1) : nums(i, 2), 1 : nums(i, 3) + 3);

i = 4;
T_duct4 = duct_all(nums(i, 1) : nums(i, 2), 1 : nums(i, 3) + 3);

i = 5;
T_duct5 = duct_all(nums(i, 1) : nums(i, 2), 1 : nums(i, 3) + 3);

%%
load('basic_T_all.mat')
disp('result comparing')
T_diff1 = basic_T_all(:, 17 + 3) - T_duct1(: , 17 + 3);
T_diff2 = basic_T_all(:, 17 + 3) - T_duct2(: , 17 + 3);
T_diff3 = basic_T_all(:, 17 + 3) - T_duct3(: , 17 + 3);
T_diff4 = basic_T_all(:, 17 + 3) - T_duct4(: , 17 + 3);
T_diff5 = basic_T_all(:, 17 + 3) - T_duct5(: , 17 + 3);

T_diff_all = zeros(N_weather, num_duct);
T_diff_all(:, 1) = T_diff1;
T_diff_all(:, 2) = T_diff2;
T_diff_all(:, 3) = T_diff3;
T_diff_all(:, 4) = T_diff4;
T_diff_all(:, 5) = T_diff5;

X = zeros(N_weather, 1);
for i = 1 : N_weather
    X(i, 1) = i;
end



% 
% subplot(3, 2, 1)
% plot(X, T_diff1)
% 
% subplot(3, 2, 2)
% plot(X, T_diff2)
% 
% subplot(3, 2, 3)
% plot(X, T_diff3)
% 
% subplot(3, 2, 4)
% plot(X, T_diff4)
% 
% subplot(3, 2, 5)
% plot(X, T_diff5)


%% result


% %% defining the effeciency
% 
% cost_airduct = (digging_per_unit + unit_cost) * duct_length;
% effi = zeros(1, num_length);
% effi(1,length_num_now) = 1 / cost_airduct * sum(T_diff(D1 : D2, 1));
% 
% save('length_all_effi.mat', 'length_all', 'effi')