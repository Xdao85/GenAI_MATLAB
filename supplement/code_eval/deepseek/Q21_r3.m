% =========================================================
% Magnetic Flux Density of a Finite Straight Wire
% =========================================================
clear; clc; close all;

%% ---------------- User Inputs ----------------
mu0 = 4*pi*1e-7;          % Permeability of free space (H/m)
I   = 1;                 % Current (A)
l   = 2;                % Length of conductor (m)

A   = [0.25, 0.5, 0];          % Center of wire (Ax, Ay, Az)
P   = [1, 1, 0];    % Observation point P(Px, Py, Pz)

%% ---------------- Geometry ----------------
% Wire runs from z1 to z2 parallel to z-axis at (Ax, Ay)
z1 = A(3) - l/2;
z2 = A(3) + l/2;

% Perpendicular distance (rho) from P to wire axis
rho = sqrt((P(1)-A(1))^2 + (P(2)-A(2))^2);

if rho < 1e-12
    error('Point P lies on the wire axis — B is singular there.');
end

% Distance from P to the two ends of the wire
r1 = sqrt(rho^2 + (z1 - P(3))^2);
r2 = sqrt(rho^2 + (z2 - P(3))^2);

% Common factor
k = mu0 * I / (4*pi);

% Field components (Bz = 0)
Bx = -k * (P(2)-A(2)) / rho^2 * ((z2-P(3))/r2 - (z1-P(3))/r1);
By =  k * (P(1)-A(1)) / rho^2 * ((z2-P(3))/r2 - (z1-P(3))/r1);
Bz = 0;

B = [Bx, By, Bz];
Bmag = norm(B);

fprintf('B at P = [%.3f, %.3f, %.3f] m\n', P);
fprintf('Bx = %.4e T\nBy = %.4e T\nBz = %.4e T\n', Bx, By, Bz);
fprintf('|B| = %.4e T\n', Bmag);

%% ---------------- 3D Plot ----------------
figure('Color','w','Position',[100 100 900 700]);
hold on; grid on; axis equal;
view(35, 25);
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title(sprintf('Magnetic Flux Density at P due to Finite Wire (I = %.1f A, l = %.1f m)', I, l));

% ---- Plot the conductor ----
plot3([A(1) A(1)], [A(2) A(2)], [z1 z2], 'k-', 'LineWidth', 3);
plot3(A(1), A(2), z1, 'ko', 'MarkerFaceColor','k');
plot3(A(1), A(2), z2, 'ko', 'MarkerFaceColor','k');
text(A(1), A(2), z2, '  I ↑', 'FontSize',12, 'FontWeight','bold');

% ---- Plot point P ----
plot3(P(1), P(2), P(3), 'ro', 'MarkerSize',10, 'MarkerFaceColor','r');
text(P(1), P(2), P(3), sprintf('  P(%.2f, %.2f, %.2f)', P), 'FontSize',11);

% ---- Plot B vector at P (scaled for visibility) ----
scale = 1 / max(Bmag, eps);          % normalize
Bscale = B * scale * 0.5;            % arrow length in plot units
quiver3(P(1), P(2), P(3), Bscale(1), Bscale(2), Bscale(3), ...
        0, 'b', 'LineWidth', 2.5, 'MaxHeadSize', 0.8);
text(P(1)+Bscale(1), P(2)+Bscale(2), P(3)+Bscale(3), ...
     sprintf('  B (|B|=%.2e T)', Bmag), 'Color','b', 'FontSize',10);

% ---- Optional: perpendicular line from P to wire axis ----
plot3([P(1) A(1)], [P(2) A(2)], [P(3) P(3)], '--', 'Color',[0.5 0.5 0.5]);
plot3(A(1), A(2), P(3), 'ks', 'MarkerSize',6, 'MarkerFaceColor',[0.5 0.5 0.5]);

legend('Conductor','Wire ends','','Point P','B vector', ...
       'Perp. distance','Projection','Location','northeastoutside');

axis([-1 1 -1 1 min(z1,-0.5) max(z2,1)]);
hold off;