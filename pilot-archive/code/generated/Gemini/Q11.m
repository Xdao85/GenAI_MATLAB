% =========================================================================
% 3D Electric Field Vector Visualization at Point P due to Two Point Charges
% =========================================================================

clear; clc; close all;

% --- 1. Physical Constants ---
k = 8.98755e9; % Coulomb's constant in N*m^2/C^2

% --- 2. Charge Setup ---
q1 = 2e-9;                 % Charge 1 in Coulombs (+2 nC)
pos1 = [-1.0, 0.0, 0.0];   % Position of q1 [x, y, z] in meters

q2 = -2e-9;                % Charge 2 in Coulombs (-2 nC)
pos2 = [1.0, 0.0, 0.0];    % Position of q2 [x, y, z] in meters

% --- 3. Observation Point P ---
P = [0, 1, 2];       % Target point P(Px, Py, Pz) in meters

% --- 4. Electric Field Calculations ---
% Vectors pointing from charges to observation point P
r1_vec = P - pos1;
r2_vec = P - pos2;

% Distances (magnitudes)
r1_mag = norm(r1_vec);
r2_mag = norm(r2_vec);

% Individual Electric Field Vectors (N/C)
E1 = (k * q1 / r1_mag^3) * r1_vec;
E2 = (k * q2 / r2_mag^3) * r2_vec;

% Total Electric Field Vector via Superposition
E_net = E1 + E2;
E_net_mag = norm(E_net);

% Display Numerical Results in Console
fprintf('=== Electric Field Results at P(%.2f, %.2f, %.2f) ===\n', P(1), P(2), P(3));
fprintf('E1 Vector    : [%10.3e, %10.3e, %10.3e] N/C\n', E1(1), E1(2), E1(3));
fprintf('E2 Vector    : [%10.3e, %10.3e, %10.3e] N/C\n', E2(1), E2(2), E2(3));
fprintf('E_net Vector : [%10.3e, %10.3e, %10.3e] N/C\n', E_net(1), E_net(2), E_net(3));
fprintf('E_net Mag    : %10.3e N/C\n', E_net_mag);

% --- 5. Visualization Setup ---
figure('Color', 'w', 'Name', '3D Electric Field Vector at Point P');
hold on; grid on; box on;
axis equal;

% Color coding charges (Red = Positive, Blue = Negative)
if q1 >= 0, color_q1 = [1 0 0]; else, color_q1 = [0 0 1]; end
if q2 >= 0, color_q2 = [1 0 0]; else, color_q2 = [0 0 1]; end

% Plot Charges
h_q1 = scatter3(pos1(1), pos1(2), pos1(3), 180, color_q1, 'filled', ...
    'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
h_q2 = scatter3(pos2(1), pos2(2), pos2(3), 180, color_q2, 'filled', ...
    'MarkerEdgeColor', 'k', 'LineWidth', 1.5);

% Plot Observation Point P
h_P = scatter3(P(1), P(2), P(3), 90, [0.2 0.2 0.2], 'filled');

% Dashed lines connecting charges to P
plot3([pos1(1) P(1)], [pos1(2) P(2)], [pos1(3) P(3)], 'k:', 'LineWidth', 1.2);
plot3([pos2(1) P(1)], [pos2(2) P(2)], [pos2(3) P(3)], 'k:', 'LineWidth', 1.2);

% --- 6. Vector Scaling for 3D Plot Display ---
% Scale vector arrows to visual spatial length (e.g., 0.6 spatial units)
vis_length = 0.6;
scale_factor = vis_length / E_net_mag;

E1_vis = E1 * scale_factor;
E2_vis = E2 * scale_factor;
E_net_vis = E_net * scale_factor;

% Plot Electric Field Component Vectors (Dashed arrows)
h_E1 = quiver3(P(1), P(2), P(3), E1_vis(1), E1_vis(2), E1_vis(3), 0, ...
    '--', 'Color', [0.85 0.35 0], 'LineWidth', 1.8, 'MaxHeadSize', 0.4);
h_E2 = quiver3(P(1), P(2), P(3), E2_vis(1), E2_vis(2), E2_vis(3), 0, ...
    '--', 'Color', [0.5 0 0.8], 'LineWidth', 1.8, 'MaxHeadSize', 0.4);

% Plot Net Electric Field Vector (Solid Bold Arrow)
h_Enet = quiver3(P(1), P(2), P(3), E_net_vis(1), E_net_vis(2), E_net_vis(3), 0, ...
    'Color', [0 0.6 0.2], 'LineWidth', 3.0, 'MaxHeadSize', 0.5);

% Text Labels
text(pos1(1), pos1(2), pos1(3)+0.15, sprintf('  q_1 = %.1f nC', q1*1e9), 'FontSize', 10, 'FontWeight', 'bold');
text(pos2(1), pos2(2), pos2(3)+0.15, sprintf('  q_2 = %.1f nC', q2*1e9), 'FontSize', 10, 'FontWeight', 'bold');
text(P(1), P(2), P(3)+0.15, sprintf('  P(%.2f, %.2f, %.2f)', P(1), P(2), P(3)), 'FontSize', 10, 'FontWeight', 'bold');

% --- 7. Formatting and Legend ---
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
title('3D Electric Field Vector \bf{E} at Point P');
legend([h_q1, h_q2, h_P, h_E1, h_E2, h_Enet], ...
    {'Charge q_1', 'Charge q_2', 'Point P', '\bfE_1 (from q_1)', '\bfE_2 (from q_2)', '\bfE_{net}'}, ...
    'Location', 'bestoutside');

view(3);
camlight;
lightingMethod = 'gouraud';

view(120,35)

