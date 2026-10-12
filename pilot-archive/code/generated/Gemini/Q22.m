% =========================================================================
% BIOT-SAVART LAW: MAGNETIC FIELD OF A FINITE LINEAR CONDUCTOR IN 3D
% =========================================================================

clear; clc; close all;

%% 1. INPUT PARAMETERS
% Physical constants
mu0 = 4*pi*1e-7;          % Magnetic permeability of free space (H/m)

% Conductor parameters
I = 1;                   % Current in Amperes (A)
l = 2.0;                  % Length of conductor (m)
A = [0.25, 0.5, 0];            % Center of conductor [Ax, Ay, Az] (m)

% Observation Point P
P = [1, 1, 0];      % Point P [Px, Py, Pz] (m)

%% 2. NUMERICAL COMPUTATION USING BIOT-SAVART LAW
% Vector from center: segment endpoints along z-axis
z_start = A(3) - l/2;
z_end   = A(3) + l/2;

% Discretize the conductor into N small current elements dL
N = 1000;
z_elem = linspace(z_start, z_end, N);
dz = (z_end - z_start) / (N - 1);

% Differential length vector dL (oriented along +z direction)
dL = [0, 0, dz];          

B_total = [0, 0, 0];      % Initialize magnetic field vector [Bx, By, Bz]

% Integrate dB over the length of the conductor
for k = 1:N
    % Position vector of current element dL_k
    r_elem = [A(1), A(2), z_elem(k)];
    
    % Displacement vector r from element dL to observation point P
    r_vec = P - r_elem;
    r_mag = norm(r_vec);   % Distance |r|
    
    % Differential magnetic field dB using Biot-Savart law:
    % dB = (mu0 * I / (4 * pi)) * (dL x r_vec) / |r|^3
    dB = (mu0 * I / (4 * pi)) * cross(dL, r_vec) / (r_mag^3);
    
    % Sum contribution
    B_total = B_total + dB;
end

% Display computed magnetic field components and magnitude
fprintf('Magnetic Field B at point P:\n');
fprintf('  Bx = %10.3e T\n', B_total(1));
fprintf('  By = %10.3e T\n', B_total(2));
fprintf('  Bz = %10.3e T\n', B_total(3));
fprintf('  |B| = %10.3e T\n', norm(B_total));

%% 3. 3D VECTOR VISUALIZATION
figure('Color', 'w');
hold on; grid on; axis equal;
view(3);                  % 3D view angle

% Plot the conductor line
line([A(1), A(1)], [A(2), A(2)], [z_start, z_end], ...
    'Color', 'r', 'LineWidth', 4, 'DisplayName', 'Conductor (Current I)');

% Mark the midpoint A and observation point P
plot3(A(1), A(2), A(3), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'DisplayName', 'Center A');
plot3(P(1), P(2), P(3), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'DisplayName', 'Point P');

% Normalize B vector for visual scaling in 3D plot
scale_factor = 0.3;      % Scale length of arrow for display
B_dir = (B_total / norm(B_total)) * scale_factor;

% Plot the magnetic field vector arrow at point P using quiver3
quiver3(P(1), P(2), P(3), B_dir(1), B_dir(2), B_dir(3), 0, ...
    'Color', [0 0.5 0], 'LineWidth', 2.5, 'MaxHeadSize', 0.5, ...
    'DisplayName', 'Magnetic Field B');

% Plot current direction arrow along conductor
quiver3(A(1), A(2), z_start, 0, 0, l, 0, ...
    'Color', 'r', 'LineWidth', 1.5, 'LineStyle', '--', 'HandleVisibility', 'off');

% Labels and Title
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('3D Magnetic Field Vector B computed via Biot–Savart Law');
legend('Location', 'northeast');

% Adjust axis margins
padding = 0.5;
xlim([min([A(1), P(1)]) - padding, max([A(1), P(1)]) + padding]);
ylim([min([A(2), P(2)]) - padding, max([A(2), P(2)]) + padding]);
zlim([z_start - padding, z_end + padding]);

% Thêm 
view(120,45)