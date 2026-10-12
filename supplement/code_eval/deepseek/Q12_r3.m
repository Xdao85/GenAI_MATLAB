%% Main Script: Electric Field Calculation and Visualization
% This script calculates the electric field at a point P due to two point charges
% and visualizes the result using a 3D quiver plot.

clear; clc; close all;

%% Define Problem Parameters
% Physical constant: Coulomb's constant (N·m²/C²)
k = 8.9875517923e9;

% Charge 1: position (m) and magnitude (C)
q1 = 2e-9;              % Charge magnitude [C]
pos1 = [-1, 0, 0];       % Position [x, y, z] in meters

% Charge 2: position (m) and magnitude (C)
q2 = -2e-9;             % Charge magnitude [C]
pos2 = [1, 0, 0];   % Position [x, y, z] in meters

% Point P where electric field is evaluated
P = [0, 1, 2];    % Point coordinates [x, y, z] in meters

%% Compute Electric Field at Point P
% Sum the contributions from both charges (superposition principle)
E1 = electricFieldCoulomb(k, q1, pos1, P);
E2 = electricFieldCoulomb(k, q2, pos2, P);
E_total = E1 + E2;

% Display results
fprintf('Electric field at point P = [%.3f, %.3f, %.3f] m:\n', P);
fprintf('  E1 (from q1) = [%.4e, %.4e, %.4e] N/C\n', E1);
fprintf('  E2 (from q2) = [%.4e, %.4e, %.4e] N/C\n', E2);
fprintf('  E_total      = [%.4e, %.4e, %.4e] N/C\n', E_total);
fprintf('  |E_total|    = %.4e N/C\n', norm(E_total));

%% Visualize the Electric Field
plotElectricField(P, E_total, pos1, q1, pos2, q2);

%% ========================================================================
%  Function: electricFieldCoulomb
%  Computes the electric field vector at point P due to a single point charge
%  using Coulomb's law: E = k*q*(r_P - r_q)/|r_P - r_q|^3
%  ========================================================================
function E = electricFieldCoulomb(k, q, pos_q, P)
    % k     : Coulomb's constant [N·m²/C²]
    % q     : charge magnitude [C]
    % pos_q : charge position [x, y, z] in meters
    % P     : observation point [x, y, z] in meters
    
    % Vector from charge to observation point
    r_vec = P - pos_q;
    
    % Distance between charge and observation point
    r = norm(r_vec);
    
    % Avoid division by zero (singularity at charge location)
    if r < 1e-12
        error('Observation point coincides with charge location.');
    end
    
    % Coulomb's law for electric field vector
    E = k * q * r_vec / r^3;
end

%% ========================================================================
%  Function: plotElectricField
%  Visualizes the electric field vector at point P along with the two
%  charges using a 3D quiver plot.
%  ========================================================================
function plotElectricField(P, E, pos1, q1, pos2, q2)
    % P    : observation point [x, y, z]
    % E    : electric field vector at P [Ex, Ey, Ez]
    % pos1 : position of charge 1
    % q1   : magnitude of charge 1
    % pos2 : position of charge 2
    % q2   : magnitude of charge 2
    
    figure('Color', 'w');
    hold on; grid on; box on;
    
    % --- Plot point P ---
    plot3(P(1), P(2), P(3), 'ko', 'MarkerSize', 10, ...
          'MarkerFaceColor', 'k');
    
    % --- Plot the charges with color depending on sign ---
    if q1 >= 0
        plot3(pos1(1), pos1(2), pos1(3), 'r^', 'MarkerSize', 12, ...
              'MarkerFaceColor', 'r');
    else
        plot3(pos1(1), pos1(2), pos1(3), 'bv', 'MarkerSize', 12, ...
              'MarkerFaceColor', 'b');
    end
    
    if q2 >= 0
        plot3(pos2(1), pos2(2), pos2(3), 'r^', 'MarkerSize', 12, ...
              'MarkerFaceColor', 'r');
    else
        plot3(pos2(1), pos2(2), pos2(3), 'bv', 'MarkerSize', 12, ...
              'MarkerFaceColor', 'b');
    end
    
    % --- Plot electric field vector using quiver3 ---
    % Scale the arrow length for visibility (auto-scaling based on magnitude)
    arrow_scale = 0.3 / max(norm(E), eps);
    quiver3(P(1), P(2), P(3), ...
            E(1)*arrow_scale, E(2)*arrow_scale, E(3)*arrow_scale, ...
            0, 'Color', [0 0.6 0], 'LineWidth', 2, 'MaxHeadSize', 0.5);
    
    % --- Labels, title, legend ---
    xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
    title('Electric Field at Point P due to Two Point Charges');
    legend('Point P', 'Positive charge', 'Negative charge', ...
           'E at P', 'Location', 'best');
    
    % Set equal aspect ratio for accurate 3D perception
    axis equal;
    view(45, 25);
    hold off;
end