%% finite_wire_B.m
% Magnetic flux density of a finite straight wire (undergraduate EM).
% Base MATLAB only. Local functions at the end of the file require
% MATLAB R2016b or later (script files with local functions).
%
% Geometry (SI units):
%   Wire along z, centered at A = (0.25, 0.5, 0) m, z from -1 to +1 m
%   (length l = 2 m), current I = 1 A in the +z direction.
%   Observation point P = (1, 1, 0) m.

clear; clc; close all;

%% ---------------- Input data (SI units) ----------------
mu0   = 4*pi*1e-7;          % permeability of free space [T*m/A]
I     = 1;                  % current [A], flowing in +z
A     = [0.25, 0.5, 0];     % wire center [m]
zLow  = -1;                 % wire end (lower), z-coordinate [m]
zHigh = +1;                 % wire end (upper), z-coordinate [m]
P     = [1, 1, 0];          % observation point [m]
N     = 2000;               % number of segments for numerical integral
tol   = 1e-3;               % allowed relative vector error (0.1 %)

%% ---------------- Solutions ----------------
B_ref = bfield_closed_form(mu0, I, A, zLow, zHigh, P);   % closed form
B_num = bfield_biot_savart(mu0, I, A, zLow, zHigh, P, N); % numerical

%% ---------------- Print results ----------------
% Relative vector error: norm of the difference over norm of reference
relErr = norm(B_num - B_ref) / norm(B_ref);

fprintf('B (closed form)  = [%12.6e %12.6e %12.6e] T, |B| = %.6e T\n', ...
        B_ref, norm(B_ref));
fprintf('B (Biot-Savart)  = [%12.6e %12.6e %12.6e] T, |B| = %.6e T\n', ...
        B_num, norm(B_num));
fprintf('Relative vector error = %.3e (%.4f %%)\n', relErr, 100*relErr);

%% ---------------- Right-hand rule check ----------------
% Wire direction (unit vector) and radial vector from the wire axis to P
zhat    = [0, 0, 1];                        % current direction
rho_vec = (P - A) - dot(P - A, zhat)*zhat;  % perpendicular distance vector
rho     = norm(rho_vec);                    % perpendicular distance [m]
rhohat  = rho_vec / rho;                    % radial unit vector
% Right-hand rule: thumb along I (+z), fingers curl in direction zhat x rhohat
phihat  = cross(zhat, rhohat);              % expected direction of B

% B must be (a) along phihat and (b) perpendicular to both wire and radial
alignment = dot(B_num, phihat) / norm(B_num);   % cosine, should be +1
perpTol   = 1e-9;                               % numerical tolerance
isPerp    = abs(dot(B_num, zhat))   < perpTol*norm(B_num) && ...
            abs(dot(B_num, rhohat)) < perpTol*norm(B_num);
rhrOK     = (alignment > 1 - 1e-6) && isPerp;

fprintf('Right-hand rule: cos(angle between B and z x rho_hat) = %.8f\n', ...
        alignment);
if rhrOK
    fprintf('Right-hand rule check: PASSED\n');
else
    error('finite_wire_B:RHR', ...
          'Right-hand rule check FAILED: B is not along z x rho_hat.');
end

%% ---------------- Accuracy check (stop if > 0.1 %) ----------------
if relErr > tol
    error('finite_wire_B:accuracy', ...
          ['Numerical result differs from closed form by %.4f %% ' ...
           '(limit %.2f %%). Increase N or check the setup.'], ...
          100*relErr, 100*tol);
end
fprintf('Accuracy check: PASSED (error below %.2f %%)\n', 100*tol);

%% ---------------- Plot ----------------
plot_scene(A, zLow, zHigh, P, B_ref);

%% ======================= Local functions =======================

