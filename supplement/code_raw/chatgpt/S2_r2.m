% Finite straight conductor: closed-form and numerical Biot-Savart
% Undergraduate electromagnetics example
% SI units throughout.
%
% Geometry:
%   Wire length l = 2 m, centered at A = (0.25, 0.5, 0) m
%   Current I = 1 A in the +z direction
%   Wire extends from z = -1 m to z = +1 m
%   Observation point P = (1, 1, 0) m
%
% The script:
%   1) Computes B at P using the closed-form finite-wire formula.
%   2) Computes B at P using numerical Biot-Savart integration.
%   3) Compares the two vectors and checks the right-hand rule.
%   4) Plots the wire, A, P, and B using quiver3.
%   5) Stops if the vector error exceeds 0.1 percent.

clear;
clc;
close all;

%% Given data

mu0 = 4*pi*1e-7;       % Permeability of free space, H/m.
I = 1;                 % Current, A.

l = 2;                 % Wire length, m.
A = [0.25, 0.5, 0];    % Wire center, m.
P = [1, 1, 0];         % Observation point, m.

z1 = -l/2;             % Lower z coordinate relative to A, m.
z2 =  l/2;             % Upper z coordinate relative to A, m.

%% Closed-form finite-wire solution

[B_ref, r_perp, phi1, phi2] = finite_wire_B(mu0, I, A, P, z1, z2);

%% Numerical Biot-Savart solution

N = 200000;            % Number of integration points.
[B_num, z_num] = numerical_biot_savart(mu0, I, A, P, z1, z2, N);

%% Compare the two solutions

% Equation: vector error = ||B_num - B_ref|| / ||B_ref||.
vector_error = norm(B_num - B_ref) / norm(B_ref);

fprintf('Finite straight conductor EM calculation\n');
fprintf('-----------------------------------------\n');
fprintf('Wire center A = (%.4f, %.4f, %.4f) m\n', A);
fprintf('Observation point P = (%.4f, %.4f, %.4f) m\n', P);
fprintf('Current I = %.4f A in the +z direction\n', I);
fprintf('Wire length l = %.4f m\n\n', l);

fprintf('Closed-form B_ref [T]:\n');
fprintf('  Bx = %.10e T\n', B_ref(1));
fprintf('  By = %.10e T\n', B_ref(2));
fprintf('  Bz = %.10e T\n', B_ref(3));
fprintf('  |B_ref| = %.10e T\n\n', norm(B_ref));

fprintf('Numerical Biot-Savart B_num [T]:\n');
fprintf('  Bx = %.10e T\n', B_num(1));
fprintf('  By = %.10e T\n', B_num(2));
fprintf('  Bz = %.10e T\n', B_num(3));
fprintf('  |B_num| = %.10e T\n\n', norm(B_num));

fprintf('Relative vector error = %.6e (%.6f %%)\n', ...
    vector_error, 100*vector_error);

%% Right-hand-rule check

% For current in +z, the magnetic field circles the z axis according
% to the right-hand rule.  At P, the radial direction from the wire
% center toward P is +x and +y, so the tangential field direction is
% proportional to z_hat x r_perp = [-dy, dx, 0].
%
% Equation:
%   r_perp = P - A
%   B_RHR direction = z_hat x r_perp.

r_perp_vec = P - A;
z_hat = [0, 0, 1];

B_rhr_direction = cross(z_hat, r_perp_vec);
B_rhr_direction = B_rhr_direction / norm(B_rhr_direction);

% Normalize the calculated field for a direction comparison.
B_ref_direction = B_ref / norm(B_ref);

% Equation:
%   cos(theta) = B_ref_hat dot B_RHR_hat.
rhr_dot = dot(B_ref_direction, B_rhr_direction);

fprintf('\nRight-hand-rule check:\n');
fprintf('Expected direction = [%.4f, %.4f, %.4f]\n', ...
    B_rhr_direction);
fprintf('Calculated direction = [%.4f, %.4f, %.4f]\n', ...
    B_ref_direction);

if rhr_dot > 1 - 1e-10
    fprintf('PASS: B_ref follows the right-hand rule.\n');
else
    fprintf('FAIL: B_ref does not follow the expected right-hand rule.\n');
    error('Right-hand-rule check failed.');
end

%% Accuracy check

% The required maximum relative vector error is 0.1 percent.
error_limit = 0.001;

if vector_error > error_limit
    fprintf('\nERROR: Numerical solution exceeds the 0.1%% error limit.\n');
    fprintf('Increase N or check the numerical integration.\n');
    error('Vector error exceeds 0.1 percent.');
else
    fprintf('PASS: Vector error is below the 0.1%% limit.\n');
end

%% Plot

plot_field_geometry(A, P, z1, z2, B_ref);


%% Local function: closed-form finite-wire solution

