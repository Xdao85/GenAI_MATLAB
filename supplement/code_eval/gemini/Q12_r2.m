% =========================================================================
% Main Script Execution: 3D Electric Field Calculation & Visualization
% =========================================================================
clc; clear; close all;

% 1. Physical Constants and Input Definitions
k_e = 8.98755e9; % Coulomb's constant (N*m^2/C^2)

% Charge magnitudes in Coulombs (e.g., q1 = +2 nC, q2 = -2 nC)
q = [2e-9, -2e-9]; 

% Charge positions in 3D space (meters): [x, y, z]
% Row 1: Charge 1 position, Row 2: Charge 2 position
q_pos = [-1, 0, 0; 1, 0, 0]; 

% Observation point P(Px, Py, Pz) in meters
P = [0, 1, 2];

% 2. Calculate Electric Field Vector
E_total = computeElectricField(P, q, q_pos, k_e);

% Print numeric output to Command Window
fprintf('--------------------------------------------------\n');
fprintf('Observation Point P: [%.3f, %.3f, %.3f] m\n', P(1), P(2), P(3));
fprintf('Electric Field E   : [%.3e, %.3e, %.3e] N/C\n', E_total(1), E_total(2), E_total(3));
fprintf('E-field Magnitude  : %.3e N/C\n', norm(E_total));
fprintf('--------------------------------------------------\n');

% 3. Visualize System and Electric Field Vector
plotElectricField(P, E_total, q, q_pos);


% =========================================================================
% Local Function: Electric Field Calculation (Coulomb's Law + Superposition)
% =========================================================================
function E = computeElectricField(P, q, q_pos, k_e)
    % COMPUTEELECTRICFIELD Calculates total electric field vector at point P.
    % Inputs:
    %   P     - [1x3] vector for observation point (m)
    %   q     - [1xN] vector of charge magnitudes (C)
    %   q_pos - [Nx3] matrix of charge position vectors (m)
    %   k_e   - Coulomb constant (N*m^2/C^2)
    % Output:
    %   E     - [1x3] total electric field vector (N/C)
    
    if nargin < 4
        k_e = 8.98755e9; % Default to vacuum permittivity constant
    end

    E = [0, 0, 0]; % Initialize field components [Ex, Ey, Ez]
    num_charges = length(q);

    for i = 1:num_charges
        % Displacement vector pointing from charge_i to observation point P
        r_vec = P - q_pos(i, :);
        
        % Euclidean distance |r|
        r_mag = norm(r_vec);
        
        % Singularity check
        if r_mag == 0
            error('Calculation error: Point P coincides with charge position %d.', i);
        end
        
        % Vector electric field contribution: E_i = (k_e * q_i / |r|^3) * r_vec
        E_i = (k_e * q(i) / (r_mag^3)) * r_vec;
        
        % Apply superposition principle
        E = E + E_i;
    end
end


% =========================================================================
% Local Function: 3D Visualization using quiver3
% =========================================================================
function plotElectricField(P, E, q, q_pos)
    % PLOTELECTRICFIELD Plots charges, point P, and E-field vector.
    
    figure('Color', 'w', 'Name', '3D Electric Field Vector');
    hold on; grid on; box on;
    
    % Plot point charges (Red for positive, Blue for negative)
    num_charges = length(q);
    for i = 1:num_charges
        if q(i) > 0
            scatter3(q_pos(i,1), q_pos(i,2), q_pos(i,3), 150, 'r', 'filled', ...
                'DisplayName', sprintf('q_{%d} (+%.1fnC)', i, q(i)*1e9));
        elseif q(i) < 0
            scatter3(q_pos(i,1), q_pos(i,2), q_pos(i,3), 150, 'b', 'filled', ...
                'DisplayName', sprintf('q_{%d} (%.1fnC)', i, q(i)*1e9));
        else
            scatter3(q_pos(i,1), q_pos(i,2), q_pos(i,3), 150, 'k', 'filled', ...
                'DisplayName', sprintf('q_{%d} (Neutral)', i));
        end
    end
    
    % Plot observation point P
    scatter3(P(1), P(2), P(3), 90, 'k', 'square', 'filled', ...
        'DisplayName', sprintf('Point P (%.2f, %.2f, %.2f)', P(1), P(2), P(3)));
    
    % Draw Electric Field Vector at Point P using quiver3
    % The scale factor 0.5 scales vector length visually without altering actual data
    quiver3(P(1), P(2), P(3), E(1), E(2), E(3), 0.5, ...
        'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2.5, ...
        'MaxHeadSize', 0.4, 'DisplayName', 'Electric Field \mathbf{E}');
    
    % Axes labeling and scene formatting
    xlabel('X Position (m)');
    ylabel('Y Position (m)');
    zlabel('Z Position (m)');
    title('3D Electric Field Vector at Point P Due to Point Charges');
    legend('Location', 'northeast');
    axis equal;
    view(3); % Set standard 3D perspective
    rotate3d on;
    hold off;
end
