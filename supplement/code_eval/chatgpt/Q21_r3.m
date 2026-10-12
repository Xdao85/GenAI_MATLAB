%% Magnetic flux density of a finite straight conductor
clear; clc; close all;

% ---------------- Parameters ----------------
mu0 = 4*pi*1e-7;       % Permeability of free space (H/m)

I = 1;                % Current (A)
l = 2;                 % Conductor length (m)

% Position of conductor center A = (Ax, Ay, Az)
Ax = 0.25;
Ay = 0.5;
Az = 0;

% Observation point P = (Px, Py, Pz)
Px = 1;
Py = 1;
Pz = 0;

% ---------------- Numerical integration ----------------
N = 1000;                         % Number of current elements
z1 = Az - l/2;
z2 = Az + l/2;

z = linspace(z1,z2,N);
dz = z(2)-z(1);

% Current element positions
rx = Ax * ones(1,N);
ry = Ay * ones(1,N);
rz = z;

% Vector from current element to observation point P
Rx = Px - rx;
Ry = Py - ry;
Rz = Pz - rz;

R = sqrt(Rx.^2 + Ry.^2 + Rz.^2);

% dl = dz * z_hat
% dl x R = dz * (z_hat x R)
% z_hat x [Rx,Ry,Rz] = [-Ry,Rx,0]

dBx = (mu0*I/(4*pi)) .* (-Ry) ./ R.^3 * dz;
dBy = (mu0*I/(4*pi)) .* ( Rx) ./ R.^3 * dz;
dBz = zeros(size(dBx));

% Total magnetic flux density
Bx = sum(dBx);
By = sum(dBy);
Bz = sum(dBz);

B = [Bx By Bz];
Bmag = norm(B);

fprintf('Magnetic flux density at P:\n');
fprintf('Bx = %.6e T\n', Bx);
fprintf('By = %.6e T\n', By);
fprintf('Bz = %.6e T\n', Bz);
fprintf('|B| = %.6e T\n', Bmag);

%% ---------------- 3D visualization ----------------
figure;
hold on;
grid on;
axis equal;

% Plot conductor
plot3([Ax Ax], [Ay Ay], [z1 z2], ...
      'k-', 'LineWidth', 4);

% Plot point P
plot3(Px, Py, Pz, 'ro', ...
      'MarkerSize', 8, 'MarkerFaceColor', 'r');

% Plot magnetic field vector at P
scale = 1e6;   % Scaling for visualization
quiver3(Px, Py, Pz, ...
        scale*Bx, scale*By, scale*Bz, ...
        0, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');

title('Magnetic Flux Density of a Finite Straight Conductor');

legend('Conductor', 'Observation Point P', 'Magnetic Field B', ...
       'Location', 'best');

view(3);