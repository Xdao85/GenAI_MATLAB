% Script to compute and visualize magnetic field B of a finite linear conductor

clear; clc; close all;

%% 1. User Defined Parameters
mu0 = 4*pi*1e-7;        % Permeability of free space [H/m]
I   = 1;             % Current carrying capacity [A]
L   = 2;              % Length of the conductor [m]

% Position of the conductor center A = [Ax, Ay, Az]
A = [0.25, 0.5, 0];    

% Observation point P = [Px, Py, Pz]
P = [1, 1, 0];    

%% 2. Conductor Geometry Setup
% Conductor endpoints parallel to z-axis
z1 = A(3) - L/2;
z2 = A(3) + L/2;

wire_start = [A(1), A(2), z1];
wire_end   = [A(1), A(2), z2];

%% 3. Magnetic Field Calculation (Biot-Savart Law)
rx = P(1) - A(1);
ry = P(2) - A(2);
R  = sqrt(rx^2 + ry^2);  % Radial distance in xy-plane

if R == 0
    error('Point P lies directly on the conductor axis; magnetic field is singular.');
end

% Integral substitution terms
u1 = z1 - P(3);
u2 = z2 - P(3);

% Definite integral result along conductor length
integral_factor = (u2 / sqrt(R^2 + u2^2) - u1 / sqrt(R^2 + u1^2)) / (R^2);

% Vector components of B
Bx = -(mu0 * I / (4 * pi)) * ry * integral_factor;
By =  (mu0 * I / (4 * pi)) * rx * integral_factor;
Bz =  0;

B = [Bx, By, Bz];
B_mag = norm(B);

% Print results to command window
fprintf('Magnetic Field Vector B at P: [%.3e, %.3e, %.3e] T\n', B(1), B(2), B(3));
fprintf('Magnitude |B|: %.3e T\n', B_mag);

%% 4. 3D Vector Visualization
figure('Color', 'w', 'Name', 'Biot-Savart Law 3D Visualization');
hold on; grid on; axis equal;
xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');
title('3D Magnetic Field Vector \bf{B} from Finite Linear Conductor');

% Draw Conductor
plot3([wire_start(1), wire_end(1)], ...
      [wire_start(2), wire_end(2)], ...
      [wire_start(3), wire_end(3)], ...
      'r-', 'LineWidth', 3, 'DisplayName', 'Conductor (I)');

% Current Direction Indicator
quiver3(A(1), A(2), A(3)-0.1*L, 0, 0, 0.2*L, 0, ...
        'r', 'LineWidth', 2, 'MaxHeadSize', 0.6, 'HandleVisibility', 'off');

% Observation Point P
plot3(P(1), P(2), P(3), 'ko', 'MarkerFaceColor', 'k', ...
      'MarkerSize', 6, 'DisplayName', 'Point P');

% Plot Magnetic Field Vector B (Scaled for visualization)
scale_factor = 0.3 / B_mag; % Normalizes arrow length to 0.3 meters on plot
quiver3(P(1), P(2), P(3), ...
        B(1)*scale_factor, B(2)*scale_factor, B(3)*scale_factor, ...
        0, 'b', 'LineWidth', 2.5, 'MaxHeadSize', 0.5, ...
        'DisplayName', 'Magnetic Field Vector B');

legend('Location', 'northeast');
view(37.5, 30);
rotate3d on;
