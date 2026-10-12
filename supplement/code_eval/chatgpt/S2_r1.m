% Finite straight conductor: magnetic field at an observation point
% Undergraduate electromagnetics example
%
% All quantities are in SI units.
% The conductor carries current in the +z direction.
%
% Geometry:
%   Wire center A = (0.25, 0.5, 0) m
%   Wire length l = 2 m
%   Wire extends from z = -1 m to z = +1 m
%   Observation point P = (1, 1, 0) m
%   Current I = 1 A
%
% The script:
%   1. Computes B using the closed-form finite-wire formula.
%   2. Computes B independently using numerical Biot-Savart integration.
%   3. Compares the two vectors.
%   4. Checks the right-hand-rule direction.
%   5. Stops if the vector error exceeds 0.1 percent.
%   6. Plots the geometry and magnetic-field vector.

clear;
clc;
close all;

%% Constants and geometry

mu0 = 4*pi*1e-7;       % Permeability of free space, H/m
I = 1.0;               % Current, A
L = 2.0;               % Wire length, m

A = [0.25, 0.50, 0.00]; % Center of the wire, m
P = [1.00, 1.00, 0.00]; % Observation point, m

% Unit vector in the direction of current.
Ihat = [0, 0, 1];

% Wire endpoints.
z1 = -L/2;
z2 =  L/2;

% Endpoint coordinates.
R1 = A + [0, 0, z1];
R2 = A + [0, 0, z2];

%% Closed-form solution

% B_ref is obtained from the exact finite straight-wire expression.
B_ref = finiteWireB(mu0, I, A, z1, z2, P);

%% Numerical Biot-Savart solution

% Number of integration segments.
N = 100000;

% B_num is obtained independently by numerical integration.
B_num = numericalBiotSavart(mu0, I, A, z1, z2, P, N);

%% Compare the two solutions

% Vector error is the norm of the difference divided by the reference norm.
vectorError = norm(B_num - B_ref) / norm(B_ref);

% Print both magnetic-field vectors.
fprintf('Finite-wire closed-form solution:\n');
fprintf('B_ref = [% .8e, % .8e, % .8e] T\n', ...
    B_ref(1), B_ref(2), B_ref(3));
fprintf('|B_ref| = %.8e T\n\n', norm(B_ref));

fprintf('Numerical Biot-Savart solution:\n');
fprintf('B_num = [% .8e, % .8e, % .8e] T\n', ...
    B_num(1), B_num(2), B_num(3));
fprintf('|B_num| = %.8e T\n\n', norm(B_num));

fprintf('Relative vector error = %.6e (%.6f%%)\n', ...
    vectorError, 100*vectorError);

%% Right-hand-rule check

% The perpendicular displacement from the wire axis to P is:
% R_perp = P - A, with the z component removed.
R_perp = P - A;
R_perp(3) = 0;

% For current in the +z direction, the right-hand rule gives a field
% direction proportional to cross(Ihat, R_perp).
B_rhr_direction = cross(Ihat, R_perp);

% Normalize the expected direction.
B_rhr_direction = B_rhr_direction / norm(B_rhr_direction);

% Normalize the computed field direction.
B_direction = B_ref / norm(B_ref);

% The dot product should be approximately +1 for the correct direction.
rhrDot = dot(B_direction, B_rhr_direction);

fprintf('\nRight-hand-rule check:\n');
fprintf('Expected direction = [% .6f, % .6f, % .6f]\n', ...
    B_rhr_direction(1), B_rhr_direction(2), B_rhr_direction(3));
fprintf('Computed direction = [% .6f, % .6f, % .6f]\n', ...
    B_direction(1), B_direction(2), B_direction(3));
fprintf('Direction dot product = %.6f\n', rhrDot);

if rhrDot > 0.999999
    fprintf('Right-hand rule check: PASS\n');
else
    fprintf('Right-hand rule check: FAIL\n');
end

%% Error check

% The maximum permitted relative vector error is 0.1 percent.
errorLimit = 0.001;

if vectorError > errorLimit
    error('Vector error exceeds 0.1 percent. Numerical solution failed.');
else
    fprintf('\nVector error check: PASS (error <= 0.1%%)\n');
end

%% Plot geometry and magnetic field

plotEMGeometry(A, R1, R2, P, B_ref);

%% Local functions

