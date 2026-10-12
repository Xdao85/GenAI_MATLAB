%% Electric field at point P due to two point charges (3D)
clear; clc; close all;

%% ---------------- Inputs ----------------
k  = 8.9875517923e9;          % Coulomb constant [N*m^2/C^2]

q1 = +2e-9;   r1 = [ 1  0  0];   % charge 1 [C], position [m]
q2 = -3e-9;   r2 = [-1  1  0.5]; % charge 2 [C], position [m]

Px = 0.5; Py = 2; Pz = 1.5;      % field point P [m]
P  = [Px Py Pz];

%% ---------------- Field calculation ----------------
% E = k*q*(P - r)/|P - r|^3
fieldFrom = @(q, r) k * q * (P - r) / norm(P - r)^3;

E1 = fieldFrom(q1, r1);          % field due to q1 at P
E2 = fieldFrom(q2, r2);          % field due to q2 at P
E  = E1 + E2;                    % superposition

fprintf('E1    = [%9.3f %9.3f %9.3f] N/C, |E1|    = %.3f N/C\n', E1, norm(E1));
fprintf('E2    = [%9.3f %9.3f %9.3f] N/C, |E2|    = %.3f N/C\n', E2, norm(E2));
fprintf('Etot  = [%9.3f %9.3f %9.3f] N/C, |Etot|  = %.3f N/C\n', E,  norm(E));

%% ---------------- Visualization ----------------
figure('Color','w','Name','Electric field at P'); hold on; grid on; axis equal;
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title('Electric field at P due to two point charges');
view(135, 25);

% Scale arrows so the largest one has a length comparable to the scene size
allPts   = [r1; r2; P];
sceneLen = max(max(allPts) - min(allPts));
maxE     = max([norm(E1), norm(E2), norm(E)]);
s        = 0.6 * sceneLen / maxE;      % arrow scale factor (m per N/C)

% Charges (red = positive, blue = negative)
chargeColor = @(q) (q > 0) * [0.85 0.1 0.1] + (q <= 0) * [0.1 0.2 0.85];
scatter3(r1(1), r1(2), r1(3), 150, chargeColor(q1), 'filled', 'MarkerEdgeColor','k');
scatter3(r2(1), r2(2), r2(3), 150, chargeColor(q2), 'filled', 'MarkerEdgeColor','k');
text(r1(1), r1(2), r1(3), sprintf('  q_1 = %+.1f nC', q1*1e9), 'FontSize', 10);
text(r2(1), r2(2), r2(3), sprintf('  q_2 = %+.1f nC', q2*1e9), 'FontSize', 10);

% Field point
scatter3(Px, Py, Pz, 80, 'k', 'filled');
text(Px, Py, Pz, '  P', 'FontSize', 12, 'FontWeight', 'bold');

% Dashed lines from each charge to P
plot3([r1(1) Px], [r1(2) Py], [r1(3) Pz], 'k:');
plot3([r2(1) Px], [r2(2) Py], [r2(3) Pz], 'k:');

% Field vectors drawn at P (autoscale off so lengths are true to scale)
h1 = quiver3(Px, Py, Pz, s*E1(1), s*E1(2), s*E1(3), 0, ...
    'Color', chargeColor(q1), 'LineWidth', 1.8, 'MaxHeadSize', 0.5);
h2 = quiver3(Px, Py, Pz, s*E2(1), s*E2(2), s*E2(3), 0, ...
    'Color', chargeColor(q2), 'LineWidth', 1.8, 'MaxHeadSize', 0.5);
h3 = quiver3(Px, Py, Pz, s*E(1),  s*E(2),  s*E(3),  0, ...
    'Color', [0 0.6 0.2], 'LineWidth', 3, 'MaxHeadSize', 0.5);

% Parallelogram showing the vector addition E1 + E2
plot3(Px + s*[E1(1), E(1)], Py + s*[E1(2), E(2)], Pz + s*[E1(3), E(3)], 'k--');
plot3(Px + s*[E2(1), E(1)], Py + s*[E2(2), E(2)], Pz + s*[E2(3), E(3)], 'k--');

legend([h1 h2 h3], {'E_1 (from q_1)', 'E_2 (from q_2)', 'E_{total}'}, ...
       'Location','northeastoutside');

hold off;
