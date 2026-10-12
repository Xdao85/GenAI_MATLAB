%% Electric Field Visualization due to Two Point Charges in 3D
clear; clc; close all;

%% Parameters
% Point P where we want to calculate the electric field
Px = 0; Py = 1; Pz = 2;

% Charge 1
q1 = 2e-9;              % Charge magnitude (Coulombs)
Q1 = [-1, 0, 0];         % Position of charge 1 [x, y, z]

% Charge 2
q2 = -2e-9;             % Charge magnitude (Coulombs)
Q2 = [1, 0, 0];         % Position of charge 2 [x, y, z]

% Physical constants
k = 8.9875e9;           % Coulomb constant (N·m²/C²)

%% Compute Electric Field at Point P
% Position vector of point P
P = [Px, Py, Pz];

% Vector from Q1 to P
r1 = P - Q1;
r1_mag = norm(r1);

% Vector from Q2 to P
r2 = P - Q2;
r2_mag = norm(r2);

% Electric field contributions (Coulomb's Law)
E1 = k * q1 * r1 / r1_mag^3;
E2 = k * q2 * r2 / r2_mag^3;

% Total electric field at P
E_total = E1 + E2;
E_mag = norm(E_total);

fprintf('Electric Field at P(%.2f, %.2f, %.2f):\n', Px, Py, Pz);
fprintf('  E1   = [%.4e, %.4e, %.4e] N/C\n', E1);
fprintf('  E2   = [%.4e, %.4e, %.4e] N/C\n', E2);
fprintf('  E    = [%.4e, %.4e, %.4e] N/C\n', E_total);
fprintf('  |E|  = %.4e N/C\n', E_mag);

%% Visualization
figure('Color', 'w', 'Position', [100, 100, 1000, 750]);
hold on; grid on; axis equal;
view(45, 25);

% Scale factor for visualization (to make arrows visible)
scale = 0.5 / max([norm(E1), norm(E2), norm(E_total)]);

% --- Plot charges ---
plot3(Q1(1), Q1(2), Q1(3), 'o', 'MarkerSize', 14, ...
      'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
plot3(Q2(1), Q2(2), Q2(3), 'o', 'MarkerSize', 14, ...
      'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');

% --- Plot point P ---
plot3(P(1), P(2), P(3), 'p', 'MarkerSize', 18, ...
      'MarkerFaceColor', [0.9, 0.9, 0.2], 'MarkerEdgeColor', 'k');

% --- Plot Electric Field vectors ---
% E1 vector (from P)
quiver3(P(1), P(2), P(3), E1(1)*scale, E1(2)*scale, E1(3)*scale, ...
        0, 'Color', [0.85, 0.33, 0.10], 'LineWidth', 2.5, ...
        'MaxHeadSize', 0.5);

% E2 vector (from P)
quiver3(P(1), P(2), P(3), E2(1)*scale, E2(2)*scale, E2(3)*scale, ...
        0, 'Color', [0.00, 0.45, 0.74], 'LineWidth', 2.5, ...
        'MaxHeadSize', 0.5);

% Total E vector (from P)
quiver3(P(1), P(2), P(3), E_total(1)*scale, E_total(2)*scale, E_total(3)*scale, ...
        0, 'Color', [0.00, 0.60, 0.20], 'LineWidth', 3.5, ...
        'MaxHeadSize', 0.6);

% --- Dashed lines from charges to P ---
plot3([Q1(1), P(1)], [Q1(2), P(2)], [Q1(3), P(3)], ...
      '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);
plot3([Q2(1), P(1)], [Q2(2), P(2)], [Q2(3), P(3)], ...
      '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);

%% Labels and Legend
xlabel('X (m)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Y (m)', 'FontSize', 12, 'FontWeight', 'bold');
zlabel('Z (m)', 'FontSize', 12, 'FontWeight', 'bold');
title('Electric Field at Point P due to Two Point Charges', ...
      'FontSize', 14, 'FontWeight', 'bold');

% Text annotations
text(Q1(1)+0.08, Q1(2), Q1(3), ...
     sprintf('Q_1 = %.1e C', q1), 'FontSize', 10, ...
     'Color', 'r', 'FontWeight', 'bold');
text(Q2(1)+0.08, Q2(2), Q2(3), ...
     sprintf('Q_2 = %.1e C', q2), 'FontSize', 10, ...
     'Color', 'b', 'FontWeight', 'bold');
text(P(1)+0.08, P(2), P(3)+0.08, ...
     sprintf('P(%.1f, %.1f, %.1f)', Px, Py, Pz), ...
     'FontSize', 10, 'FontWeight', 'bold');

legend({'Q_1', 'Q_2', 'Point P', 'E_1 (due to Q_1)', ...
        'E_2 (due to Q_2)', 'E_{total} = E_1 + E_2'}, ...
        'Location', 'northeastoutside', 'FontSize', 10);

set(gca, 'FontSize', 11, 'LineWidth', 1);
hold off;

% Thêm 
view(3)
view(120,35)