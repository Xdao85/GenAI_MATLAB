% finite_wire_B.m
% Magnetic field of a finite straight wire: closed form vs numerical Biot-Savart.
% Base MATLAB only (local functions at the end require R2016b or later).
% SI units throughout.

clear; clc; close all;

%% 1. Problem data
mu0 = 4*pi*1e-7;          % permeability of free space [H/m]
I   = 1;                  % current [A], flowing in +z
A   = [0.25, 0.5, 0];     % wire center point [m]
zLo = -1;                 % lower end of the wire in z [m]
zHi =  1;                 % upper end of the wire in z [m]  (l = 2 m)
P   = [1, 1, 0];          % observation point [m]
tol = 1e-3;               % allowed relative vector error (0.1 %)

%% 2. Solutions
B_ref = B_closed_form(mu0, I, A, zLo, zHi, P);   % analytic result [T]
B_num = B_biot_savart(mu0, I, A, zLo, zHi, P);   % numerical result [T]

%% 3. Report and verification
relErr = norm(B_num - B_ref) / norm(B_ref);      % relative vector error

fprintf('B closed form  = [%12.6e %12.6e %12.6e] T\n', B_ref);
fprintf('B Biot-Savart  = [%12.6e %12.6e %12.6e] T\n', B_num);
fprintf('|B_ref| = %.6e T,  |B_num| = %.6e T\n', norm(B_ref), norm(B_num));
fprintf('Relative vector error = %.3e (%.4f %%)\n', relErr, 100*relErr);

% Right-hand rule check: with the thumb along +z, the fingers curl
% counterclockwise seen from +z, so B must point along z_hat x rho_hat,
% where rho_hat is the unit vector from the wire axis to P.
rho_vec = [P(1)-A(1), P(2)-A(2), 0];             % perpendicular vector wire->P [m]
rho_hat = rho_vec / norm(rho_vec);               % unit radial vector
phi_hat = cross([0 0 1], rho_hat);               % expected direction of B (RHR)
alignment = dot(B_ref, phi_hat) / norm(B_ref);   % +1 means B along phi_hat
radialPart = dot(B_ref, rho_hat) / norm(B_ref);  % should be 0 (B has no radial part)
axialPart  = B_ref(3) / norm(B_ref);             % should be 0 (B has no z part)

fprintf('Right-hand rule: B.phi_hat/|B| = %+.6f (expect +1)\n', alignment);
fprintf('                 B.rho_hat/|B| = %+.2e, Bz/|B| = %+.2e (expect 0)\n', ...
        radialPart, axialPart);

if alignment < 1 - 1e-9 || abs(radialPart) > 1e-9 || abs(axialPart) > 1e-9
    error('finite_wire_B:RHR', ...
          'Right-hand rule check FAILED: B is not along z_hat x rho_hat.');
end
disp('Right-hand rule check passed.');

if relErr > tol
    error('finite_wire_B:accuracy', ...
          'Stopped: relative vector error %.3e exceeds %.1e (0.1 %%).', relErr, tol);
end
disp('Numerical result agrees with closed form within 0.1 %.');

%% 4. Plot
plot_geometry(A, zLo, zHi, P, B_ref);

%% ===================== Local functions =====================

function B = B_closed_form(mu0, I, A, zLo, zHi, P)
% Closed-form field of a finite straight wire along z through A(1),A(2).
    dx  = P(1) - A(1);                 % x distance from wire axis [m]
    dy  = P(2) - A(2);                 % y distance from wire axis [m]
    rho = hypot(dx, dy);               % perpendicular distance rho [m]
    z1  = zLo - P(3);                  % lower wire end relative to P [m]
    z2  = zHi - P(3);                  % upper wire end relative to P [m]

    % sin of the angles seen from P to each end: sin(a) = z / sqrt(z^2+rho^2)
    s1 = z1 / sqrt(z1^2 + rho^2);      % sin(alpha1) at the lower end
    s2 = z2 / sqrt(z2^2 + rho^2);      % sin(alpha2) at the upper end

    % Magnitude: B = mu0*I/(4*pi*rho) * (sin(a2) - sin(a1))  [T]
    Bmag = mu0 * I / (4*pi*rho) * (s2 - s1);

    % Direction: phi_hat = z_hat x rho_hat = (-dy, dx, 0)/rho (right-hand rule)
    phi_hat = [-dy, dx, 0] / rho;

    % Vector field: B = Bmag * phi_hat  [T]
    B = Bmag * phi_hat;
end

function B = B_biot_savart(mu0, I, A, zLo, zHi, P)
% Numerical Biot-Savart integration along the wire (adaptive quadrature).
    % Integrand: dB/dz' = mu0*I/(4*pi) * (z_hat x R) / |R|^3, with
    % R = P - r' the vector from the source element to P [m].
    integrand = @(zp) dB_element(mu0, I, A, zp, P);

    % B = integral of dB over the wire from zLo to zHi  [T]
    B = integral(integrand, zLo, zHi, 'ArrayValued', true, ...
                 'RelTol', 1e-10, 'AbsTol', 1e-20).';
end

function dB = dB_element(mu0, I, A, zp, P)
% Field contribution per unit length at source height zp (column 3x1).
    R  = [P(1)-A(1); P(2)-A(2); P(3)-zp];   % vector source -> P [m]
    Rn = norm(R);                            % distance |R| [m]
    dl = [0; 0; 1];                          % dl/dz' = z_hat (current along +z)
    % Biot-Savart: dB = mu0/(4*pi) * I * (dl x R) / |R|^3  [T/m]
    dB = mu0 / (4*pi) * I * cross(dl, R) / Rn^3;
end

function plot_geometry(A, zLo, zHi, P, B)
% 3-D view of the wire, center A, point P and the field vector B at P.
    figure('Name', 'Finite wire and B field', 'Color', 'w');
    hold on; grid on;

    % Wire: vertical line through A(1), A(2) from zLo to zHi
    hW = plot3([A(1) A(1)], [A(2) A(2)], [zLo zHi], 'k-', 'LineWidth', 3);

    % Current direction arrow (+z) drawn on the wire for orientation
    quiver3(A(1), A(2), 0.3*(zHi+zLo)/2 + 0.3, 0, 0, 0.4, 0, ...
            'k', 'LineWidth', 2, 'MaxHeadSize', 2);

    % Points A and P
    hA = plot3(A(1), A(2), A(3), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
    hP = plot3(P(1), P(2), P(3), 'rs', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

    % Perpendicular from wire to P (helps see rho)
    plot3([A(1) P(1)], [A(2) P(2)], [A(3) P(3)], 'k:', 'LineWidth', 1);

    % B at P: B is only ~1e-7 T, so draw it with a fixed visible length
    Lvis = 0.5;                              % displayed arrow length [m]
    Bd   = Lvis * B / norm(B);               % scaled direction vector [m]
    hB = quiver3(P(1), P(2), P(3), Bd(1), Bd(2), Bd(3), 0, ...
                 'Color', [0.85 0.33 0.1], 'LineWidth', 2.5, 'MaxHeadSize', 1.5);

    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
    title('Finite straight wire (I = 1 A, +z) and B at P');
    legend([hW hA hP hB], ...
           {'Wire (I in +z)', 'A (wire center)', 'P (observation)', ...
            'B at P (direction only, length not to scale)'}, ...
           'Location', 'best');
    axis equal;
    view(3);
    hold off;
end