function B = finiteWireB(mu0, I, A, z1, z2, P)
%FINITEWIREB Magnetic field of a finite straight conductor.
%
% The wire is parallel to the z axis and passes through A.
% z1 and z2 are the endpoint z coordinates relative to A.
%
% For a straight wire, the finite-wire result is
%
%   B = (mu0*I/(4*pi*rho))*(sin(theta1) + sin(theta2))*phi_hat
%
% where rho is the perpendicular distance from the wire axis to P,
% and theta1 and theta2 are the angles subtended by the two endpoints.
%
% For this geometry:
%
%   rho = sqrt((Px-Ax)^2 + (Py-Ay)^2)
%
% and
%
%   sin(theta_i) = z_i / sqrt(rho^2 + z_i^2)
%
% The azimuthal unit vector follows from the right-hand rule:
%
%   phi_hat = z_hat x rho_hat

    % Perpendicular displacement from the wire axis to P.
    Rperp = [P(1)-A(1), P(2)-A(2), 0];

    % Perpendicular distance from the wire axis to P.
    rho = norm(Rperp);

    % Stop if the observation point lies on the wire axis.
    if rho == 0
        error('Observation point lies on the wire axis.');
    end

    % Unit vector from the wire axis toward the observation point.
    rho_hat = Rperp / rho;

    % Unit vector in the +z direction.
    z_hat = [0, 0, 1];

    % Right-hand-rule azimuthal direction.
    phi_hat = cross(z_hat, rho_hat);

    % Sine of the angle associated with the lower endpoint.
    sinTheta1 = z1 / sqrt(rho^2 + z1^2);

    % Sine of the angle associated with the upper endpoint.
    sinTheta2 = z2 / sqrt(rho^2 + z2^2);

    % Closed-form finite-wire magnetic-field magnitude.
    Bmag = (mu0*I/(4*pi*rho)) * (sinTheta2 - sinTheta1);

    % Magnetic-field vector.
    B = Bmag * phi_hat;
end

function B = numericalBiotSavart(mu0, I, A, z1, z2, P, N)
%NUMERICALBIOTSAVART Numerical Biot-Savart integration.
%
% The differential Biot-Savart law is
%
%   dB = (mu0/(4*pi))*I*(dl x R)/|R|^3
%
% where:
%   dl is a differential current-element vector,
%   R is the vector from the current element to P.
%
% For a wire parallel to +z:
%
%   dl = dz*z_hat
%
% The integral is evaluated numerically using the midpoint rule.

    % Width of each integration segment.
    dz = (z2 - z1) / N;

    % Initialize the magnetic-field vector.
    B = [0, 0, 0];

    % Unit vector in the current direction.
    z_hat = [0, 0, 1];

    % Loop over all wire segments.
    for k = 1:N

        % Midpoint coordinate of the current element.
        z = z1 + (k - 0.5)*dz;

        % Position of the current element.
        source = A + [0, 0, z];

        % Vector from the source point to the observation point.
        R = P - source;

        % Magnitude of the source-to-observation vector.
        Rmag = norm(R);

        % Differential current-element vector.
        dl = dz * z_hat;

        % Biot-Savart differential field.
        dB = (mu0/(4*pi)) * I * cross(dl, R) / Rmag^3;

        % Add the differential contribution to the total field.
        B = B + dB;
    end
end

function plotEMGeometry(A, R1, R2, P, B)
%PLOTEMGEOMETRY Plot the conductor, center A, observation point P, and B.
%
% The magnetic field is displayed using quiver3.
% The field arrow is scaled for visualization only.

    figure('Color', 'w');
    hold on;
    grid on;
    box on;

    % Plot the straight conductor.
    plot3([R1(1), R2(1)], ...
          [R1(2), R2(2)], ...
          [R1(3), R2(3)], ...
          'k-', 'LineWidth', 3);

    % Plot the center point A.
    plot3(A(1), A(2), A(3), ...
          'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');

    % Plot the observation point P.
    plot3(P(1), P(2), P(3), ...
          'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

    % Scale the magnetic-field vector for display.
    % The scale has no physical meaning; it is only for visualization.
    BplotScale = 0.25 / norm(B);

    % Plot the magnetic-field vector at P.
    quiver3(P(1), P(2), P(3), ...
            BplotScale*B(1), ...
            BplotScale*B(2), ...
            BplotScale*B(3), ...
            0, 'LineWidth', 2, 'MaxHeadSize', 0.5);

    % Label the coordinate axes with SI units.
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');

    % Add a descriptive title.
    title('Magnetic field of a finite straight conductor');

    % Add a legend.
    legend('Conductor', 'A', 'P', 'B direction', ...
           'Location', 'best');

    % Use equal scaling on all coordinate axes.
    axis equal;

    % Set a useful viewing angle.
    view(35, 25);

    hold off;
end