%% Magnetic field of a finite straight current-carrying conductor
% The conductor is a free-standing straight wire of length l,
% centered at point A = [Ax, Ay, Az] and oriented parallel to the z-axis.
%
% The magnetic field at point P = [Px, Py, Pz] is calculated using
% the Biot-Savart law:
%
%       dB = (mu0 / 4*pi) * I * (dl x R) / |R|^3
%
% where:
%   dl = differential current-element vector
%   R  = vector from the current element to observation point P
%   mu0 = permeability of free space

clear;
clc;
close all;

%% -------------------- Input parameters ------------------------------

% Permeability of free space
mu0 = 4*pi*1e-7;          % H/m

% Current and conductor length
I = 10;                   % Current [A]
l = 2;                    % Conductor length [m]

% Coordinates of conductor center A = [Ax, Ay, Az]
Ax = 0;
Ay = 0;
Az = 0;

% Observation point P = [Px, Py, Pz]
Px = 1;
Py = 1;
Pz = 0.5;

%% -------------------- Numerical integration -------------------------

% Number of segments used to approximate the conductor
N = 10000;

% Position along the conductor measured from its center
z = linspace(-l/2, l/2, N);

% Differential length
dz = z(2) - z(1);

% Coordinates of each current element
x_wire = Ax * ones(size(z));
y_wire = Ay * ones(size(z));
z_wire = Az + z;

% Initialize magnetic field vector
B = [0, 0, 0];

% Unit vector along the current direction (+z)
z_hat = [0, 0, 1];

% Numerically integrate the Biot-Savart law
for k = 1:N

    % Position of the current element
    r_source = [x_wire(k), y_wire(k), z_wire(k)];

    % Vector from current element to observation point P
    R = [Px, Py, Pz] - r_source;

    % Distance from current element to P
    Rmag = norm(R);

    % Differential current-element vector
    dl = z_hat * dz;

    % Differential magnetic field
    dB = (mu0/(4*pi)) * I * cross(dl, R) / Rmag^3;

    % Accumulate magnetic field
    B = B + dB;
end

%% -------------------- Display result --------------------------------

fprintf('Magnetic field at P = [%.3f, %.3f, %.3f] m:\n', Px, Py, Pz);
fprintf('Bx = %.6e T\n', B(1));
fprintf('By = %.6e T\n', B(2));
fprintf('Bz = %.6e T\n', B(3));
fprintf('|B| = %.6e T\n', norm(B));

%% -------------------- 3D visualization ------------------------------

figure('Color','w');
hold on;
grid on;
axis equal;

% Plot the conductor
plot3(x_wire, y_wire, z_wire, 'k-', 'LineWidth', 3);

% Mark point A (center of conductor)
plot3(Ax, Ay, Az, 'ko', ...
    'MarkerFaceColor','k', 'MarkerSize',7);

% Mark observation point P
plot3(Px, Py, Pz, 'ro', ...
    'MarkerFaceColor','r', 'MarkerSize',8);

% Scale the B vector for easier visualization.
% The scaling is only for plotting and does not change the calculated B.
BplotScale = 1e6;

% Plot magnetic-field vector using quiver3
quiver3(Px, Py, Pz, ...
        BplotScale*B(1), ...
        BplotScale*B(2), ...
        BplotScale*B(3), ...
        0, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

% Label the points
text(Ax, Ay, Az, '  A', 'FontSize', 12);
text(Px, Py, Pz, '  P', 'FontSize', 12, 'Color','r');

% Coordinate axes
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');

title('Magnetic Field of a Finite Straight Current-Carrying Conductor');

legend('Conductor', 'Point A', 'Observation point P', ...
       'Magnetic field B', 'Location','best');

view(3);
hold off;