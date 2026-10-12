%% Magnetic flux density of a finite straight conductor parallel to z-axis
clear; clc; close all;

%% ---------------- INPUTS ----------------
mu0 = 4*pi*1e-7;          % permeability of free space [H/m]
I   = 10;                 % current [A] (positive = +z direction)
l   = 4;                  % conductor length [m]
A   = [1, 2, 0];          % [Ax Ay Az] : starting point of the conductor
P   = [3, 4, 1.5];        % [Px Py Pz] : field point

%% ---------------- CALCULATION ----------------
% Conductor end points
z_bot = A(3);             % <-- ends (use A(3) - l/2 if A is the midpoint)
z_top = A(3) + l;         % <-- ends (use A(3) + l/2 if A is the midpoint)

% Perpendicular (radial) vector from wire to P in the xy-plane
d   = [P(1)-A(1), P(2)-A(2)];
rho = norm(d);
if rho == 0
    error('P lies on the conductor axis: B is undefined (rho = 0).');
end
rho_hat = [d, 0] / rho;                 % radial unit vector
phi_hat = cross([0 0 1], rho_hat);      % azimuthal unit vector (right-hand rule)

% Heights of the ends relative to the field point
z1 = z_bot - P(3);
z2 = z_top - P(3);

sin1 = z1 / sqrt(rho^2 + z1^2);
sin2 = z2 / sqrt(rho^2 + z2^2);

Bmag = mu0*I/(4*pi*rho) * (sin2 - sin1);   % signed magnitude [T]
B    = Bmag * phi_hat;                     % vector [T]

fprintf('rho = %.4f m\n', rho);
fprintf('B   = [%.4e  %.4e  %.4e] T\n', B);
fprintf('|B| = %.4e T\n', norm(B));

%% ---------------- PLOT ----------------
figure('Color','w'); hold on; grid on; axis equal; view(35,25);

% Conductor
plot3([A(1) A(1)], [A(2) A(2)], [z_bot z_top], 'r-', 'LineWidth', 4);
plot3(A(1), A(2), z_bot, 'ro', 'MarkerFaceColor','r');
plot3(A(1), A(2), z_top, 'ro', 'MarkerFaceColor','r');
quiver3(A(1), A(2), (z_bot+z_top)/2, 0, 0, l*0.2, 0, ...
        'r', 'LineWidth', 2, 'MaxHeadSize', 2);   % current direction

% Field point
plot3(P(1), P(2), P(3), 'bo', 'MarkerFaceColor','b', 'MarkerSize', 8);

% Perpendicular distance line (from wire to P's level)
foot = [A(1), A(2), P(3)];
plot3([foot(1) P(1)], [foot(2) P(2)], [foot(3) P(3)], 'k--');

% B vector at P (scaled for visibility)
scale = 0.3*l / max(norm(B), eps);
quiver3(P(1), P(2), P(3), B(1)*scale, B(2)*scale, B(3)*scale, 0, ...
        'b', 'LineWidth', 2.5, 'MaxHeadSize', 1.5);

% Circular field line through P (circle of radius rho around the wire)
th = linspace(0, 2*pi, 200);
plot3(A(1)+rho*cos(th), A(2)+rho*sin(th), P(3)*ones(size(th)), ...
      'Color',[0.6 0.6 1], 'LineStyle','-.');

% Labels
text(A(1), A(2), z_top, '  I', 'Color','r', 'FontSize', 12);
text(P(1), P(2), P(3), sprintf('  P (|B| = %.3e T)', norm(B)), ...
     'Color','b', 'FontSize', 11);
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title('Magnetic flux density of a finite straight conductor');
legend({'Conductor','','','Current dir.','Point P','\rho','B at P','Field circle'}, ...
       'Location','best');
hold off;