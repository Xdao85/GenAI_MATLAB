%% Main Script: Electric Field Computation and Visualization
% This script computes the electric field at a point P due to two point charges
% and visualizes the result using a 3D quiver plot.

clear; clc; close all;

%% Define Problem Parameters
% Position of point P where we want to compute the electric field (in meters)
P = [0, 1, 2];  % [Px, Py, Pz]

% Define the two point charges
% Charge 1: position [x, y, z] in meters, magnitude in Coulombs
q1_pos = [-1, 0, 0];
q1_mag = 2e-9;  % 1 nC

% Charge 2: position [x, y, z] in meters, magnitude in Coulombs
q2_pos = [1, 0, 0];
q2_mag = -2e-9;  % -1 nC

% Physical constant: Coulomb's constant (N·m²/C²)
k = 8.9875517873681764e9;

%% Compute Electric Field
% Compute E-field contribution from charge 1
E1 = computeElectricField(P, q1_pos, q1_mag, k);

% Compute E-field contribution from charge 2
E2 = computeElectricField(P, q2_pos, q2_mag, k);

% Total electric field at point P (superposition principle)
E_total = E1 + E2;

% Display results
fprintf('Electric Field at P = [%.2f, %.2f, %.2f]:\n', P(1), P(2), P(3));
fprintf('  E1 (from q1)     = [%.3e, %.3e, %.3e] N/C\n', E1(1), E1(2), E1(3));
fprintf('  E2 (from q2)     = [%.3e, %.3e, %.3e] N/C\n', E2(1), E2(2), E2(3));
fprintf('  E_total          = [%.3e, %.3e, %.3e] N/C\n', E_total(1), E_total(2), E_total(3));
fprintf('  |E_total|        = %.3e N/C\n', norm(E_total));

%% Visualization
% Call the visualization function to plot the charges and electric field
visualizeElectricField(P, E_total, q1_pos, q1_mag, q2_pos, q2_mag);


