%% MAIN SCRIPT: Electric Field Calculation and Visualization
% This script sets up charges, evaluates the total electric field at a 
% specified point P in 3D space, and plots the vector result.

clear; clc; close all;

% --- 1. DEFINE INPUT PARAMETERS ---
% Positions of point charges: [x, y, z] in meters
r1 = [-1, 0, 0];    % Position of Charge 1
r2 = [1, 0, 0];  % Position of Charge 2

% Charge values in Coulombs
q1 = 2e-9;         % +5 nC charge
q2 = -2e-9;        % -3 nC charge

% Observation point P: [Px, Py, Pz] in meters
rP = [0, 1, 2];    % Point P where E-field is evaluated

% --- 2. ELECTRIC FIELD CALCULATION ---
% Calculate individual electric fields from q1 and q2 at point P
E1 = calculateEField(q1, r1, rP);
E2 = calculateEField(q2, r2, rP);

% Superposition principle: Net Electric Field E_net = E1 + E2
E_net = E1 + E2;

% Display total electric field components and magnitude in Command Window
fprintf('--- Electric Field Results at Point P (%.2f, %.2f, %.2f) ---\n', rP(1), rP(2), rP(3));
fprintf('E_net Vector    : [%.3e, %.3e, %.3e] N/C\n', E_net(1), E_net(2), E_net(3));
fprintf('E_net Magnitude : %.3e N/C\n', norm(E_net));

% --- 3. VISUALIZATION ---
% Call visualization function to display 3D spatial setup and field vectors
plotEField3D(r1, q1, r2, q2, rP, E1, E2, E_net);


%% =========================================================================
%  HELPER FUNCTIONS
%  =========================================================================

function E = calculateEField(q, r_source, r_obs)
% CALCULATEEFIELD Computes electric field vector E at r_obs due to charge q at r_source.
%
% Mathematical Formulation (Coulomb's Law):
%   E = (1 / (4 * pi * epsilon_0)) * (q / |R|^2) * uR
%     = k_e * q * (r_obs - r_source) / |r_obs - r_source|^3
%
% Inputs:
%   q        - Charge magnitude in Coulombs (scalar)
%   r_source - Position vector of the charge [x, y, z] (1x3 vector)
%   r_obs    - Observation point vector [x, y, z] (1x3 vector)
%
% Output:
%   E        - Electric field vector [Ex, Ey, Ez] in N/C (1x3 vector)

    % Coulomb's Constant k_e = 1 / (4 * pi * epsilon_0) in N*m^2/C^2
    k_e = 8.9875517923e9; 

    % Displacement vector R from source charge to observation point
    R = r_obs - r_source;
    
    % Distance between source charge and observation point
    distance = norm(R);
    
    % Check to avoid division by zero if point P coincides with a charge position
    if distance == 0
        error('Observation point P cannot be at the exact same location as a point charge.');
    end
    
    % Electric field vector calculation
    E = (k_e * q / (distance^3)) * R;
end


function plotEField3D(r1, q1, r2, q2, rP, E1, E2, E_net)
% PLOTEFIELD3D Visualizes the point charges, observation point, and electric field vectors.
%
% Inputs:
%   r1, r2 - Positions of charges 1 and 2 [x,y,z]
%   q1, q2 - Magnitudes of charges 1 and 2
%   rP     - Position of point P [x,y,z]
%   E1, E2 - Individual electric field vectors at point P
%   E_net  - Total resultant electric field vector at point P

    figure('Name', '3D Electric Field Vector Plot', 'NumberTitle', 'off');
    hold on; grid on; axis equal;
    view(3); % Set 3D isometric perspective

    % --- Plot Point Charges ---
    % Plot Positive Charge (Red) or Negative Charge (Blue)
    if q1 >= 0, color1 = 'r'; else, color1 = 'b'; end
    if q2 >= 0, color2 = 'r'; else, color2 = 'b'; end

    plot3(r1(1), r1(2), r1(3), 'o', 'MarkerSize', 10, 'MarkerFaceColor', color1, ...
        'MarkerEdgeColor', 'k', 'DisplayName', sprintf('q1 = %.1f nC', q1*1e9));
    plot3(r2(1), r2(2), r2(3), 'o', 'MarkerSize', 10, 'MarkerFaceColor', color2, ...
        'MarkerEdgeColor', 'k', 'DisplayName', sprintf('q2 = %.1f nC', q2*1e9));

    % --- Plot Target Point P ---
    plot3(rP(1), rP(2), rP(3), 'k*', 'MarkerSize', 12, 'LineWidth', 1.5, ...
        'DisplayName', 'Target Point P');

    % --- Normalize Field Vectors for Clear Visualization ---
    % Since E-field magnitudes can be huge (e.g., 10^3 N/C), we normalize 
    % them to unit vectors and scale them visually so they fit nicely on the plot.
    scaleFactor = 1.5; % Physical length of the vector on the plot
    
    uE1 = (E1 / norm(E1)) * scaleFactor;
    uE2 = (E2 / norm(E2)) * scaleFactor;
    uE_net = (E_net / norm(E_net)) * scaleFactor;

    % --- Plot Electric Field Vectors using quiver3 ---
    % quiver3(X, Y, Z, U, V, W, scale): X,Y,Z = start point; U,V,W = vector components
    
    % Individual field from q1
    quiver3(rP(1), rP(2), rP(3), uE1(1), uE1(2), uE1(3), 0, ...
        'm--', 'LineWidth', 1.5, 'MaxHeadSize', 0.5, 'DisplayName', 'E1 (from q1)');
    
    % Individual field from q2
    quiver3(rP(1), rP(2), rP(3), uE2(1), uE2(2), uE2(3), 0, ...
        'c--', 'LineWidth', 1.5, 'MaxHeadSize', 0.5, 'DisplayName', 'E2 (from q2)');
    
    % Total net electric field E_net
    quiver3(rP(1), rP(2), rP(3), uE_net(1), uE_net(2), uE_net(3), 0, ...
        'g', 'LineWidth', 2.5, 'MaxHeadSize', 0.6, 'DisplayName', 'E_{net} (Total)');

    % --- Formatting and Labels ---
    xlabel('X Position (m)');
    ylabel('Y Position (m)');
    zlabel('Z Position (m)');
    title('3D Electric Field Vector at Point P');
    legend('Location', 'northeastoutside');
    rotate3d on; % Enable interactive rotation
    hold off;
end

% Thêm 
view(3)
view(120,35)