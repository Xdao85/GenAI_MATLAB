% MATLAB Script: Visualize 3D Electric Field Vector E at Point P due to Two Point Charges

clear; clc; close all;

% --- Physical Constants ---
k = 8.98755e9;  % Coulomb's constant in N*m^2/C^2 (1 / (4 * pi * epsilon_0))

% --- Configuration ---
% Point Charge 1: Magnitude (Coulombs) and Position [x, y, z] (meters)
q1 = 2e-9;              % +2 nC
r1 = [-1, 0, 0];

% Point Charge 2: Magnitude (Coulombs) and Position [x, y, z] (meters)
q2 = -2e-9;             % -2 nC
r2 = [1, 0, 0];

% Observation Point P [Px, Py, Pz] (meters)
rP = [0, 1, 2];

% --- Vector Calculations ---
% Displacement vectors from charges to point P
R1 = rP - r1;
R2 = rP - r2;

% Distances (magnitudes)
dist1 = norm(R1);
dist2 = norm(R2);

% Individual electric field vectors (N/C)
E1 = k * q1 * R1 / (dist1^3);
E2 = k * q2 * R2 / (dist2^3);

% Resultant electric field vector at P
E_total = E1 + E2;

% --- Command Window Output ---
fprintf('--- Electric Field Calculation Results ---\n');
fprintf('Position P    : [%.2f, %.2f, %.2f] m\n', rP);
fprintf('Field E1      : [%.3e, %.3e, %.3e] N/C\n', E1);
fprintf('Field E2      : [%.3e, %.3```matlab
% MATLAB script to visualize electric field vector at a 3D point due to two point charges

% 1. Physical Constants and Parameters
k = 8.98755e9; % Coulomb's constant (N*m^2/C^2)

% Define point charges (in Coulombs) and their positions [x, y, z] (in meters)
q1 = 2e-9;                 % Charge 1 (+2 microCoulombs)
q1_pos = [-1, 0, 0];       % Position of q1 [x1, y1, z1]

q2 = -2e-9;                % Charge 2 (-3 microCoulombs)
q2_pos = [1, 0, 0];       % Position of q2 [x2, y2, z2]

% Target evaluation point P(Px, Py, Pz)
P = [0, 1, 2];             % Point P [Px, Py, Pz]

% 2. Calculate Electric Field Vectors
R1 = P - q1_pos;           % Position vector from q1 to P
R2 = P - q2_pos;           % Position vector from q2 to P

mag_R1 = norm(R1);         % Distance from q1 to P
mag_R2 = norm(R2);         % Distance from q2 to P

% Electric field vectors contributed by each charge
E1 = (k * q1 / mag_R1^3) * R1;
E2 = (k * q2 / mag_R2^3) * R2;

% Net Electric Field vector at P using Superposition Principle
E_net = E1 + E2;

% Display values in Command Window
fprintf('E1 vector at P:    [%.2e, %.2e, %.2e] N/C\n', E1(1), E1(2), E1(3));
fprintf('E2 vector at P:    [%.2e, %.2e, %.2e] N/C\n', E2(1), E2(2), E2(3));
fprintf('Net E vector at P: [%.2e, %.2e, %.2e] N/C\n', E_net(1), E_net(2), E_net(3));
fprintf('Net E Magnitude:   %.2e N/C\n', norm(E_net));

% 3. Visualization
figure('Color', 'w');
hold on;
grid on;
axis equal;
view(3); % Set 3D perspective

% Plot charge positions
scatter3(q1_pos(1), q1_pos(2), q1_pos(3), 120, 'r', 'filled', 'DisplayName', 'Charge q1 (+)');
scatter3(q2_pos(1), q2_pos(2), q2_pos(3), 120, 'b', 'filled', 'DisplayName', 'Charge q2 (-)');

% Plot evaluation point P
scatter3(P(1), P(2), P(3), 80, 'k', 'filled', 'DisplayName', 'Point P');

% Scale factor for visualizing vectors (normalizes field magnitude for display)
scale = 1.5 / norm(E_net); 

% Plot component and net electric field vectors at P
quiver3(P(1), P(2), P(3), E1(1)*scale, E1(2)*scale, E1(3)*scale, 0, ...
    'r--', 'LineWidth', 1.5, 'DisplayName', 'E_1');
quiver3(P(1), P(2), P(3), E2(1)*scale, E2(2)*scale, E2(3)*scale, 0, ...
    'b--', 'LineWidth', 1.5, 'DisplayName', 'E_2');
quiver3(P(1), P(2), P(3), E_net(1)*scale, E_net(2)*scale, E_net(3)*scale, 0, ...
    'g', 'LineWidth', 2.5, 'DisplayName', 'E_{net}');

% Plot line segments connecting charges to point P
plot3([q1_pos(1), P(1)], [q1_pos(2), P(2)], [q1_pos(3), P(3)], 'k:', 'LineWidth', 0.8, 'HandleVisibility', 'off');
plot3([q2_pos(1), P(1)], [q2_pos(2), P(2)], [q2_pos(3), P(3)], 'k:', 'LineWidth', 0.8, 'HandleVisibility', 'off');

% Formatting plot
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('3D Electric Field Vector \mathbf{E} at Point P');
legend('Location', 'northeastoutside');
rotate3d on;
hold off;