function [B, r_perp, phi1, phi2] = finite_wire_B(mu0, I, A, P, z1, z2)
%FINITe_WIRE_B Closed-form magnetic field of a finite straight wire.
%
% The wire is parallel to the z axis and centered at A.
% The current flows in the +z direction.

    % Equation:
    % r_perp = P - A gives the displacement from the wire axis
    % to the observation point.
    r_perp = P - A;

    % The perpendicular distance from the wire axis to P is:
    %
    % Equation:
    % rho = sqrt(dx^2 + dy^2).
    rho = sqrt(r_perp(1)^2 + r_perp(2)^2);

    % Unit vector in the azimuthal field direction.
    %
    % Equation:
    % phi_hat = z_hat x r_perp_hat.
    phi_hat = [-r_perp(2), r_perp(1), 0] / rho;

    % Coordinates of P relative to the wire center.
    xrel = r_perp(1);
    yrel = r_perp(2);

    % Signed longitudinal coordinate of P relative to the wire.
    zrel = P(3) - A(3);

    % Distance from P to the lower and upper wire endpoints.
    %
    % Equation:
    % R_i = sqrt(rho^2 + (z_i - z_P)^2).
    R1 = sqrt(rho^2 + (z1 - zrel)^2);
    R2 = sqrt(rho^2 + (z2 - zrel)^2);

    % Angles used in the finite-wire formula.
    %
    % Equation:
    % phi1 = atan2(z_P - z1, rho)
    % phi2 = atan2(z2 - z_P, rho).
    phi1 = atan2(zrel - z1, rho);
    phi2 = atan2(z2 - zrel, rho);

    % Closed-form finite-wire magnetic field.
    %
    % Equation:
    % B = (mu0*I/(4*pi*rho)) * (sin(phi1) + sin(phi2)) * phi_hat.
    B_magnitude = (mu0*I/(4*pi*rho)) * ...
                  (sin(phi1) + sin(phi2));

    B = B_magnitude * phi_hat;

    % Keep these variables explicitly used/documented.
    %#ok<NASGU>
    xrel = xrel;
    yrel = yrel;
    R1 = R1;
    R2 = R2;
end


%% Local function: numerical Biot-Savart integration

function [B, z_values] = numerical_biot_savart(mu0, I, A, P, z1, z2, N)
%NUMERICAL_BIOT_SAVART Numerically evaluates the Biot-Savart law.
%
% The wire is divided into N small segments.
% The midpoint rule is used for the line integral.

    % Divide the wire into N equal intervals.
    z_edges = linspace(z1, z2, N + 1);

    % Midpoint coordinate of each integration segment.
    z_values = 0.5 * (z_edges(1:end-1) + z_edges(2:end));

    % Segment length.
    %
    % Equation:
    % dl = dz * z_hat.
    dz = (z2 - z1) / N;

    % Position vectors of the source points on the wire.
    source = [A(1)*ones(1,N);
              A(2)*ones(1,N);
              A(3) + z_values];

    % Vector from each source point to P.
    %
    % Equation:
    % R = P - r'.
    R = P(:) - source;

    % Magnitude of each source-to-observation vector.
    %
    % Equation:
    % R_mag = sqrt(Rx^2 + Ry^2 + Rz^2).
    R_mag = sqrt(sum(R.^2, 1));

    % Current element vector.
    %
    % Equation:
    % dl = [0, 0, dz].
    dl = [zeros(1,N);
          zeros(1,N);
          dz*ones(1,N)];

    % Cross product dl x R for every integration point.
    %
    % Equation:
    % dB = (mu0*I/(4*pi)) * (dl x R) / |R|^3.
    dl_cross_R = cross(dl.', R.', 2).';

    dB = (mu0*I/(4*pi)) * ...
         dl_cross_R ./ (ones(3,1) * R_mag.^3);

    % Sum all differential contributions.
    %
    % Equation:
    % B = integral(dB) approximately sum(dB).
    B = sum(dB, 2).';

end


%% Local function: 3-D plot

function plot_field_geometry(A, P, z1, z2, B)
%PLOT_FIELD_GEOMETRY Plots the wire, its center A, P, and B.

    figure('Color', 'w');
    hold on;
    grid on;

    % Wire coordinates.
    z_wire = linspace(z1, z2, 200);
    x_wire = A(1) * ones(size(z_wire));
    y_wire = A(2) * ones(size(z_wire));

    % Plot the conductor.
    plot3(x_wire, y_wire, z_wire, 'k-', 'LineWidth', 2);

    % Plot A and P.
    plot3(A(1), A(2), A(3), 'bo', ...
        'MarkerSize', 8, 'MarkerFaceColor', 'b');

    plot3(P(1), P(2), P(3), 'rs', ...
        'MarkerSize', 8, 'MarkerFaceColor', 'r');

    % Draw B at P.
    %
    % The scaling factor is only for visual clarity. It does not
    % change the calculated magnetic field value.
    B_scale = 1e6;

    quiver3(P(1), P(2), P(3), ...
            B_scale*B(1), B_scale*B(2), B_scale*B(3), ...
            0, 'LineWidth', 2, 'MaxHeadSize', 0.5);

    % Labels and plot formatting.
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');

    title('Magnetic Field of a Finite Straight Conductor');

    legend('Wire', 'A: wire center', 'P: observation point', ...
           'B at P', 'Location', 'best');

    axis equal;

    % Extend the view slightly so that the B vector is visible.
    view(3);

    hold off;

end