%% ========================================================================
%  Function: computeElectricField
%  ------------------------------------------------------------------------
%  Computes the electric field vector at a point P due to a point charge.
%
%  Mathematical formulation (Coulomb's Law):
%     E = k * q * (r_P - r_q) / |r_P - r_q|^3
%  where:
%     k   = Coulomb's constant (N·m²/C²)
%     q   = charge magnitude (C)
%     r_P = position vector of the observation point P
%     r_q = position vector of the charge
%
%  Inputs:
%     P      - [1x3] observation point position [x, y, z] (m)
%     q_pos  - [1x3] charge position [x, y, z] (m)
%     q_mag  - scalar charge magnitude (C)
%     k      - Coulomb's constant (N·m²/C²)
%
%  Output:
%     E      - [1x3] electric field vector at P (N/C)
%% ========================================================================
function E = computeElectricField(P, q_pos, q_mag, k)
    % Vector from charge to observation point
    r_vec = P - q_pos;
    
    % Distance between charge and observation point
    r_mag = norm(r_vec);
    
    % Guard against division by zero (observation point at charge location)
    if r_mag < eps
        error('Observation point coincides with charge location. Field is undefined.');
    end
    
    % Coulomb's law: E = k * q * r_hat / r^2 = k * q * r_vec / r^3
    E = k * q_mag * r_vec / r_mag^3;
end


%% ========================================================================
%  Function: visualizeElectricField
%  ------------------------------------------------------------------------
%  Visualizes the point charges and the electric field vector at point P
%  using a 3D quiver plot.
%
%  Inputs:
%     P        - [1x3] observation point position
%     E_total  - [1x3] total electric field vector at P
%     q1_pos   - [1x3] position of charge 1
%     q1_mag   - scalar magnitude of charge 1
%     q2_pos   - [1x3] position of charge 2
%     q2_mag   - scalar magnitude of charge 2
%% ========================================================================
function visualizeElectricField(P, E_total, q1_pos, q1_mag, q2_pos, q2_mag)
    figure('Color', 'w', 'Position', [100 100 900 700]);
    hold on; grid on; box on;
    
    % --- Plot the two point charges as colored spheres ---
    % Positive charge: red, Negative charge: blue
    scatter3(q1_pos(1), q1_pos(2), q1_pos(3), 200, ...
             getChargeColor(q1_mag), 'filled', ...
             'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    scatter3(q2_pos(1), q2_pos(2), q2_pos(3), 200, ...
             getChargeColor(q2_mag), 'filled', ...
             'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    
    % Label the charges
    text(q1_pos(1), q1_pos(2), q1_pos(3)+0.15, ...
         sprintf('q_1 = %.1f nC', q1_mag*1e9), ...
         'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(q2_pos(1), q2_pos(2), q2_pos(3)+0.15, ...
         sprintf('q_2 = %.1f nC', q2_mag*1e9), ...
         'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % --- Plot the observation point P ---
    plot3(P(1), P(2), P(3), 'ks', 'MarkerSize', 10, ...
          'MarkerFaceColor', 'g', 'LineWidth', 1.5);
    text(P(1)+0.1, P(2), P(3)+0.1, 'P', ...
         'FontSize', 12, 'FontWeight', 'bold', 'Color', 'g');
    
    % --- Plot the electric field vector with quiver3 ---
    % Scale factor chosen so the arrow is visible in the plot
    E_mag = norm(E_total);
    if E_mag > 0
        scaleFactor = 0.3 / E_mag;   % Scale so arrow has length ~0.3 units
    else
        scaleFactor = 0;
    end
    
    quiver3(P(1), P(2), P(3), ...
            E_total(1)*scaleFactor, E_total(2)*scaleFactor, E_total(3)*scaleFactor, ...
            0, 'Color', [0.85 0.33 0.10], 'LineWidth', 2.5, ...
            'MaxHeadSize', 0.8);
    
    % --- Add a legend and labels ---
    % Create dummy handles for a clean legend
    h1 = plot3(nan, nan, nan, 'o', 'MarkerSize', 10, ...
               'MarkerFaceColor', getChargeColor(q1_mag), ...
               'MarkerEdgeColor', 'k');
    h2 = plot3(nan, nan, nan, 'o', 'MarkerSize', 10, ...
               'MarkerFaceColor', getChargeColor(q2_mag), ...
               'MarkerEdgeColor', 'k');
    h3 = plot3(nan, nan, nan, 's', 'MarkerSize', 10, ...
               'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    h4 = quiver3(nan, nan, nan, nan, nan, nan, 0, ...
                 'Color', [0.85 0.33 0.10], 'LineWidth', 2.5);
    
    legend([h1, h2, h3, h4], ...
           {sprintf('q_1 = %.1f nC', q1_mag*1e9), ...
            sprintf('q_2 = %.1f nC', q2_mag*1e9), ...
            'Observation Point P', ...
            sprintf('E_{total} (|E| = %.2e N/C)', E_mag)}, ...
           'Location', 'northeast', 'FontSize', 10);
    
    % --- Formatting ---
    xlabel('x (m)', 'FontSize', 12);
    ylabel('y (m)', 'FontSize', 12);
    zlabel('z (m)', 'FontSize', 12);
    title('Electric Field at Point P due to Two Point Charges', ...
          'FontSize', 13, 'FontWeight', 'bold');
    
    % Adjust axis limits to encompass all elements
    all_pts = [P; q1_pos; q2_pos];
    margin = 0.6;
    xlim([min(all_pts(:,1))-margin, max(all_pts(:,1))+margin]);
    ylim([min(all_pts(:,2))-margin, max(all_pts(:,2))+margin]);
    zlim([min(all_pts(:,3))-margin, max(all_pts(:,3))+margin]);
    
    view(45, 25);   % Set a nice 3D viewing angle
    axis equal;
    hold off;
    % Thêm 
    view(3)
    view(120,35)
end


%% ========================================================================
%  Helper Function: getChargeColor
%  ------------------------------------------------------------------------
%  Returns a color for a charge marker based on its sign.
%  Positive charge -> red, Negative charge -> blue.
%% ========================================================================
function c = getChargeColor(q)
    if q >= 0
        c = [0.9 0.2 0.2];   % Red for positive
    else
        c = [0.2 0.4 0.9];   % Blue for negative
    end
end