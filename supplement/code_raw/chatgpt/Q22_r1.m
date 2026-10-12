%% Magnetic field of a finite straight conductor
% The conductor is a free-standing straight wire of length l carrying
% current I. Its center is located at A = [Ax, Ay, Az] and it is
% oriented parallel to the z-axis.
%
% The magnetic field at point P = [Px, Py, Pz] is calculated using
% the Biot-Savart law:
%
%       dB = (mu0 / 4*pi) * I * (dl x R) / |R|^3
%
% where:
%       dl = differential current-element vector
%       R  = vector from the current element to P
%
% The integral is evaluated numerically using the trapezoidal rule.

clear;
clc;
close all;

%% -------------------- Input parameters -----------------------------

% Physical constants
mu0 = 4*pi*1e-7;       % Permeability of free space [H/m]

% Conductor parameters
I  = 10;               % Current [A]
l  = 2;                % Conductor length [m]

% Point A: center of the conductor
Ax = 0;
Ay = 0;
Az = 0;

A = [Ax, Ay, Az];

% Observation point P
Px = 1.0;
Py = 0.5;
Pz = 0.8;

P = [Px, Py, Pz];

%% -------------------- Discretize conductor -------------------------

% Number of segments used for numerical integration
N = 10000;

% z-coordinate of current elements
z = linspace(Az - l/2, Az + l/2, N);

% Differential element length
dz = z(2) - z(1);

% Coordinates of current elements
xWire = Ax * ones(size(z));
yWire = Ay * ones(size(z));

%% -------------------- Biot-Savart calculation ----------------------

% Vector R from every current element to observation point P
Rx = Px - xWire;
Ry = Py - yWire;
Rz = Pz - z;

% Magnitude of R
Rmag = sqrt(Rx.^2 + Ry.^2 + Rz.^2);

% Current element vector:
% dl = [0, 0, dz], since the wire is parallel to the z-axis.
%
% Cross product:
%       dl x R = [-dz*Ry, dz*Rx, 0]

dBx = (mu0/(4*pi)) * I .* (-Ry) ./ Rmag.^3;
dBy = (mu0/(4*pi)) * I .* ( Rx) ./ Rmag.^3;
dBz = zeros(size(z));

% Numerically integrate the contributions along the wire
Bx = trapz(z, dBx);
By = trapz(z, dBy);
Bz = trapz(z, dBz);

% Magnetic-field vector
B = [Bx, By, Bz];

%% -------------------- Display result -------------------------------

fprintf('Magnetic field at P = [%.3f, %.3f, %.3f] m:\n', ...
        Px, Py, Pz);

fprintf('Bx = %.6e T\n', Bx);
fprintf('By = %.6e T\n', By);
fprintf('Bz = %.6e T\n', Bz);

fprintf('|B| = %.6e T\n', norm(B));

%% -------------------- 3D visualization -----------------------------

figure('Color','w');
hold on;
grid on;
axis equal;

% Plot the conductor
plot3(xWire, yWire, z, 'k-', 'LineWidth', 4);

% Mark point A (center of conductor)
plot3(Ax, Ay, Az, 'ko', ...
    'MarkerFaceColor','k', ...
    'MarkerSize',7);

% Mark observation point P
plot3(Px, Py, Pz, 'ro', ...
    'MarkerFaceColor','r', ...
    'MarkerSize',8);

% Scale the B vector for visualization.
% This scale factor is only for display and does not change the
% calculated magnetic-field value.
BplotScale = 0.5 / norm(B);

% Plot magnetic-field vector using quiver3
quiver3(Px, Py, Pz, ...
        BplotScale*Bx, ...
        BplotScale*By, ...
        BplotScale*Bz, ...
        0, ...                  % Do not automatically rescale vector
        'b', ...
        'LineWidth',2.5, ...
        'MaxHeadSize',0.8);

% Labels
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');

title('Magnetic Field of a Finite Straight Conductor');

legend('Conductor', 'Point A', 'Observation Point P', ...
       'Magnetic Field B', ...
       'Location','best');

% Display the magnetic-field components near P
text(Px, Py, Pz, sprintf('  P\\n  B = [%.2e, %.2e, %.2e] T', ...
     Bx, By, Bz), ...
     'FontSize',10);

view(35,25);
hold off;