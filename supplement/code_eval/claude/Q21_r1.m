%% Magnetic flux density of a finite straight conductor (parallel to z)
clear; clc; close all;

%% ---------------- INPUTS ----------------
mu0 = 4*pi*1e-7;          % permeability of free space [H/m]
I   = 1;                 % current [A] (+z direction)
l   = 2;                  % conductor length [m]
A   = [0.25, 0.5, 0];    % wire start point A(Ax,Ay,Az) [m]
P   = [1, 1, 0];    % field point P(Px,Py,Pz) [m]

%% ---------------- WIRE ENDS ----------------
z1 = A(3);                % lower end
z2 = A(3) + l;            % upper end
% (If A is the wire's midpoint use: z1 = A(3)-l/2; z2 = A(3)+l/2;)

%% ---------------- B AT POINT P ----------------
rho_vec = [P(1)-A(1), P(2)-A(2), 0];   % perpendicular vector wire -> P
rho     = norm(rho_vec);
if rho == 0
    error('P lies on the wire axis: B is undefined (rho = 0).');
end

sin1 = (z1 - P(3)) / sqrt(rho^2 + (z1 - P(3))^2);
sin2 = (z2 - P(3)) / sqrt(rho^2 + (z2 - P(3))^2);

phi_hat = cross([0 0 1], rho_vec/rho); % direction of B (azimuthal)
Bmag    = mu0*I/(4*pi*rho) * (sin2 - sin1);
B       = Bmag * phi_hat;              % [T]

fprintf('B at P = [%.4e  %.4e  %.4e] T\n', B);
fprintf('|B|    = %.4e T\n', norm(B));

%% ---------------- PLOT ----------------
figure('Color','w'); hold on; grid on; axis equal;

% conductor
plot3([A(1) A(1)], [A(2) A(2)], [z1 z2], 'r-', 'LineWidth', 4);
plot3(A(1), A(2), z1, 'ko', 'MarkerFaceColor','k');
text(A(1), A(2), z1, '  A');

% field point
plot3(P(1), P(2), P(3), 'bo', 'MarkerFaceColor','b', 'MarkerSize', 8);
text(P(1), P(2), P(3), '  P');

% B vector at P (scaled for visibility)
scale = 0.5 * l / norm(B);
quiver3(P(1), P(2), P(3), B(1), B(2), B(3), scale, ...
        'Color',[0 0.6 0], 'LineWidth', 2, 'MaxHeadSize', 0.8);

% perpendicular distance line from wire to P
plot3([A(1) P(1)], [A(2) P(2)], [P(3) P(3)], 'k--');

% circle of B-field direction around the wire at height Pz (visual aid)
th = linspace(0, 2*pi, 200);
plot3(A(1)+rho*cos(th), A(2)+rho*sin(th), P(3)*ones(size(th)), ...
      'Color',[0.6 0.6 0.6]);

xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title(sprintf('B at P: |B| = %.3e T, I = %g A, l = %g m', norm(B), I, l));
legend('Conductor','','','P','B vector','Location','best');
view(35, 25);
hold off;