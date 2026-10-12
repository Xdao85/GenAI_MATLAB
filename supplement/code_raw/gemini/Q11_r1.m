% Electric Field Vector Visualization at Point P due to Two Point Charges
clc; clear; close all;

% --- 1. Parameters & Configuration ---
k_e = 8.98755e9; % Coulomb's constant (N*m^2/C^2)

% Point Charge 1 [Charge in Coulombs, Position [x, y, z] in meters]
q1 = 2e-9;          % +2 nC
pos1 = [-1, 0, 0];  

% Point Charge 2 [Charge in Coulombs, Position [x, y, z] in meters]
q2 = -2e-9;         % -2 nC
pos2 = [1, 0, 0];   

% Observation Point P [Px, Py, Pz] in meters
P = [0.5, 1.2, 0.8]; 

% --- 2. Field Computation ---
% Displacement vectors pointing from charges to P
r1 = P - pos1;
r2 = P - pos2;

% Distances (magnitudes of displacement vectors)
R1 = norm(r1);
R2 = norm(r2);

% Electric field vectors from individual charges (N/C)
E1 = (k_e * q1 / R1^3) * r1;
E2 = (k_e * q2 / R2^3) * r2;

% Net electric field vector at point P
E_total = E1 + E2;

% --- 3. Display Numerical Results in Command Window ---
fprintf('=== Electric Field Calculation Results ===\n');
fprintf('E1 vector (from q1) : [%10.3e, %10.3e, %10.3e] N/C\n', E1);
fprintf('E2 vector (from q2) : [%10.3e, %10.3e, %10.3e] N/C\n', E2);
fprintf('E_total vector      : [%10.3e, %10.3e, %10.3e] N/C\n', E_total);
fprintf('E_total magnitude   : %10.3e N/C\n\n', norm(E_total));

% --- 4. 3D Visualization ---
figure('Name', '3D Electric Field Vector at Point P', 'Color', 'w');
hold on; grid on; axis equal;
view(3); % Enable 3D perspective

% Color coding: Red for positive charges, Blue for negative
c1 = [1 0 0]; if q1 < 0, c1 = [0 0 1]; end
c2 = [1 0 0]; if q2 < 0, c2 = [0 0 1]; end

% Plot Charge 1 and Charge 2
scatter3(pos1(1), pos1(2), pos1(3), 120, c1, 'filled', 'MarkerEdgeColor', 'k');
scatter3(pos2(1), pos2(2), pos2(3), 120, c2, 'filled', 'MarkerEdgeColor', 'k');

% Plot Point P
scatter3(P(1), P(2), P(3), 80, [0.2 0.2 0.2], 'filled');

% Visual scaling factor to draw arrows at readable graphic length
arrow_scale = 0.4 / norm(E_total);

% Plot component vectors (dashed arrows)
h1 = quiver3(P(1), P(2), P(3), E1(1)*arrow_scale, E1(2)*arrow_scale, E1(3)*arrow_scale, 0, ...
    'Color', [0.85 0.325 0.098], 'LineWidth', 1.5, 'LineStyle', '--', 'MaxHeadSize', 0.5);

h2 = quiver3(P(1), P(2), P(3), E2(1)*arrow_scale, E2(2)*arrow_scale, E2(3)*arrow_scale, 0, ...
    'Color', [0.494 0.184 0.556], 'LineWidth', 1.5, 'LineStyle', '--', 'MaxHeadSize', 0.5);

% Plot total electric field vector (solid thick arrow)
h3 = quiver3(P(1), P(2), P(3), E_total(1)*arrow_scale, E_total(2)*arrow_scale, E_total(3)*arrow_scale, 0, ...
    'Color', [0.466 0.674 0.188], 'LineWidth', 2.5, 'MaxHeadSize', 0.8);

% Label points and charges
text(pos1(1), pos1(2), pos1(3)+0.15, sprintf('q_1 = %.1f nC', q1*1e9), 'HorizontalAlignment', 'center', 'FontSize', 10);
text(pos2(1), pos2(2), pos2(3)+0.15, sprintf('q_2 = %.1f nC', q2*1e9), 'HorizontalAlignment', 'center', 'FontSize', 10);
text(P(1)+0.05, P(2)+0.05, P(3)+0.05, 'P(P_x, P_y, P_z)', 'FontSize', 10, 'FontWeight', 'bold');

% Axes & Legend Formatting
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
title('Electric Field Vector \vec{E} at Point P');
legend([h1, h2, h3], {'\vec{E}_1 (from q_1)', '\vec{E}_2 (from q_2)', '\vec{E}_{total}'}, 'Location', 'northeast');

rotate3d on;
