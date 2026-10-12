%% Magnetic field of a finite straight conductor
% The conductor:
%   - has length l
%   - carries current I
%   - is centered at point A = [Ax, Ay, Az]
%   - is oriented parallel to the z-axis
%
% The magnetic field at point P is calculated from the Biot-Savart law:
%
%       dB = (mu0 / 4*pi) * I * (dl x R) / |R|^3
%
% where:
%   dl = differential element of the conductor
%   R  = vector from the current element to P
%
% The integral is evaluated numerically.

clear;
clc;
close all;

%% -------------------- Input parameters --------------------

% Current and conductor length
I = 1;                  % Current [A]
l = 2;                  % Conductor length [m]

% Position of the center of the conductor, A
Ax = 0.25;
Ay = 0.5;
Az = 0;

% Observation point P
Px = 1;
Py = 1;
Pz = 0;

% Permeability of free space
mu0 = 4*pi*1e-7;        % [H/m]

% Number of integration elements
N = 10000;

%% -------------------- Discretize the conductor --------------------

% The conductor extends from z = Az-l/2 to z = Az+l/2.
z = linspace(Az - l/2, Az + l/2, N);

% Differential length along the z-axis
dz = l/(N-1);

% Coordinates of the current elements
x_wire = Ax * ones(size(z));
y_wire = Ay * ones(size(z));

%% -------------------- Biot-Savart calculation --------------------

% Vector from every current element to observation point P:
Rx = Px - x_wire;
Ry = Py - y_wire;
Rz = Pz - z;

% Distance from each current element to P
R = sqrt(Rx.^2 + Ry.^2 + Rz.^2);

% Since the conductor is parallel to the z-axis:
%     dl = [0, 0, dz]
%
% Therefore:
%     dl x R = [-Ry*dz, Rx*dz, 0]

dBx = (mu0/(4*pi)) * I .* (-Ry) ./ R.^3 * dz;
dBy = (mu0/(4*pi)) * I .* ( Rx) ./ R.^3 * dz;
dBz = zeros(size(dBx));

% Numerically integrate all differential contributions
Bx = sum(dBx);
By = sum(dBy);
Bz = sum(dBz);

% Magnetic-field vector
B = [Bx, By, Bz];

%% -------------------- Display result --------------------

fprintf('Magnetic field at P:\n');
fprintf('Bx = %.6e T\n', Bx);
fprintf('By = %.6e T\n', By);
fprintf('Bz = %.6e T\n', Bz);
fprintf('|B| = %.6e T\n', norm(B));

%% -------------------- 3D visualization --------------------

figure('Color','w');
hold on;
grid on;
axis equal;
view(3);

% Plot the finite conductor
plot3(x_wire, y_wire, z, 'k-', 'LineWidth', 4);

% Plot point A (center of conductor)
plot3(Ax, Ay, Az, 'ko', ...
    'MarkerFaceColor','k', 'MarkerSize',7);

% Plot observation point P
plot3(Px, Py, Pz, 'ro', ...
    'MarkerFaceColor','r', 'MarkerSize',8);

% Scale factor for displaying the B vector.
% This is only for visualization; it does not change the calculated B.
vectorScale = 0.5 / norm(B);

% Plot magnetic-field vector using quiver3
quiver3(Px, Py, Pz, ...
        Bx*vectorScale, By*vectorScale, Bz*vectorScale, ...
        0, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

% Labels and title
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
title('Magnetic Field of a Finite Straight Current-Carrying Conductor');

legend('Conductor', 'Point A', 'Observation Point P', ...
       'Magnetic field B', 'Location','best');

hold off;