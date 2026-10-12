%% ========================================================================
%  MAIN SCRIPT: Compute and visualize the electric field at point P
%  due to two point charges in 3D space.
%
%  Physical/mathematical formulation:
%     Coulomb's Law:  E = k * q / r^2 * r_hat
%     where  r_vec = P - Q_position,  r = |r_vec|,  r_hat = r_vec / r
%     Total field (superposition): E_total = E1 + E2
%
%     k = 1/(4*pi*eps0)  ~= 8.9875e9  N·m^2/C^2
% =========================================================================

clear; clc; close all;

%% -------- 1. Define problem parameters ---------------------------------
k = 8.9875517923e9;              % Coulomb constant [N·m^2/C^2]

% Positions of the two charges [x, y, z] (meters)
pos1 = [-1, 0, 0];
pos2 = [1, 0, 0];

% Charge magnitudes (Coulombs). Sign matters: +/-
q1 =  2e-9;     % +1 µC
q2 = -2e-9;     % -1 µC

% Observation point P where we evaluate the field (meters)
P = [0, 1, 2];

%% -------- 2. Compute total electric field at P -------------------------
E1 = electricField(k, q1, pos1, P);   % Field due to charge 1
E2 = electricField(k, q2, pos2, P);   % Field due to charge 2
E_total = E1 + E2;                    % Superposition principle

fprintf('Electric field due to q1 : [%10.4e, %10.4e, %10.4e] N/C\n', E1);
fprintf('Electric field due to q2 : [%10.4e, %10.4e, %10.4e] N/C\n', E2);
fprintf('Total electric field at P: [%10.4e, %10.4e, %10.4e] N/C\n', E_total);
fprintf('Magnitude |E| = %.4e N/C\n', norm(E_total));

%% -------- 3. Visualization ---------------------------------------------
plotEField(P, E1, E2, E_total, pos1, pos2);


%% ========================================================================
%  FUNCTION: electricField
%  Computes E vector at observation point P due to a point charge q at qpos.
%  E = k * q * (P - qpos) / |P - qpos|^3
% =========================================================================
function E = electricField(k, q, qpos, P)
    % Vector from charge to observation point
    r_vec = P - qpos;
    r     = norm(r_vec);

    if r == 0
        error('Observation point coincides with charge location.');
    end

    % Coulomb's law (vector form)
    E = k * q * r_vec / r^3;
end


%% ========================================================================
%  FUNCTION: plotEField
%  Visualizes the two source charges and the electric-field vectors at P.
%  Uses quiver3 to draw arrows for E1, E2 and the total field.
% =========================================================================
function plotEField(P, E1, E2, E_total, pos1, pos2)
    figure('Color','w'); hold on; grid on; axis equal;
    xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
    title('Electric field at point P due to two point charges');
    view(45, 25);

    % --- Plot charge locations ---
    plot3(pos1(1), pos1(2), pos1(3), 'ro', ...
          'MarkerFaceColor','r', 'MarkerSize',10);
    plot3(pos2(1), pos2(2), pos2(3), 'bo', ...
          'MarkerFaceColor','b', 'MarkerSize',10);
    plot3(P(1), P(2), P(3), 'ks', ...
          'MarkerFaceColor','y', 'MarkerSize',10);

    % Text labels
    text(pos1(1), pos1(2), pos1(3), '  q_1', 'Color','r', ...
         'FontWeight','bold');
    text(pos2(1), pos2(2), pos2(3), '  q_2', 'Color','b', ...
         'FontWeight','bold');
    text(P(1),   P(2),   P(3),   '  P',   'Color','k', ...
         'FontWeight','bold');

    % --- Scale arrows so they are visible on the geometry plot ---
    %  Normalize each arrow to a fixed length for readability.
    arrowLen = 0.4;   % desired display length (m)
    s1 = arrowLen / norm(E1);
    s2 = arrowLen / norm(E2);
    sT = arrowLen / norm(E_total);

    % --- quiver3 plots ---
    quiver3(P(1), P(2), P(3), s1*E1(1), s1*E1(2), s1*E1(3), ...
            0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.8);   % E1
    quiver3(P(1), P(2), P(3), s2*E2(1), s2*E2(2), s2*E2(3), ...
            0, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.8);   % E2
    quiver3(P(1), P(2), P(3), sT*E_total(1), sT*E_total(2), sT*E_total(3), ...
            0, 'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.8); % E_total

    % --- Legend (dummy plots for arrow colors) ---
    h1 = plot3(NaN,NaN,NaN,'r-','LineWidth',2);
    h2 = plot3(NaN,NaN,NaN,'b-','LineWidth',2);
    h3 = plot3(NaN,NaN,NaN,'k-','LineWidth',2.5);
    legend([h1 h2 h3], {'E_1 (from q_1)','E_2 (from q_2)','E_{total}'}, ...
           'Location','best');

    hold off;
end