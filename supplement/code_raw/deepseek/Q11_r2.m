%% Electric Field Visualization due to Two Point Charges
clear; clc; close all;

%% Parameters
% Physical constants
k = 8.99e9;  % Coulomb's constant (N·m²/C²)

% Point P where we want to calculate E field
Px = 1.0; Py = 1.0; Pz = 1.0;  % Position of point P (meters)
P = [Px, Py, Pz];

% Charge 1
q1 = 1e-9;           % Charge magnitude (Coulombs)
r1 = [0, 0, 0];      % Position of charge 1

% Charge 2
q2 = -1e-9;          % Charge magnitude (Coulombs)
r2 = [2, 2, 2];      % Position of charge 2

%% Compute Electric Field at Point P
% Vector from charge 1 to P
R1 = P - r1;
R1_mag = norm(R1);

% Vector from charge 2 to P
R2 = P - r2;
R2_mag = norm(R2);

% Electric field contributions (E = k*q*R_hat / R²)
E1 = k * q1 * R1 / R1_mag^3;
E2 = k * q2 * R2 / R2_mag^3;

% Total electric field
E_total = E1 + E2;
E_mag = norm(E_total);

%% Display Results in Command Window
fprintf('=== Electric Field Calculation ===\n');
fprintf('Point P = (%.2f, %.2f, %.2f) m\n\n', Px, Py, Pz);

fprintf('Charge q1 = %.2e C at (%.2f, %.2f, %.2f)\n', q1, r1(1), r1(2), r1(3));
fprintf('Charge q2 = %.2e C at (%.2f, %.2f, %.2f)\n\n', q2, r2(1), r2(2), r2(3));

fprintf('E1 (from q1) = [%.2f, %.2f, %.2f] N/C\n', E1(1), E1(2), E1(3));
fprintf('E2 (from q2) = [%.2f, %.2f, %.2f] N/C\n', E2(1), E2(2), E2(3));
fprintf('E_total      = [%.2f, %.2f, %.2f] N/C\n', E_total(1), E_total(2), E_total(3));
fprintf('|E_total|    = %.2f N/C\n', E_mag);

%% Visualization
figure('Position', [100 100 1200 500]);

% --- Subplot 1: 3D View of Geometry and Field Vectors ---
subplot(1,2,1);
hold on; grid on; axis equal;
view(45, 25);

% Scale factor for vector visualization
scale = 0.3 / max([norm(E1), norm(E2), E_mag]);

% Plot charges
plot3(r1(1), r1(2), r1(3), 'ro', 'MarkerSize', 14, 'MarkerFaceColor', 'r');
plot3(r2(1), r2(2), r2(3), 'bo', 'MarkerSize', 14, 'MarkerFaceColor', 'b');

% Plot point P
plot3(P(1), P(2), P(3), 'ks', 'MarkerSize', 12, 'MarkerFaceColor', 'y', 'LineWidth', 1.5);

% Plot position vectors (dashed lines) to P
plot3([r1(1) P(1)], [r1(2) P(2)], [r1(3) P(3)], 'r--', 'LineWidth', 1);
plot3([r2(1) P(1)], [r2(2) P(2)], [r2(3) P(3)], 'b--', 'LineWidth', 1);

% Plot E-field vectors at P
quiver3(P(1), P(2), P(3), scale*E1(1), scale*E1(2), scale*E1(3), ...
    'Color', [0.85 0.33 0.10], 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(P(1), P(2), P(3), scale*E2(1), scale*E2(2), scale*E2(3), ...
    'Color', [0.30 0.75 0.93], 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(P(1), P(2), P(3), scale*E_total(1), scale*E_total(2), scale*E_total(3), ...
    'Color', [0 0.6 0], 'LineWidth', 3, 'MaxHeadSize', 0.7);

xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('Electric Field Vectors at Point P');
legend({'q_1', 'q_2', 'Point P', 'r_1\rightarrowP', 'r_2\rightarrowP', ...
    'E_1', 'E_2', 'E_{total}'}, 'Location', 'northeastoutside');
xlim([min([r1(1),r2(1),Px])-0.5, max([r1(1),r2(1),Px])+0.5]);
ylim([min([r1(2),r2(2),Py])-0.5, max([r1(2),r2(2),Py])+0.5]);
zlim([min([r1(3),r2(3),Pz])-0.5, max([r1(3),r2(3),Pz])+0.5]);

% --- Subplot 2: Zoom on Point P showing only E-field vectors ---
subplot(1,2,2);
hold on; grid on; axis equal;
view(45, 25);

plot3(P(1), P(2), P(3), 'ks', 'MarkerSize', 12, 'MarkerFaceColor', 'y', 'LineWidth', 1.5);

% Larger scale for zoom view
scale2 = 0.6 / max([norm(E1), norm(E2), E_mag]);

quiver3(P(1), P(2), P(3), scale2*E1(1), scale2*E1(2), scale2*E1(3), ...
    'Color', [0.85 0.33 0.10], 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(P(1), P(2), P(3), scale2*E2(1), scale2*E2(2), scale2*E2(3), ...
    'Color', [0.30 0.75 0.93], 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(P(1), P(2), P(3), scale2*E_total(1), scale2*E_total(2), scale2*E_total(3), ...
    'Color', [0 0.6 0], 'LineWidth', 3, 'MaxHeadSize', 0.7);

xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title(sprintf('Zoom at P: |E_{total}| = %.2f N/C', E_mag));
legend({'Point P', 'E_1', 'E_2', 'E_{total}'}, 'Location', 'northeastoutside');

lim = 0.5*scale2*max([norm(E1), norm(E2), E_mag]);
xlim([Px-lim, Px+lim]);
ylim([Py-lim, Py+lim]);
zlim([Pz-lim, Pz+lim]);