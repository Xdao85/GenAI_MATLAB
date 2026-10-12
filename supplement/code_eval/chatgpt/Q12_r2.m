%% main.m
% Electric Field Due to Two Point Charges
%
% This script calculates the electric field vector E at a point P in
% 3D space due to two point charges and visualizes the resulting field
% vector using a 3D quiver plot.
%
% Coulomb's law:
%
%   E_i = (1 / (4*pi*epsilon0)) * q_i * (r - r_i) / |r - r_i|^3
%
% where:
%   q_i  = charge magnitude (C)
%   r    = observation point P = [Px, Py, Pz] (m)
%   r_i  = position of charge i (m)
%   epsilon0 = permittivity of free space (F/m)
%
% The total electric field is obtained by superposition:
%
%   E_total = E_1 + E_2

clear;
clc;
close all;

%% 1. Define physical constants
epsilon0 = 8.854187817e-12;   % Permittivity of free space (F/m)
k = 1 / (4*pi*epsilon0);      % Coulomb constant (N*m^2/C^2)

%% 2. Define observation point P
% Coordinates of point P in meters
P = [0, 1, 2];

%% 3. Define the two point charges
% Charge magnitudes in Coulombs
q1 = 2e-9;                    % Charge 1: +5 nC
q2 = -2e-9;                   % Charge 2: -3 nC

% Positions of the charges in meters
r1 = [-1, 0, 0];               % Charge 1 position
r2 = [1, 0, 0];               % Charge 2 position

%% 4. Calculate the electric field
% Calculate the electric field at P due to each charge and their total.
E1 = electricFieldPointCharge(P, r1, q1, k);
E2 = electricFieldPointCharge(P, r2, q2, k);

% Principle of superposition:
E_total = E1 + E2;

%% 5. Display the results
fprintf('Electric field due to Charge 1:\n');
fprintf('E1 = [%.4e, %.4e, %.4e] N/C\n\n', E1);

fprintf('Electric field due to Charge 2:\n');
fprintf('E2 = [%.4e, %.4e, %.4e] N/C\n\n', E2);

fprintf('Total electric field at P:\n');
fprintf('E  = [%.4e, %.4e, %.4e] N/C\n', E_total);

fprintf('Magnitude of E = %.4e N/C\n', norm(E_total));

%% 6. Visualize the electric field vector
plotElectricField(P, E_total, r1, r2);


%% ========================================================================
% FUNCTION 1: Calculate electric field due to a single point charge
% ========================================================================
function E = electricFieldPointCharge(P, chargePosition, q, k)
% electricFieldPointCharge calculates the electric field produced by
% one point charge at observation point P.
%
% INPUTS:
%   P               - Observation point [Px, Py, Pz] in meters
%   chargePosition  - Position of point charge [x, y, z] in meters
%   q               - Charge magnitude in Coulombs
%   k               - Coulomb constant (N*m^2/C^2)
%
% OUTPUT:
%   E               - Electric field vector [Ex, Ey, Ez] in N/C
%
% Mathematical formulation:
%
%   R = P - r_q
%
%   E = k*q*R / |R|^3
%
% The vector R points from the charge toward the observation point.

    % Vector from charge to observation point
    R = P - chargePosition;

    % Distance between charge and observation point
    R_mag = norm(R);

    % Prevent division by zero if P is exactly at the charge location
    if R_mag == 0
        error('Observation point P cannot be located at the charge position.');
    end

    % Coulomb's law in vector form
    E = k * q * R / R_mag^3;
end


%% ========================================================================
% FUNCTION 2: Visualize the electric field using quiver3
% ========================================================================
function plotElectricField(P, E, r1, r2)
% plotElectricField creates a 3D quiver plot showing the electric field
% vector at point P.
%
% INPUTS:
%   P  - Observation point [Px, Py, Pz]
%   E  - Electric field vector [Ex, Ey, Ez]
%   r1 - Position of charge 1
%   r2 - Position of charge 2
%
% The MATLAB function quiver3 is used to draw the vector:
%
%   P --> P + E
%
% Since electric-field magnitudes can be very large, the vector is
% normalized for visualization while the actual numerical value of E
% remains unchanged.

    figure;

    % Plot the two point charges
    plot3(r1(1), r1(2), r1(3), 'ro', ...
        'MarkerSize', 10, 'MarkerFaceColor', 'r');
    hold on;

    plot3(r2(1), r2(2), r2(3), 'bo', ...
        'MarkerSize', 10, 'MarkerFaceColor', 'b');

    % Plot observation point P
    plot3(P(1), P(2), P(3), 'ko', ...
        'MarkerSize', 8, 'MarkerFaceColor', 'k');

    % Normalize E for a visually meaningful arrow length
    E_magnitude = norm(E);

    if E_magnitude > 0
        E_plot = E / E_magnitude;
    else
        E_plot = [0, 0, 0];
    end

    % Scale factor controls the displayed arrow length
    arrowScale = 1.5;

    % Plot electric field vector using quiver3
    quiver3(P(1), P(2), P(3), ...
            arrowScale*E_plot(1), ...
            arrowScale*E_plot(2), ...
            arrowScale*E_plot(3), ...
            0, 'LineWidth', 2);

    % Labels
    text(r1(1), r1(2), r1(3), '  q_1', 'FontSize', 12);
    text(r2(1), r2(2), r2(3), '  q_2', 'FontSize', 12);
    text(P(1), P(2), P(3), '  P', 'FontSize', 12);

    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');

    title('Electric Field Vector at Point P');

    legend('Charge q_1', 'Charge q_2', 'Point P', ...
           'Electric Field E', 'Location', 'best');

    grid on;
    axis equal;
    view(3);

    hold off;
end