function B = bfield_closed_form(mu0, I, A, zLow, zHigh, P)
% Closed-form B of a finite straight wire along z through (A(1), A(2)).
% Inputs in SI units; returns B as a 1x3 row vector [T].

    zhat    = [0, 0, 1];                      % wire direction (current in +z)
    d       = P - A;                          % vector from wire center to P
    rho_vec = d - dot(d, zhat)*zhat;          % component of d perpendicular to wire
    rho     = norm(rho_vec);                  % perpendicular distance [m]
    rhohat  = rho_vec / rho;                  % radial unit vector

    % Heights of the wire ends relative to the foot of the perpendicular
    % from P (foot is at z = P(3)); signed distances along +z [m]
    z1 = (A(3) + zLow)  - P(3);               % lower end, relative to P's level
    z2 = (A(3) + zHigh) - P(3);               % upper end, relative to P's level

    % Sine of the angle between the perpendicular and the line from P to
    % each end:  sin(alpha) = z / sqrt(rho^2 + z^2)
    s1 = z1 / sqrt(rho^2 + z1^2);             % lower end
    s2 = z2 / sqrt(rho^2 + z2^2);             % upper end

    % Finite-wire magnitude: B = mu0*I/(4*pi*rho) * (sin(a2) - sin(a1))
    Bmag = mu0*I / (4*pi*rho) * (s2 - s1);    % [T]

    % Direction by right-hand rule: phihat = zhat x rhohat
    phihat = cross(zhat, rhohat);             % azimuthal unit vector

    % Vector result: B = Bmag * phihat
    B = Bmag * phihat;
end

function B = bfield_biot_savart(mu0, I, A, zLow, zHigh, P, N)
% Numerical Biot-Savart integration (midpoint rule, N segments).
% Returns B as a 1x3 row vector [T].

    dz = (zHigh - zLow) / N;                  % segment length [m]
    zc = zLow + dz*((1:N)' - 0.5);            % segment midpoints, z' [m] (Nx1)

    % Source points on the wire: r' = A + (0, 0, z')
    rs = [A(1)*ones(N,1), A(2)*ones(N,1), A(3) + zc];   % Nx3 [m]

    % Vector from each source point to P: R = r - r'
    R  = repmat(P, N, 1) - rs;                % Nx3 [m]
    Rm = sqrt(sum(R.^2, 2));                  % |R| for each segment [m]

    % Current element vector: dl = zhat * dz  (direction of the current)
    dL = [zeros(N,1), zeros(N,1), dz*ones(N,1)];        % Nx3 [m]

    % Biot-Savart law: dB = mu0*I/(4*pi) * (dl x R) / |R|^3
    dB = (mu0*I/(4*pi)) * cross(dL, R, 2) ./ Rm.^3;      % Nx3 [T]

    % Superposition: B = integral of dB, approximated by the sum
    B = sum(dB, 1);                           % 1x3 [T]
end

function plot_scene(A, zLow, zHigh, P, B)
% 3-D plot of the wire, its center A, the point P and the field B at P.

    % Wire end points: A + (0, 0, z)
    wire = [A(1) A(2) A(3)+zLow; A(1) A(2) A(3)+zHigh];  % 2x3 [m]

    % B is ~1e-7 T, far too small to see; scale it to a fixed display
    % length (0.5 m). Only the direction is meaningful in the plot.
    Lshow = 0.5;                              % displayed arrow length [m]
    Bdisp = Lshow * B / norm(B);              % scaled vector [m]

    figure('Name', 'Finite straight wire', 'Color', 'w');
    hold on;
    hw = plot3(wire(:,1), wire(:,2), wire(:,3), 'b-', 'LineWidth', 3);
    ha = plot3(A(1), A(2), A(3), 'ks', 'MarkerFaceColor', 'k', ...
               'MarkerSize', 8);
    hp = plot3(P(1), P(2), P(3), 'ro', 'MarkerFaceColor', 'r', ...
               'MarkerSize', 8);
    % Dashed perpendicular segment from A to P (shows rho)
    plot3([A(1) P(1)], [A(2) P(2)], [A(3) P(3)], 'k--', 'LineWidth', 1);
    % Current direction arrow on the wire (+z), drawn from the upper half
    quiver3(A(1), A(2), A(3)+0.3, 0, 0, 0.5, 0, 'b', 'LineWidth', 2, ...
            'MaxHeadSize', 1);
    hb = quiver3(P(1), P(2), P(3), Bdisp(1), Bdisp(2), Bdisp(3), 0, ...
                 'm', 'LineWidth', 2, 'MaxHeadSize', 0.8);
    hold off;

    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
    title('Finite wire: B at P (arrow length scaled for display)');
    legend([hw ha hp hb], {'Wire, I = 1 A in +z', 'A (wire center)', ...
           'P (observation point)', 'B at P (scaled)'}, ...
           'Location', 'best');
    axis equal; grid on; view(3);
end
