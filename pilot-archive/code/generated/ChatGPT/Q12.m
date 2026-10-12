%% Q1: Electric Field Due to Two Point Charges
% This main script:
% 1. Defines the observation point P.
% 2. Defines the positions and magnitudes of two point charges.
% 3. Calculates the total electric field using Coulomb's law.
% 4. Displays the electric field vector.
% 5. Visualizes the vector using a 3D quiver plot.

clear;
clc;
close all;

%% ------------------------------------------------------------
% 1. Physical constant
% -------------------------------------------------------------
epsilon0 = 8.854187817e-12;       % Permittivity of free space [F/m]
k = 1/(4*pi*epsilon0);             % Coulomb's constant [N*m^2/C^2]

%% ------------------------------------------------------------
% 2. Define observation point P
% -------------------------------------------------------------
P = [0, 1, 2];                     % P = (Px, Py, Pz) [m]

%% ------------------------------------------------------------
% 3. Define the two point charges
% -------------------------------------------------------------
% Charge 1
q1 = 2e-9;                          % Charge magnitude [C]
r1 = [-1, 0, 0];                    % Position of q1 [m]

% Charge 2
q2 = -2e-9;                         % Charge magnitude [C]
r2 = [1, 0, 0];                    % Position of q2 [m]

%% ------------------------------------------------------------
% 4. Calculate electric field due to each charge
% -------------------------------------------------------------
E1 = electricFieldPointCharge(P, q1, r1, k);
E2 = electricFieldPointCharge(P, q2, r2, k);

%% ------------------------------------------------------------
% 5. Calculate total electric field
% -------------------------------------------------------------
E_total = E1 + E2;

%% ------------------------------------------------------------
% 6. Display results
% -------------------------------------------------------------
fprintf('Observation point P = (%.2f, %.2f, %.2f) m\n', ...
        P(1), P(2), P(3));

fprintf('\nElectric field due to Charge 1:\n');
fprintf('E1 = [%.4e, %.4e, %.4e] N/C\n', ...
        E1(1), E1(2), E1(3));

fprintf('\nElectric field due to Charge 2:\n');
fprintf('E2 = [%.4e, %.4e, %.4e] N/C\n', ...
        E2(1), E2(2), E2(3));

fprintf('\nTotal electric field:\n');
fprintf('E  = [%.4e, %.4e, %.4e] N/C\n', ...
        E_total(1), E_total(2), E_total(3));

% Magnitude of the total electric field
E_magnitude = norm(E_total);

fprintf('|E| = %.4e N/C\n', E_magnitude);

%% ------------------------------------------------------------
% 7. Visualize the electric field vector
% -------------------------------------------------------------
plotElectricField(P, E_total, r1, q1, r2, q2);
