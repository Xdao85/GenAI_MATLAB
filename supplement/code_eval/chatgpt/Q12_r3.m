%% Electric Field Due to Two Point Charges
% This script calculates and visualizes the electric field vector E
% at a point P(x,y,z) due to two point charges in 3D space.
%
% Coulomb's law:
%
%       E = (1/(4*pi*epsilon0)) * q * R / |R|^3
%
% where:
%   q       = point charge (C)
%   R       = vector from the charge to point P (m)
%   |R|     = distance between the charge and point P (m)
%   epsilon0 = permittivity of free space (F/m)
%
% The total electric field is the vector sum:
%
%       E_total = E1 + E2
%
% The field vector at P is displayed using MATLAB's quiver3 function.

clear;
clc;
close all;

%% ------------------------------------------------------------------------
%  MAIN SCRIPT
%  ------------------------------------------------------------------------

% Physical constant: permittivity of free space
epsilon0 = 8.854187817e-12;       % F/m

% Coulomb's constant
k = 1 / (4*pi*epsilon0);          % N*m^2/C^2

% -------------------------------------------------------------------------
% Define the two point charges
% -------------------------------------------------------------------------

% Charge magnitudes in Coulombs
q1 = 2e-9;                        % Charge 1: +2 nC
q2 = -2e-9;                       % Charge 2: -3 nC

% Positions of the charges [x, y, z] in meters
r1 = [-1, 0, 0];
r2 = [1, 0, 0];

% -------------------------------------------------------------------------
% Define the observation point P
% -------------------------------------------------------------------------

P = [0, 1, 2];                    % Point P = (1, 1, 2) m

% -------------------------------------------------------------------------
% Calculate the electric field due to each charge
% -------------------------------------------------------------------------

E1 = electricFieldPointCharge(P, r1, q1, k);
E2 = electricFieldPointCharge(P, r2, q2, k);

% Total electric field by superposition
E_total = E1 + E2;

% Display the results
fprintf('Electric field due to Charge 1:\n');
fprintf('E1 = [%.4e, %.4e, %.4e] N/C\n\n', E1);

fprintf('Electric field due to Charge 2:\n');
fprintf('E2 = [%.4e, %.4e, %.4e] N/C\n\n', E2);

fprintf('Total electric field at P:\n');
fprintf('E = [%.4e, %.4e, %.4e] N/C\n', E_total);

fprintf('Magnitude of total electric field:\n');
fprintf('|E| = %.4e N/C\n', norm(E_total));

% -------------------------------------------------------------------------
% Visualize the electric field vector
% -------------------------------------------------------------------------

plotElectricField(P, E_total, r1, r2, q1, q2);


%% =========================================================================
%  FUNCTION 1: ELECTRIC FIELD CALCULATION
%  =========================================================================
function E = electricFieldPointCharge(P, chargePosition, q, k)
% electricFieldPointCharge
%
% Calculates the electric field vector at point P due to a single
% point charge using Coulomb's law.
%
% INPUTS:
%   P               - Observation point [x, y, z] (m)
%   chargePosition  - Position of the point charge [x, y, z] (m)
%   q               - Charge magnitude (C)
%   k               - Coulomb's constant (N*m^2/C^2)
%
% OUTPUT:
%   E               - Electric field vector [Ex, Ey, Ez] (N/C)
%
% Mathematical formulation:
%
%       R = P - chargePosition
%
%       r = |R|
%
%       E = k*q*R/r^3
%
% This formulation automatically gives the correct direction:
%   - For q > 0, E points away from the charge.
%   - For q < 0, E points toward the charge.

    % Vector from the charge to the observation point
    R = P - chargePosition;

    % Distance between the charge and observation point
    r = norm(R);

    % Avoid division by zero if P is exactly at the charge location
    if r == 0
        error('Observation point P cannot be located at the charge position.');
    end

    % Coulomb's law in vector form
    E = k * q * R / r^3;
end


%% =========================================================================
%  FUNCTION 2: ELECTRIC FIELD VISUALIZATION
%  =========================================================================
function plotElectricField(P, E, r1, r2, q1, q2)
% plotElectricField
%
% Plots the electric field vector at point P using MATLAB's quiver3.
%
% INPUTS:
%   P   - Observation point [x, y, z] (m)
%   E   - Electric field vector [Ex, Ey, Ez] (N/C)
%   r1  - Position of charge 1 [x, y, z] (m)
%   r2  - Position of charge 2 [x, y, z] (m)
%   q1  - Magnitude of charge 1 (C)
%   q2  - Magnitude of charge 2 (C)

    figure;

    hold on;
    grid on;
    axis equal;

    % ---------------------------------------------------------------------
    % Plot the two point charges
    % ---------------------------------------------------------------------

    % Charge 1
    if q1 > 0
        plot3(r1(1), r1(2), r1(3), 'ro', ...
            'MarkerSize', 10, 'MarkerFaceColor', 'r');
    else
        plot3(r1(1), r1(2), r1(3), 'bo', ...
            'MarkerSize', 10, 'MarkerFaceColor', 'b');
    end

    % Charge 2
    if q2 > 0
        plot3(r2(1), r2(2), r2(3), 'ro', ...
            'MarkerSize', 10, 'MarkerFaceColor', 'r');
    else
        plot3(r2(1), r2(2), r2(3), 'bo', ...
            'MarkerSize', 10, 'MarkerFaceColor', 'b');
    end

    % ---------------------------------------------------------------------
    % Plot observation point P
    % ---------------------------------------------------------------------

    plot3(P(1), P(2), P(3), 'ks', ...
        'MarkerSize', 10, 'MarkerFaceColor', 'y');

    % ---------------------------------------------------------------------
    % Plot the electric field vector using quiver3
    % ---------------------------------------------------------------------

    % quiver3(x, y, z, u, v, w)
    %
    % The arrow starts at P and has components:
    %   E_x = E(1)
    %   E_y = E(2)
    %   E_z = E(3)
    %
    % AutoScaleFactor is used only to make the arrow visually suitable
    % for the plot. It does not change the calculated electric field.

    quiver3(P(1), P(2), P(3), ...
            E(1), E(2), E(3), ...
            0.5, 'LineWidth', 2, 'MaxHeadSize', 0.5);

    % ---------------------------------------------------------------------
    % Add labels and formatting
    % ---------------------------------------------------------------------

    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');

    title('Electric Field at Point P Due to Two Point Charges');

    legend('Charge 1', 'Charge 2', 'Point P', 'Electric Field E', ...
           'Location', 'best');

    view(3);
    hold off;
end