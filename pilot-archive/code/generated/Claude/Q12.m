%% ELECTRIC FIELD AT A POINT DUE TO TWO POINT CHARGES
% -------------------------------------------------------------------------
% Mathematical formulation (Coulomb's law + superposition principle):
%
%   Field of a single point charge q_i located at r_i, evaluated at P:
%
%       E_i = k * q_i * (P - r_i) / |P - r_i|^3
%
%   where k = 1/(4*pi*eps0) ~ 8.9875e9 N*m^2/C^2.
%   The direction of E_i is along the unit vector (P - r_i)/|P - r_i|
%   (away from a positive charge, toward a negative charge), and its
%   magnitude falls off as 1/r^2.
%
%   Total field (superposition):
%
%       E = E_1 + E_2
%
% NOTE: This file is a script with local functions. Local functions must
%       appear at the END of the file (MATLAB R2016b or newer).
% -------------------------------------------------------------------------

clear; clc; close all;

%% ------------------------------ MAIN SCRIPT -----------------------------

% ----- User inputs -------------------------------------------------------
% Charge magnitudes in Coulombs (sign matters: + repels, - attracts)
q1 =  2e-9;                 % Charge 1:  +2 uC
q2 = -2e-9;                 % Charge 2:  -3 uC

% Charge positions in meters, as [x y z] row vectors
r1 = [-1,  0,  0];          % Position of charge 1
r2 = [1,  0,  0];          % Position of charge 2

% Field point P = (Px, Py, Pz) in meters
Px = 0;  Py = 1;  Pz = 2;
P  = [Px, Py, Pz];

% ----- Computation -------------------------------------------------------
E = computeElectricField(P, [q1, q2], [r1; r2]);   % [Ex Ey Ez] in N/C

% ----- Report results in the command window ------------------------------
fprintf('Field point P  = (%.3f, %.3f, %.3f) m\n', P);
fprintf('E vector       = (%.4e, %.4e, %.4e) N/C\n', E);
fprintf('|E| magnitude  = %.4e N/C\n', norm(E));

% ----- Visualization -----------------------------------------------------
plotElectricField(P, E, [q1, q2], [r1; r2]);


%% ------------------------------ FUNCTIONS -------------------------------

function E = computeElectricField(P, q, R)
% COMPUTEELECTRICFIELD  Net electric field at P from N point charges.
%
%   E = computeElectricField(P, q, R)
%
%   Inputs:
%     P : 1x3 vector [Px Py Pz]   - field point (m)
%     q : 1xN (or Nx1) vector     - charge magnitudes with sign (C)
%     R : Nx3 matrix              - each row is a charge position [x y z] (m)
%
%   Output:
%     E : 1x3 vector [Ex Ey Ez]   - net electric field at P (N/C)
%
%   Uses Coulomb's law with superposition:
%       E = sum_i  k * q_i * (P - r_i) / |P - r_i|^3

    % Coulomb constant, k = 1/(4*pi*eps0)
    eps0 = 8.8541878128e-12;        % Vacuum permittivity (F/m)
    k    = 1 / (4*pi*eps0);         % ~8.9875e9 N*m^2/C^2

    E = zeros(1, 3);                % Accumulator for the net field

    for i = 1:numel(q)
        % Displacement vector from charge i to the field point P
        d = P - R(i, :);

        % Distance between charge i and P
        dist = norm(d);

        % Guard: the field is singular if P coincides with a charge
        if dist == 0
            error('Field point P coincides with charge %d; field is undefined.', i);
        end

        % Coulomb's law for charge i:  E_i = k*q_i*d / |d|^3
        E_i = k * q(i) * d / dist^3;

        % Superposition: add the contribution of charge i
        E = E + E_i;
    end
end


function plotElectricField(P, E, q, R)
% PLOTELECTRICFIELD  3-D visualization of the field vector at P.
%
%   plotElectricField(P, E, q, R)
%
%   Inputs:
%     P : 1x3 field point (m)
%     E : 1x3 electric field vector at P (N/C)
%     q : 1xN charge magnitudes (C), used for coloring by sign
%     R : Nx3 charge positions (m)
%
%   The arrow is drawn with quiver3 at P. Because |E| (often ~1e4-1e6 N/C)
%   is numerically huge compared with distances in meters, the arrow is
%   scaled so its length is a fixed fraction of the scene size. Only the
%   DIRECTION and RELATIVE size are meaningful; the true value is printed
%   in the legend/title.

    figure('Name', 'Electric Field at P', 'Color', 'w');
    hold on; grid on; axis equal; box on;

    % ----- Determine a sensible arrow scale ------------------------------
    allPts   = [R; P];                                    % All points in scene
    sceneExt = max(max(allPts) - min(allPts));            % Largest extent (m)
    if sceneExt == 0, sceneExt = 1; end
    Emag     = norm(E);
    scale    = 0.4 * sceneExt / Emag;                     % Arrow ~40% of scene
    Eplot    = E * scale;                                 % Scaled vector

    % ----- Plot the charges (red = positive, blue = negative) ------------
    for i = 1:numel(q)
        if q(i) >= 0
            c = [0.85 0.1 0.1];  lbl = sprintf('q_%d = %+.2g C', i, q(i));
        else
            c = [0.1 0.2 0.85];  lbl = sprintf('q_%d = %+.2g C', i, q(i));
        end
        scatter3(R(i,1), R(i,2), R(i,3), 150, c, 'filled', ...
                 'MarkerEdgeColor', 'k', 'DisplayName', lbl);
        text(R(i,1), R(i,2), R(i,3), sprintf('  q_%d', i), 'FontSize', 11);
    end

    % ----- Plot the field point P ----------------------------------------
    scatter3(P(1), P(2), P(3), 80, 'k', 'filled', 'DisplayName', 'Point P');
    text(P(1), P(2), P(3), '  P', 'FontSize', 11, 'FontWeight', 'bold');

    % ----- Plot the electric field vector at P with quiver3 --------------
    % quiver3(x, y, z, u, v, w, 0) -> the 0 disables automatic scaling
    quiver3(P(1), P(2), P(3), Eplot(1), Eplot(2), Eplot(3), 0, ...
            'Color', [0 0.6 0.2], 'LineWidth', 2.5, 'MaxHeadSize', 0.6, ...
            'DisplayName', sprintf('E at P (|E| = %.3e N/C)', Emag));

    % ----- Formatting ----------------------------------------------------
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
    title('Electric Field Vector at P Due to Two Point Charges');
    legend('Location', 'best');
    view(3);                                              % Default 3-D view
    hold off;
end
view(120,35)