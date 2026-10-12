%% em_wire_biot_savart.m
% Undergraduate EM demo: magnetic flux density B of a finite straight wire.
% Base MATLAB only, ASCII characters only.
%
% Geometry / sources (SI units):
%   - Straight conductor of length l = 2 m carrying I = 1 A in +z direction.
%   - Center at A(0.25, 0.5, 0) m, so the wire spans z = -1 m to z = +1 m.
%   - Observation point P(1, 1, 0) m.
%
% Two independent evaluations of B at P:
%   1) Closed-form finite-wire formula (reference).
%   2) Numerical Biot-Savart line integration (comparison).
%
% Right-hand rule is checked and a diagnostic message is issued if the
% relative vector error exceeds 0.1 percent.
%
% Author: EM course demo
% Date:   2024

clear; clc; close all;

%% ------------------------- Problem parameters -------------------------
mu0 = 4*pi*1e-7;              % Permeability of free space [H/m]
I   = 1.0;                    % Current [A]
A   = [0.25, 0.5, 0.0];       % Wire center [m]
P   = [1.0,  1.0, 0.0];       % Observation point [m]
l   = 2.0;                    % Wire length [m]
z1  = A(3) - l/2;             % Lower end z-coordinate [m]
z2  = A(3) + l/2;             % Upper end z-coordinate [m]

% Direction unit vector of the current (along +z)
aI = [0 0 1];

fprintf('--- Finite straight wire: Biot-Savart demo ---\n');
fprintf('Wire center A = (%.3f, %.3f, %.3f) m\n', A);
fprintf('Wire ends: z = %.3f m to z = %.3f m\n', z1, z2);
fprintf('Current I = %.3f A in +z direction\n', I);
fprintf('Observation point P = (%.3f, %.3f, %.3f) m\n\n', P);

%% ------------------- B via closed-form formula ------------------------
B_ref = computeB_closed_form(mu0, I, A, P, l);

%% ------------------- B via numerical Biot-Savart ----------------------
% Number of segments for the numerical integration
Nseg = 200001;                % Odd number helps midpoint rule symmetry
B_num = computeB_numeric(mu0, I, A, P, z1, z2, Nseg);

%% --------------------------- Comparison -------------------------------
err_vec = norm(B_num - B_ref) / norm(B_ref);

fprintf('Closed-form B_ref = [% .6e, % .6e, % .6e] T\n', B_ref);
fprintf('Numerical  B_num = [% .6e, % .6e, % .6e] T\n', B_num);
fprintf('|B_ref| = %.6e T,  |B_num| = %.6e T\n', norm(B_ref), norm(B_num));
fprintf('Relative vector error ||B_num - B_ref|| / ||B_ref|| = %.6e\n', err_vec);

%% --------------------- Right-hand rule check --------------------------
% For current in +z and a point with positive radial offset from the wire,
% the expected B direction is +phi_hat = z_hat x rho_hat.
% Here we check sign of (aI x r_vec) . B_ref, where r_vec goes from a wire
% point to P. Use the foot of the perpendicular from P to the wire axis.
r_foot  = [P(1) - A(1), P(2) - A(2), 0];   % radial vector from axis to P
r_hat   = r_foot / norm(r_foot);
phi_hat = cross(aI, r_hat);                % azimuthal direction (+phi)
dot_rh  = dot(B_ref, phi_hat);

fprintf('\nRight-hand rule check:\n');
fprintf('  phi_hat = aI x r_hat = [% .4f, % .4f, % .4f]\n', phi_hat);
fprintf('  B_ref . phi_hat = %.6e T (should be > 0)\n', dot_rh);

if dot_rh > 0
    fprintf('  Right-hand rule: satisfied (B curls in +phi direction).\n');
else
    fprintf('  Right-hand rule: NOT satisfied (check current direction).\n');
end

%% ------------------- Error tolerance check ----------------------------
tol = 1e-3;   % 0.1 percent
if err_vec > tol
    fprintf('\n*** STOP: Relative vector error %.3e exceeds tolerance %.3e ***\n', ...
            err_vec, tol);
    return;
else
    fprintf('\nError within tolerance (%.1f%%). Proceeding to plot.\n\n', tol*100);
end

%% ----------------------------- Plot -----------------------------------
plot_wire_and_B(A, P, B_ref, l);

%% ======================================================================
%  Local functions
%% ======================================================================

