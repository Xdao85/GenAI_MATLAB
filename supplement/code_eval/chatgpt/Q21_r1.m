%% Magnetic flux density B due to a finite straight conductor
% Conductor: length l, current I, parallel to z-axis
% A = (Ax, Ay, Az) : center of conductor
% P = (Px, Py, Pz) : observation point

clear; clc; close all;

%% Parameters
mu0 = 4*pi*1e-7;      % Permeability of free space (H/m)

I  = 1;              % Current (A)
l  = 2;               % Conductor length (m)

Ax = 0.25;
Ay = 0.5;
Az = 0;

% Observation point
Px = 1;
Py = 1;
Pz = 0;

%% Conductor endpoints
z1 = Az - l/2;
z2 = Az + l/2;

%% Magnetic field at point P
dx = Px - Ax;
dy = Py - Ay;

rho2 = dx^2 + dy^2;
rho  = sqrt(rho2);

% Avoid division by zero if P lies on the conductor axis
if rho < 1e-12
    error('Observation point P cannot lie on the conductor axis.');
end

R1 = sqrt(rho2 + (z1 - Pz)^2);
R2 = sqrt(rho2 + (z2 - Pz)^2);

% Integral factor
F = (z2 - Pz)/R2 - (z1 - Pz)/R1;

% B = (mu0*I/4*pi*rho^2) * (zhat x rho_vector) * F
Bx = -mu0*I/(4*pi*rho2) * dy * F;
By =  mu0*I/(4*pi*rho2) * dx * F;
Bz = 0;

Bmag = sqrt(Bx^2 + By^2 + Bz^2);

%% Display result
fprintf('Magnetic flux density at P:\n');
fprintf('Bx = %.6e T\n', Bx);
fprintf('By = %.6e T\n', By);
fprintf('Bz = %.6e T\n', Bz);
fprintf('|B| = %.6e T\n', Bmag);

%% Create 3D grid for visualization
N = 8;

x = linspace(Ax-2, Ax+2, N);
y = linspace(Ay-2, Ay+2, N);
z = linspace(Az-l, Az+l, N);

[X,Y,Z] = meshgrid(x,y,z);

DX = X - Ax;
DY = Y - Ay;
RHO2 = DX.^2 + DY.^2;

% Prevent singularity on conductor axis
RHO2(RHO2 < 1e-8) = NaN;

Z1 = z1 - Z;
Z2 = z2 - Z;

R1 = sqrt(RHO2 + Z1.^2);
R2 = sqrt(RHO2 + Z2.^2);

F = Z2./R2 - Z1./R1;

Bx_grid = -mu0*I/(4*pi) .* DY ./ RHO2 .* F;
By_grid =  mu0*I/(4*pi) .* DX ./ RHO2 .* F;
Bz_grid = zeros(size(Bx_grid));

%% Plot magnetic field vectors
figure('Color','w');

quiver3(X,Y,Z,Bx_grid,By_grid,Bz_grid, ...
        'AutoScaleFactor',1.5);

hold on;
grid on;
axis equal;

%% Plot conductor
plot3(Ax, Ay, [z1 z2], ...
      'LineWidth', 5);

%% Plot point A (center)
plot3(Ax, Ay, Az, 'o', ...
      'MarkerSize', 8, ...
      'MarkerFaceColor','k');

%% Plot observation point P
plot3(Px, Py, Pz, 'o', ...
      'MarkerSize', 10, ...
      'MarkerFaceColor','r');

%% Plot B vector at P
scaleB = 0.5 / Bmag;

quiver3(Px,Py,Pz, ...
        Bx*scaleB, By*scaleB, Bz*scaleB, ...
        0, 'LineWidth', 2);

%% Labels
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');

title('Magnetic Flux Density \bfB\rm of a Finite Straight Conductor');

legend('B field','Conductor','A','P','B at P', ...
       'Location','best');

view(35,25);