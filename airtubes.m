function [f1, f2] = airtubes(X, Y)
 
 inlet = X(1, :);
 outlet = X(2, :);
 tube_depth = X(3, 1);
 airtube_nodes = zeros(3 + 2 * tube_depth, 3);
 
 %% inlet enter
 for i = 1 : tube_depth
     airtube_nodes(i, 1 : 2) = inlet(1, 1 : 2);
     airtube_nodes(i, 3) = inlet(1, 3) - i + 1;
 end
 
 %% tubes at constant depth
 j = tube_depth;
 airtube_nodes(j + 1, 1) = inlet(1, 1); % x constant
 airtube_nodes(j + 1, 2) = inlet(1, 2) - 1; % y - 1
 airtube_nodes(j + 1, 3) = inlet(1, 3) - tube_depth + 1; % z constant
 
 airtube_nodes(j + 2, 1) = inlet(1, 1); % x constant
 airtube_nodes(j + 2, 2) = inlet(1, 2) - 2; % y - 2
 airtube_nodes(j + 2, 3) = inlet(1, 3) - tube_depth + 1; % z constant
 
 airtube_nodes(j + 3, 1) = inlet(1, 1) - 1; % x - 1
 airtube_nodes(j + 3, 2) = inlet(1, 2) - 2; % y - 2
 airtube_nodes(j + 3, 3) = inlet(1, 3) - tube_depth + 1; % z constant
 
 %% outlet
 for i = 1 : tube_depth
     k = j + 3;
     depth_now = tube_depth - i;
     airtube_nodes(k + (tube_depth - i + 1), 1 : 2) = outlet(1, 1 : 2);
     airtube_nodes(k + i, 3) = outlet(1, 3) - depth_now;
 end
 
 
 
 Z = airtube_nodes;
 airtube_nodes_number = zeros(max(size(Z(:, 1))), 1);
 for j = 1 : max(size(Y(:, 1)))
 for i = 1 : max(size(Z(:, 1)))
     if Z(i, 1) == Y(j, 2) + 1
         if Z(i, 2) == Y(j, 3) + 1
             if Z(i, 3) == Y(j, 4) + 1
                 airtube_nodes_number(i, 1) = j;
                 Y(j, 1) = 5;
             end
         end
     end
 end
 end
 
 
     
 clearvars i;
 clearvars k;
 clearvars j;
 clearvars depth_now;
 clearvars Z;
 

 f1 = airtube_nodes_number;
 f2 = Y;
end