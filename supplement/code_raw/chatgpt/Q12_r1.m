%% Electric Field Due to Two Point Charges
% This script calculates and plots the electric field vector at a point P
% in 3D space due to two point charges.
%
% Coulomb's law:
%
%       E = (1 / (4*pi*epsilon0)) * (q / r^3) * R
%
% where:
%   q       = point charge (C)
%   R       = vector from the charge to point P (m)
%   r       = magnitude of R (m)
%   epsilon0 = permittivity of free space (F/m)
%
% The total electric field is the vector sum of the fields produced by
% the two charges:
%
%       E_total = E1 + E2

clear;
clc;
close all;

%% Constants
% Permittivity of free space
epsilon0 = 8.854187817e-12;       % F/m

%% Define observation point P
% Coordinates of point P = [Px, Py, Pz] in meters
P = [2, 1, 1];

%% Define the two point charges
% Charge 1
q1 = 5e-9;                         % Coulombs
pos1 = [0, 0, 0];                  % [x, y, z] in meters

% Charge 2
q2 = -3e-9;                        % Coulombs
pos2 = [4, 2, 1];                  % [x, y, z] in meters

%% Calculate the electric field at P
% Calculate the field contribution from each charge and their total.
[E1, E2, E_total] = calculateElectricField(P, q1, pos1, q2, pos2, epsilon0);

%% Display the results
fprintf('Electric field due to Charge 1:\n');
fprintf('E1 = [%.4e, %.4e, %.4e] N/C\n\n', E1(1), E1(2), E1(3));

fprintf('Electric field due to Charge 2:\n');
fprintf('E2 = [%.4e, %.4e, %.4e] N/C\n\n', E2(1), E2(2), E2(3));

fprintf('Total electric field at P:\n');
fprintf('E  = [%.4e, %.4e, %.4e] N/C\n', ...
    E_total(1), E_total(2), E_total(3));

fprintf('Magnitude of E = %.4e N/C\n', norm(E_total));

%% Plot the electric field vector
plotElectricField(P, E_total, pos1, q1, pos2, q2);


%% ========================================================================
%  FUNCTION: calculateElectricField
%  ========================================================================
function [E1, E2, E_total] = calculateElectricField(P, q1, pos1, ...
                                                       q2, pos2, epsilon0)
% calculateElectricField calculates the electric field at point P due to
% two point charges using Coulomb's law.
%
% INPUTS:
%   P       - Observation point [Px Py Pz] (m)
%   q1      - Magnitude of charge 1 (C)
%   pos1    - Position of charge 1 [x y z] (m)
%   q2      - Magnitude of charge 2 (C)
%   pos2    - Position of charge 2 [x y z] (m)
%   epsilon0 - Permittivity of free space (F/m)
%
% OUTPUTS:
%   E1      - Electric field vector due to charge 1 (N/C)
%   E2      - Electric field vector due to charge 2 (N/C)
%   E_total - Total electric field vector (N/C)
%
% Mathematical formulation:
%
%   R = P - position_of_charge
%   r = |R|
%
%   E = (1/(4*pi*epsilon0)) * (q/r^3) * R
%
% The total field follows the principle of superposition:
%
%   E_total = E1 + E2

    % Vector from charge 1 to observation point P
    R1 = P - pos1;

    % Distance between charge 1 and P
    r1 = norm(R1);

    % Vector from charge 2 to observation point P
    R2 = P - pos2;

    % Distance between charge 2 and P
    r2 = norm(R2);

    % Prevent division by zero if P coincides with a charge
    if r1 == 0 || r2 == 0
        error('Observation point P cannot coincide with a point charge.');
    end

    % Coulomb constant
    k = 1 / (4 * pi * epsilon0);

    % Electric field due to charge 1
    E1 = k * q1 * R1 / r1^3;

    % Electric field due to charge 2
    E2 = k * q2 * R2 / r2^3;

    % Total electric field using superposition
    E_total = E1 + E2;
end


%% ========================================================================
%  FUNCTION: plotElectricField
%  ========================================================================
function plotElectricField(P, E, pos1, q1, pos2, q2)
% plotElectricField creates a 3D visualization of the electric field vector
% at point P using MATLAB's quiver3 function.
%
% INPUTS:
%   P    - Observation point [Px Py Pz] (m)
%   E    - Electric field vector [Ex Ey Ez] (N/C)
%   pos1 - Position of charge 1 [x y z] (m)
%   q1   - Charge 1 (C)
%   pos2 - Position of charge 2 [x y z] (m)
%   q2   - Charge 2 (C)

    figure;

    hold on;
    grid on;
    axis equal;

    %% Plot the two point charges
    % Positive and negative charges are represented by different markers.
    if q1 > 0
        plot3(pos1(1), pos1(2), pos1(3), 'ro', ...
            'MarkerSize', 10, 'MarkerFaceColor', 'r');
    else
        plot3(pos1(1), pos1(2), pos1(3), 'bo', ...
            'MarkerSize', 10, 'MarkerFaceColor', 'b');
    end

    if q2 > 0
        plot3(pos2(1), pos2(2), pos2(3), 'ro', ...
            'MarkerSize', 10, 'MarkerFaceColor', 'r');
    else
        plot3(pos2(1), pos2(2), pos2(3), 'bo', ...
            'MarkerSize', 10, 'MarkerFaceColor', 'b');
    end

    %% Plot point P
    plot3(P(1), P(2), P(3), 'ks', ...
        'MarkerSize', 8, 'MarkerFaceColor', 'y');

    %% Plot the electric field vector using quiver3
    %
    % quiver3(X,Y,Z,U,V,W) plots a vector starting at (X,Y,Z) with
    % components (U,V,W).
    %
    % The scaleFactor is chosen only for visualization. It does not
    % change the calculated electric field value.
    scaleFactor = 0.5;

    quiver3(P(1), P(2), P(3), ...
            scaleFactor * E(1), ...
            scaleFactor * E(2), ...
            scaleFactor * E(3), ...
            0, 'LineWidth', 2, 'MaxHeadSize', 0.5);

    %% Add labels and title
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');

    title('Electric Field at Point P Due to Two Point Charges');

    legend('Charge 1', 'Charge 2', 'Point P', 'Electric Field E', ...
           'Location', 'best');

    view(3);
    hold off;
end