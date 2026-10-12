%% Magnetic Field of a Finite Straight Current-Carrying Conductor
% The conductor:
%   - has length l
%   - is centered at point A(Ax, Ay, Az)
%   - is parallel to the z-axis
%   - carries current I in the +z direction
%
% The magnetic field B at point P(Px, Py, Pz) is calculated
% using the Biot-Savart law:
%
%       dB = (mu0 / 4*pi) * I * (dl x R) / |R|^3
%
% where:
%   dl = differential current element
%   R  = vector from the current element to observation point P

clear;
clc;
close all;

%% ------------------------------------------------------------
% 1. Physical parameters
% ------------------------------------------------------------

mu0 = 4*pi*1e-7;       % Permeability of free space [H/m]

I = 1;                 % Current [A]
l = 2;                 % Conductor length [m]

% Position of the center point A of the conductor
Ax = 0.25;
Ay = 0.5;
Az = 0;

A = [Ax, Ay, Az];

% Observation point P
Px = 1.0;
Py = 1.0;
Pz = 0;

P = [Px, Py, Pz];

%% ------------------------------------------------------------
% 2. Define the finite conductor
% ------------------------------------------------------------

% The conductor is parallel to the z-axis and centered at A.
%
% Therefore:
%
%       z_start = Az - l/2
%       z_end   = Az + l/2

z_start = Az - l/2;
z_end   = Az + l/2;

% Number of integration elements
N = 10000;

% Divide the conductor into small current elements
z = linspace(z_start, z_end, N);

dz = (z_end - z_start)/(N-1);

%% ------------------------------------------------------------
% 3. Calculate the magnetic field using Biot-Savart law
% ------------------------------------------------------------

% Initialize magnetic field vector
B = [0, 0, 0];

for n = 1:N

    % Position of the current element
    r_source = [Ax, Ay, z(n)];

    % Vector from current element to observation point P
    R = P - r_source;

    % Distance from source element to P
    R_mag = norm(R);

    % Differential current element
    %
    % Current flows in +z direction:
    %
    %       dl = dz * z_hat
    %
    dl = [0, 0, dz];

    % Biot-Savart differential magnetic field
    dB = (mu0/(4*pi)) * I * cross(dl, R) / R_mag^3;

    % Accumulate magnetic field
    B = B + dB;

end

%% ------------------------------------------------------------
% 4. Display magnetic field vector
% ------------------------------------------------------------

fprintf('Observation point P = (%.3f, %.3f, %.3f) m\n', ...
    Px, Py, Pz);

fprintf('\nMagnetic field vector:\n');
fprintf('Bx = %.6e T\n', B(1));
fprintf('By = %.6e T\n', B(2));
fprintf('Bz = %.6e T\n', B(3));

fprintf('\n|B| = %.6e T\n', norm(B));

%% ------------------------------------------------------------
% 5. Plot the conductor and observation point
% ------------------------------------------------------------

figure('Color','w');
hold on;
grid on;
axis equal;

%% Plot the conductor

plot3(Ax*ones(size(z)), ...
      Ay*ones(size(z)), ...
      z, ...
      'k-', ...
      'LineWidth', 4);

%% Plot center point A

plot3(Ax, Ay, Az, ...
      'ko', ...
      'MarkerSize', 8, ...
      'MarkerFaceColor', 'k');

%% Plot observation point P

plot3(Px, Py, Pz, ...
      'ro', ...
      'MarkerSize', 10, ...
      'MarkerFaceColor', 'r');

%% ------------------------------------------------------------
% 6. Plot current direction
% ------------------------------------------------------------

% Draw an arrow showing current direction +z
quiver3(Ax, Ay, Az-l/4, ...
        0, 0, l/3, ...
        0, ...
        'Color', 'b', ...
        'LineWidth', 2, ...
        'MaxHeadSize', 0.5);

text(Ax, Ay, Az-l/4, ...
     '  I (+z)', ...
     'FontSize', 12, ...
     'Color', 'b');

%% ------------------------------------------------------------
% 7. Plot magnetic field vector B at P
% ------------------------------------------------------------

% Scale factor only for visualization.
% It does NOT change the calculated magnetic field.
B_scale = 1e6;

quiver3(Px, Py, Pz, ...
        B_scale*B(1), ...
        B_scale*B(2), ...
        B_scale*B(3), ...
        0, ...
        'Color', 'm', ...
        'LineWidth', 3, ...
        'MaxHeadSize', 0.5);

%% Label the magnetic-field vector

text(Px + B_scale*B(1), ...
     Py + B_scale*B(2), ...
     Pz + B_scale*B(3), ...
     '  B', ...
     'FontSize', 14, ...
     'FontWeight', 'bold', ...
     'Color', 'm');

%% ------------------------------------------------------------
% 8. Plot coordinate axes
% ------------------------------------------------------------

axis_length = l;

quiver3(0,0,0, axis_length,0,0, ...
        0, 'r', 'LineWidth', 1.5);

quiver3(0,0,0, 0,axis_length,0, ...
        0, 'g', 'LineWidth', 1.5);

quiver3(0,0,0, 0,0,axis_length, ...
        0, 'b', 'LineWidth', 1.5);

text(axis_length,0,0,'  x');
text(0,axis_length,0,'  y');
text(0,0,axis_length,'  z');

%% ------------------------------------------------------------
% 9. Figure formatting
% ------------------------------------------------------------

xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');

title('Magnetic Field of a Finite Straight Current-Carrying Conductor');

legend('Conductor', ...
       'Center A', ...
       'Observation Point P', ...
       'Current Direction', ...
       'Magnetic Field B', ...
       'Location', 'best');

view(35,25);

hold off;

% Thêm 
view(120,45)