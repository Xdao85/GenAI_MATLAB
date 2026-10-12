%% Magnetic Flux Density of a Finite Linear Conductor
% A straight conductor of length l parallel to z-axis carrying current I.
% The conductor's position is given at (Ax, Ay, Az), and we compute B at P.
%
% Uses the Biot-Savart law for a finite straight wire:
%   B = (mu0*I / (4*pi*rho)) * (sin(theta2) - sin(theta1)) * phi_hat
% where rho is the perpendicular distance from wire to P, and
% theta1, theta2 are the angles subtended by the wire ends at P.

clear; clc; close all;

%% ---------------- User Inputs ----------------
I    = 10;              % Current (A) - positive => +z direction
l    = 5;               % Length of conductor (m)
A    = [0, 0, 0];       % Start point of conductor (Ax, Ay, Az)  [m]
P    = [2, 1, 1.5];     % Observation point (Px, Py, Pz)          [m]
mu0  = 4*pi*1e-7;       % Permeability of free space (H/m)

%% ---------------- Compute B vector ----------------
B = computeB_finiteWire(I, l, A, P, mu0);

fprintf('Magnetic flux density at P = [%.3f, %.3f, %.3f] m:\n', P);
fprintf('  B = [% .6e, % .6e, % .6e] T\n', B);
fprintf('  |B| = %.6e T\n', norm(B));

%% ---------------- 3D Plot ----------------
figure('Color','w');
hold on; grid on; axis equal;
view(45, 25);

% --- Draw the conductor ---
z1 = A(3);
z2 = A(3) + l;
plot3([A(1) A(1)], [A(2) A(2)], [z1 z2], ...
    'k-', 'LineWidth', 3);

% Arrow showing current direction
midz = (z1 + z2)/2;
quiver3(A(1), A(2), midz, 0, 0, l/4, ...
    0, 'Color', [0.8 0 0], 'LineWidth', 2, 'MaxHeadSize', 0.6);

% --- Draw point P ---
plot3(P(1), P(2), P(3), 'bo', 'MarkerSize', 10, 'MarkerFaceColor','b');

% --- Draw B vector at P ---
Bscale = 0.8 * l / max(norm(B), eps);   % scale arrow for visibility
quiver3(P(1), P(2), P(3), ...
        B(1)*Bscale, B(2)*Bscale, B(3)*Bscale, ...
        0, 'Color', [0 0.5 0], 'LineWidth', 2.5, 'MaxHeadSize', 0.5);

% --- Optional: sketch several B vectors around the wire ---
plotBFieldAroundWire(I, l, A, mu0, l);

% --- Labels & cosmetics ---
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title(sprintf('B at P due to finite wire  (I = %.1f A, l = %.1f m)', I, l));
legend({'Conductor','Current direction','Point P','B at P'}, ...
       'Location','best');
set(gca,'FontSize',11);

hold off;

%% ================= Helper Functions =================

function B = computeB_finiteWire(I, l, A, P, mu0)
% Computes B at point P due to a straight finite wire of length l
% located at (A(1),A(2)) parallel to z, starting at z = A(3).

    Ax = A(1); Ay = A(2); Az = A(3);
    z1 = Az;         % lower end
    z2 = Az + l;     % upper end (current flows +z)

    % Perpendicular vector from wire axis to P (in xy-plane)
    rx = P(1) - Ax;
    ry = P(2) - Ay;
    rho = hypot(rx, ry);

    if rho < 1e-12
        warning('Point P lies on the conductor axis — B is undefined.');
        B = [0 0 0];
        return;
    end

    % Unit azimuthal vector phi_hat = (-ry, rx, 0)/rho
    phi_hat = [-ry, rx, 0] / rho;

    % z-coordinates of wire ends relative to P
    zc = P(3);
    s1 = z1 - zc;    % relative coord of lower end
    s2 = z2 - zc;    % relative coord of upper end

    % Angles (sin) subtended by the ends at P
    % sin(theta) = s / sqrt(s^2 + rho^2)
    sin1 = s1 / sqrt(s1^2 + rho^2);
    sin2 = s2 / sqrt(s2^2 + rho^2);

    % Magnitude of B (Biot-Savart for finite straight wire)
    Bmag = (mu0 * I / (4*pi*rho)) * (sin2 - sin1);

    B = Bmag * phi_hat;
end

function plotBFieldAroundWire(I, l, A, mu0, scale)
% Plots a small set of B vectors around the wire to show circulation.
    Ax = A(1); Ay = A(2); Az = A(3);
    zc = Az + l/2;

    gridR = linspace(0.4, 0.9, 3) * max(l/2, 1);
    angs  = linspace(0, 2*pi, 9);

    for r = gridR
        for a = angs
            Pt = [Ax + r*cos(a), Ay + r*sin(a), zc];
            Bv = computeB_finiteWire(I, l, A, Pt, mu0);
            if norm(Bv) > 0
                q = Bv / norm(Bv) * scale * 0.15;
                quiver3(Pt(1),Pt(2),Pt(3), q(1),q(2),q(3), ...
                    0, 'Color',[0.4 0.4 1], 'LineWidth',1);
            end
        end
    end
end