function B = computeB_closed_form(mu0, I, A, P, l)
% computeB_closed_form
% Closed-form magnetic flux density of a finite straight wire.
%
% Geometry (see standard EM texts, e.g. Sadiku or Hayt):
%   Wire along +z, center A, length l, current I.
%   Observation point P.
%
% The exact result for B at P is:
%
%       mu0*I
%   B = ----- * (sin(theta2) - sin(theta1)) * phi_hat
%       4*pi*rho
%
% where:
%   rho      = perpendicular distance from P to the wire axis
%   theta1   = angle at P subtended by the lower end of the wire, measured
%              from the perpendicular (positive if the lower end is below
%              the foot of the perpendicular)
%   theta2   = corresponding angle for the upper end
%   phi_hat  = azimuthal unit vector = (z_hat x rho_hat)
%
% Equivalent compact form using distances and projections:
%
%   B = (mu0*I)/(4*pi*rho) * ( (z2 - zP)/sqrt(rho^2+(z2-zP)^2)
%                              - (z1 - zP)/sqrt(rho^2+(z1-zP)^2) ) * phi_hat
%
% This is the equation implemented below.

    mu0_over_4pi = mu0 / (4*pi);

    % Wire endpoints
    z1 = A(3) - l/2;
    z2 = A(3) + l/2;

    % Radial vector from wire axis to P (axis is parallel to z through A)
    r_vec = [P(1) - A(1), P(2) - A(2), 0];
    rho   = norm(r_vec);

    % Azimuthal unit vector (right-hand rule with current in +z)
    aI      = [0 0 1];
    r_hat   = r_vec / rho;
    phi_hat = cross(aI, r_hat);   % = z_hat x rho_hat = +phi direction

    % Perpendicular foot z-coordinate at P (same as P(3) projection)
    zP = P(3);

    % Projection terms of the finite-wire formula
    s1 = (z2 - zP) / sqrt(rho^2 + (z2 - zP)^2);
    s2 = (z1 - zP) / sqrt(rho^2 + (z1 - zP)^2);

    % Closed-form B
    B = mu0_over_4pi * (I / rho) * (s1 - s2) * phi_hat;
end

function B = computeB_numeric(mu0, I, A, P, z1, z2, Nseg)
% computeB_numeric
% Numerical evaluation of the Biot-Savart law for a finite straight wire.
%
% Biot-Savart law:
%
%           mu0*I     (dl' x (r - r'))
%   B(r) = -------- * ----------------
%           4*pi      |r - r'|^3
%
% The wire is discretized into Nseg segments. For each segment we use the
% midpoint rule with segment vector dl' = (L/Nseg) * aI.

    mu0_over_4pi = mu0 / (4*pi);
    aI = [0 0 1];                        % Current direction (+z)

    dz   = (z2 - z1) / Nseg;             % Segment length
    dl   = dz * aI;                      % Segment vector dl'
    B    = [0 0 0];

    for k = 1:Nseg
        % Midpoint of the k-th segment along the wire (x = A(1), y = A(2))
        zk   = z1 + (k - 0.5) * dz;
        rp   = [A(1), A(2), zk];         % Source point r'
        Rvec = P - rp;                   % r - r'
        Rmag = norm(Rvec);

        % Biot-Savart contribution (avoid singularity if P on wire)
        if Rmag < 1e-12
            error('Observation point lies on the wire; Biot-Savart is singular.');
        end

        B = B + (mu0_over_4pi * I) * cross(dl, Rvec) / Rmag^3;
    end
end

function plot_wire_and_B(A, P, B, l)
% plot_wire_and_B
% Plots the finite wire, the point A, the observation point P, and the
% magnetic flux density vector B at P using quiver3.

    figure('Color', 'w');
    hold on; grid on; box on;

    % --- Wire geometry ---
    z1 = A(3) - l/2;
    z2 = A(3) + l/2;
    zw = linspace(z1, z2, 200);
    xw = A(1) * ones(size(zw));
    yw = A(2) * ones(size(zw));

    plot3(xw, yw, zw, 'k-', 'LineWidth', 2);   % Wire

    % Current direction arrow (midpoint of wire, along +z)
    quiver3(A(1), A(2), A(3), 0, 0, 0.5, 0, ...
            'Color', [0 0.5 0], 'LineWidth', 1.5, 'MaxHeadSize', 0.8);

    % --- Points A and P ---
    plot3(A(1), A(2), A(3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
    plot3(P(1), P(2), P(3), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

    % --- B vector at P (scaled for visibility; direction preserved) ---
    Bmag = norm(B);
    if Bmag > 0
        scale = 0.5 / Bmag;                    % Visual scaling only
        quiver3(P(1), P(2), P(3), ...
                scale*B(1), scale*B(2), scale*B(3), 0, ...
                'Color', 'b', 'LineWidth', 2, 'MaxHeadSize', 1.0);
    end

    % --- Labels, legend, formatting ---
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title('Finite straight wire and B at P (B vector scaled for display)');

    legend({'Wire (l = 2 m)', 'Current +z', 'Center A', 'Point P', 'B at P (scaled)'}, ...
           'Location', 'best');

    axis equal;
    view(35, 25);
    hold off;
end