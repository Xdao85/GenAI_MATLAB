%% biot_savart_wire.m
% Magnetic field of a finite straight conductor (parallel to z-axis)
% computed with the Biot-Savart law, plus 3D vector visualization.
%
% Requires MATLAB R2016b or newer (local functions in scripts).

clear; clc; close all;

%% ------------------------- 1. INPUT PARAMETERS -------------------------
mu0 = 4*pi*1e-7;          % vacuum permeability [T*m/A]

I   = 10;                 % current [A]  (positive = +z direction)
l   = 2;                  % conductor length [m]
A   = [0.0, 0.0, 0.0];    % point A [m] = LOWER END of the wire
                          % (wire runs from A to A + [0 0 l])
P   = [0.5, 0.3, 1.0];    % observation point P [m]

N   = 2000;               % number of segments for numerical integration

%% ------------------------- 2. WIRE GEOMETRY ----------------------------
% Wire is parallel to z: x = Ax, y = Ay, z from Az to Az + l
zEdges = linspace(A(3), A(3) + l, N + 1);        % segment boundaries
zMid   = (zEdges(1:end-1) + zEdges(2:end)) / 2;  % segment midpoints
dz     = l / N;                                  % segment length

% Midpoint positions of all current elements (N x 3)
src = [A(1)*ones(N,1), A(2)*ones(N,1), zMid(:)];

% Vector current element dl for every segment (direction = +z)
dl  = repmat([0, 0, dz], N, 1);

%% ------------------- 3. BIOT-SAVART (NUMERICAL) ------------------------
%   dB = (mu0*I / 4*pi) * (dl x r) / |r|^3,   r = P - r_source
r    = P - src;                          % vectors source -> P (N x 3)
rMag = sqrt(sum(r.^2, 2));               % |r| (N x 1)

if any(rMag < 1e-9)
    error('Point P lies on the conductor: field is singular there.');
end

dB = (mu0*I/(4*pi)) * cross(dl, r, 2) ./ rMag.^3;   % per-segment field
B  = sum(dB, 1);                                    % total B at P [T]

%% ------------------- 4. ANALYTIC CHECK (finite wire) -------------------
% B = mu0*I/(4*pi*rho) * (sin(a2) - sin(a1)) * phi_hat
dx  = P(1) - A(1);   dy = P(2) - A(2);
rho = hypot(dx, dy);                     % perpendicular distance to wire
z1  = A(3)        - P(3);                % lower end relative to P
z2  = A(3) + l    - P(3);                % upper end relative to P
Bphi = mu0*I/(4*pi*rho) * ( z2/sqrt(rho^2 + z2^2) - z1/sqrt(rho^2 + z1^2) );
phiHat = [-dy, dx, 0] / rho;             % azimuthal unit vector (z_hat x rho_hat)
B_an = Bphi * phiHat;

%% ------------------------- 5. RESULTS ----------------------------------
fprintf('Numerical B = [%.4e  %.4e  %.4e] T\n', B);
fprintf('Analytic  B = [%.4e  %.4e  %.4e] T\n', B_an);
fprintf('|B| (numerical) = %.4e T  (%.3f uT)\n', norm(B), norm(B)*1e6);
fprintf('Relative difference = %.2e\n', norm(B - B_an)/norm(B_an));

%% ------------------------- 6. 3D VISUALIZATION -------------------------
figure('Name', 'Biot-Savart: finite straight wire', 'Color', 'w');
hold on; grid on; box on;

% Wire (thick line) and current-direction arrow at its centre
plot3([A(1) A(1)], [A(2) A(2)], [A(3) A(3)+l], 'k-', 'LineWidth', 4);
quiver3(A(1), A(2), A(3)+l/2, 0, 0, sign(I)*l/5, 0, ...
        'Color', [0.85 0.33 0.1], 'LineWidth', 2, 'MaxHeadSize', 2);
text(A(1), A(2), A(3)+l/2 + sign(I)*l/4, 'I', ...
     'Color', [0.85 0.33 0.1], 'FontSize', 12, 'FontWeight', 'bold');

% Points A and P
plot3(A(1), A(2), A(3), 'ks', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
plot3(P(1), P(2), P(3), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
text(A(1), A(2), A(3), '  A', 'FontSize', 12);
text(P(1), P(2), P(3), '  P', 'FontSize', 12, 'Color', 'b');

% Perpendicular dashed line from the wire axis to P (visual aid)
plot3([A(1) P(1)], [A(2) P(2)], [P(3) P(3)], 'k--');

% B-field vector at P.  B is ~1e-6 T, so scale it for visibility:
% the arrow is drawn with length = 0.25*l; the true value is in the legend.
scale = 0.25 * l / norm(B);
quiver3(P(1), P(2), P(3), B(1)*scale, B(2)*scale, B(3)*scale, 0, ...
        'Color', 'r', 'LineWidth', 2.5, 'MaxHeadSize', 0.8);

xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title(sprintf('B at P = [%.2f %.2f %.2f] m,  |B| = %.3g \\muT', P, norm(B)*1e6));
legend({'Conductor', 'Current direction', 'A', 'P', 'Perpendicular', ...
        sprintf('B (scaled, true |B| = %.3g \\muT)', norm(B)*1e6)}, ...
        'Location', 'best');
axis equal; view(35, 25);
hold off;
