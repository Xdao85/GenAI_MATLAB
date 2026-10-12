%% Magnetic flux density of a finite straight conductor parallel to z-axis
clear; clc; close all;

%% ---------------- INPUTS ----------------
mu0 = 4*pi*1e-7;          % permeability of free space [H/m]
I   = 1;                 % current [A] (flows in +z direction)
l   = 2;                  % conductor length [m]
A   = [0.25, 0.5, 0];         % start point of conductor A(Ax,Ay,Az) [m]
P   = [1, 1,  0];       % field point P(Px,Py,Pz) [m]

%% ---------------- CALCULATION ----------------
Ax = A(1); Ay = A(2); Az = A(3);
Px = P(1); Py = P(2); Pz = P(3);

dx  = Px - Ax;
dy  = Py - Ay;
rho = hypot(dx, dy);                 % perpendicular distance to wire axis

if rho < 1e-9
    error('P lies on the wire axis: B is undefined (singular).');
end

% z-limits of the wire measured relative to P
z1 = Az     - Pz;                    % lower end
z2 = Az + l - Pz;                    % upper end

sin_a1 = z1 / sqrt(rho^2 + z1^2);
sin_a2 = z2 / sqrt(rho^2 + z2^2);

Bmag = mu0*I/(4*pi*rho) * (sin_a2 - sin_a1);   % magnitude [T]

% Direction: phi_hat = z_hat x rho_hat = (-dy, dx, 0)/rho
phi_hat = [-dy, dx, 0] / rho;
B = Bmag * phi_hat;                  % vector [T]

fprintf('rho  = %.4f m\n', rho);
fprintf('|B|  = %.4e T  (%.4f uT)\n', abs(Bmag), abs(Bmag)*1e6);
fprintf('B    = [%.4e, %.4e, %.4e] T\n', B);

%% ---------------- PLOT ----------------
figure('Color','w'); hold on; grid on; box on;

% Conductor
plot3([Ax Ax], [Ay Ay], [Az Az+l], 'r-', 'LineWidth', 4);
% Current direction arrow (at the middle of the wire)
quiver3(Ax, Ay, Az+l/2, 0, 0, l/4, 'r', 'LineWidth', 2, ...
        'MaxHeadSize', 2, 'AutoScale', 'off');

% Field point
plot3(Px, Py, Pz, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
text(Px, Py, Pz, '  P', 'FontWeight', 'bold');
text(Ax, Ay, Az, '  A', 'FontWeight', 'bold');

% Perpendicular from wire axis to P (in the plane z = Pz)
plot3([Ax Px], [Ay Py], [Pz Pz], 'k--');

% B vector at P (scaled for visibility)
scale = 0.3*max(rho, l) / max(norm(B), eps);
quiver3(Px, Py, Pz, B(1)*scale, B(2)*scale, B(3)*scale, 0, ...
        'b', 'LineWidth', 2.5, 'MaxHeadSize', 1.5);
text(Px + B(1)*scale, Py + B(2)*scale, Pz, ...
     sprintf('  B = %.2f \\muT', abs(Bmag)*1e6), 'Color', 'b', 'FontWeight', 'bold');

% Circular field line through P (centered on wire, in plane z = Pz)
th = linspace(0, 2*pi, 200);
plot3(Ax + rho*cos(th), Ay + rho*sin(th), Pz*ones(size(th)), ...
      'Color', [0.5 0.5 1], 'LineStyle', ':');

xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title('Magnetic flux density of a finite current-carrying conductor');
legend('Conductor','Current direction','Point P','','Perpendicular', ...
       'B vector','Field line','Location','best');
axis equal; view(35, 25);
hold off;

% Thêm 
view(120,45)