%% Magnetic flux density of a finite straight conductor (parallel to z)
clear; clc; close all;

%% ---------------- User parameters ----------------
mu0 = 4*pi*1e-7;      % Permeability of free space (H/m)

I  = 1;              % Current (A)  -> +z direction
l  = 2;             % Length of conductor (m)

A  = [0.25, 0.5, 0]; % Center of the conductor A(Ax,Ay,Az)
P  = [1, 1, 0]; % Observation point P(Px,Py,Pz)

%% ---------------- Geometry ----------------
% Wire endpoints (parallel to z, centered at A)
z1 = A(3) - l/2;
z2 = A(3) + l/2;

% Perpendicular (radial) vector from wire axis to P
rho_vec = [P(1)-A(1), P(2)-A(2), 0];
rho     = norm(rho_vec);          % Perpendicular distance r

if rho < 1e-12
    error('Point P lies on the conductor axis. B is undefined (infinite).');
end

% Unit vector in the azimuthal (phi) direction:  phi_hat = z_hat x rho_hat
rho_hat = rho_vec / rho;
z_hat   = [0 0 1];
phi_hat = cross(z_hat, rho_hat);

% Longitudinal distances from P's projection to the wire ends
s1 = z1 - P(3);
s2 = z2 - P(3);

% Angles subtended by the ends
sin_t1 = s1 / sqrt(s1^2 + rho^2);
sin_t2 = s2 / sqrt(s2^2 + rho^2);

% Magnitude of B (Biot-Savart for finite wire)
Bmag = (mu0 * I) / (4*pi*rho) * (sin_t2 - sin_t1);

% Vector B
B = Bmag * phi_hat;

fprintf('Point P        : (%.3f, %.3f, %.3f) m\n', P);
fprintf('Conductor A    : (%.3f, %.3f, %.3f) m, length %.3f m\n', A, l);
fprintf('Perp. distance : %.4f m\n', rho);
fprintf('|B|            : %.6e T\n', Bmag);
fprintf('B vector       : (%.6e, %.6e, %.6e) T\n', B);

%% ---------------- 3D Plot ----------------
figure('Color','w');
hold on; grid on; axis equal;
view(45, 25);
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title(sprintf('Magnetic flux density B at P  (|B| = %.3e T)', Bmag));

% --- Plot the conductor ---
plot3([A(1) A(1)], [A(2) A(2)], [z1 z2], 'k-', 'LineWidth', 3);
plot3(A(1), A(2), A(3), 'ko', 'MarkerFaceColor','k');
text(A(1), A(2), z2, '  I (conductor)', 'FontSize', 10);

% Arrow to show current direction
quiver3(A(1), A(2), z2, 0, 0, 0.25, 0, ...
        'Color','k','LineWidth',1.5,'MaxHeadSize',0.8);

% --- Plot point P ---
plot3(P(1), P(2), P(3), 'ro', 'MarkerFaceColor','r', 'MarkerSize',8);
text(P(1), P(2), P(3), '  P', 'Color','r', 'FontSize', 11);

% --- Plot the B vector at P (scaled for visibility) ---
scaleB = 0.5 * l / max(Bmag, eps);   % auto-scale arrow length
quiver3(P(1), P(2), P(3), ...
        B(1)*scaleB, B(2)*scaleB, B(3)*scaleB, ...
        0, 'Color','b', 'LineWidth', 2, 'MaxHeadSize', 0.6);
text(P(1)+B(1)*scaleB, P(2)+B(2)*scaleB, P(3)+B(3)*scaleB, ...
     '  B', 'Color','b', 'FontSize', 11);

% --- Dashed line from wire axis to P (shows rho) ---
plot3([A(1) P(1)], [A(2) P(2)], [P(3) P(3)], '--', 'Color',[0.5 0.5 0.5]);

legend('Conductor','Center A','Current dir','Point P','B vector', ...
       'Perp. distance \rho', 'Location','best');

hold off;