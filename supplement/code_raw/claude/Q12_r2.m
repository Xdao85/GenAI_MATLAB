%% ELECTRIC FIELD OF TWO POINT CHARGES AT A POINT P (3D)
% -------------------------------------------------------------------------
% Mathematical formulation (Coulomb's law + superposition principle):
%
%   The field at position r due to a point charge q located at r_i is
%
%       E_i(r) = k * q * (r - r_i) / |r - r_i|^3
%
%   where k = 1/(4*pi*eps0) ~ 8.9875e9 N*m^2/C^2.
%   (r - r_i)/|r - r_i| is the unit vector pointing from the charge to P,
%   and the 1/|r - r_i|^2 factor is the inverse-square dependence.
%
%   For several charges the fields add as vectors (superposition):
%
%       E_total = E_1 + E_2
%
% Requires MATLAB R2016b or newer (local functions inside a script file).
% -------------------------------------------------------------------------

clear; clc; close all;

%% ------------------------- MAIN SCRIPT ----------------------------------

% --- User inputs --------------------------------------------------------
% Charge magnitudes in coulombs (sign matters: + repels, - attracts)
q1 =  2e-9;                 % charge 1: +2 nC
q2 = -3e-9;                 % charge 2: -3 nC

% Charge positions in meters, as [x y z]
r1 = [ 1.0,  0.0,  0.0];    % position of charge 1
r2 = [-1.0,  0.5,  0.0];    % position of charge 2

% Field point P in meters
Px = 0.5;  Py = 1.5;  Pz = 1.0;
P  = [Px, Py, Pz];

% --- Computation --------------------------------------------------------
% Field from each charge individually (useful for visualization)
E1 = electricFieldPointCharge(q1, r1, P);
E2 = electricFieldPointCharge(q2, r2, P);

% Total field by superposition
E  = E1 + E2;

% --- Report results -----------------------------------------------------
fprintf('Field point P  = (%.3f, %.3f, %.3f) m\n', P);
fprintf('E from q1      = (%.4e, %.4e, %.4e) N/C\n', E1);
fprintf('E from q2      = (%.4e, %.4e, %.4e) N/C\n', E2);
fprintf('Total E        = (%.4e, %.4e, %.4e) N/C\n', E);
fprintf('|E|            = %.4e N/C\n', norm(E));

% --- Visualization ------------------------------------------------------
plotElectricField(P, E, E1, E2, r1, r2, q1, q2);


%% ------------------------- FUNCTIONS ------------------------------------

function E = electricFieldPointCharge(q, rq, P)
% ELECTRICFIELDPOINTCHARGE  Electric field of ONE point charge (Coulomb's law).
%
%   E = electricFieldPointCharge(q, rq, P)
%
%   Inputs:
%     q  - charge in coulombs (scalar, signed)
%     rq - charge position [x y z] in meters (1x3)
%     P  - field point     [x y z] in meters (1x3)
%
%   Output:
%     E  - electric field vector [Ex Ey Ez] in N/C (1x3)

    % Coulomb constant k = 1/(4*pi*eps0)
    eps0 = 8.854187817e-12;           % vacuum permittivity (F/m)
    k    = 1 / (4*pi*eps0);

    % Displacement vector from the charge to the field point
    R    = P(:).' - rq(:).';          % force row vectors: [Px-xq, Py-yq, Pz-zq]
    Rmag = norm(R);                   % distance |R|

    % Guard against evaluating the field exactly at the charge (singular)
    if Rmag == 0
        error('Field point P coincides with a charge location; E is undefined.');
    end

    % Coulomb's law in vector form: E = k*q*R / |R|^3
    E = k * q * R / Rmag^3;
end


function plotElectricField(P, E, E1, E2, r1, r2, q1, q2)
% PLOTELECTRICFIELD  3D visualization of the field at P using quiver3.
%
%   Draws: both charges (red = positive, blue = negative), the field point P,
%   the total E vector (black), and the individual contributions E1, E2.
%
%   Because |E| is typically huge (~1e2-1e9 N/C), arrows are rescaled so the
%   TOTAL field arrow has a length comparable to the scene size. All arrows
%   share the same scale factor, so their relative magnitudes are preserved.

    figure('Name', 'Electric field at P', 'Color', 'w');
    hold on; grid on; axis equal; box on;

    % --- Choose an arrow scale factor for readability --------------------
    pts       = [P; r1; r2];                         % all points in the scene
    sceneSize = max(max(pts) - min(pts));            % largest spatial extent
    scale     = 0.5 * sceneSize / norm(E);           % total E arrow = 50% of scene

    % --- Plot the charges ------------------------------------------------
    charges = {r1, q1; r2, q2};
    for i = 1:2
        pos = charges{i, 1};
        q   = charges{i, 2};
        if q >= 0, c = 'r'; else, c = 'b'; end       % color by sign
        scatter3(pos(1), pos(2), pos(3), 120, c, 'filled', ...
                 'MarkerEdgeColor', 'k');
        text(pos(1), pos(2), pos(3), sprintf('  q%d = %.1f nC', i, q*1e9));
    end

    % --- Plot the field point P ------------------------------------------
    scatter3(P(1), P(2), P(3), 80, 'k', 'filled', 'd');
    text(P(1), P(2), P(3), '  P');

    % --- Plot field vectors at P with quiver3 ----------------------------
    % Syntax: quiver3(x, y, z, u, v, w, autoscale); 0 = use our own scaling
    h1 = quiver3(P(1), P(2), P(3), scale*E1(1), scale*E1(2), scale*E1(3), 0, ...
                 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5, 'LineStyle', '--');
    h2 = quiver3(P(1), P(2), P(3), scale*E2(1), scale*E2(2), scale*E2(3), 0, ...
                 'Color', [0.00 0.45 0.74], 'LineWidth', 1.5, 'LineStyle', '--');
    h  = quiver3(P(1), P(2), P(3), scale*E(1),  scale*E(2),  scale*E(3),  0, ...
                 'Color', 'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.6);

    % --- Labels and formatting -------------------------------------------
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
    title(sprintf('Electric field at P  (|E| = %.3e N/C)', norm(E)));
    legend([h1 h2 h], {'E_1 (from q1)', 'E_2 (from q2)', 'E_{total}'}, ...
           'Location', 'best');
    view(3);                                         % default 3D viewpoint
    hold off;
end
