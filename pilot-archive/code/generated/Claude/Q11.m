%% Electric field at a point P due to two point charges (3D visualization)
clear; clc; close all;

%% ---------------- User inputs ----------------
q1 =  2e-9;   r1 = [-1,  0,  0];   % charge 1 [C] and position [m]
q2 = -2e-9;   r2 = [ 1,  0,  0];   % charge 2 [C] and position [m]

Px = 0;  Py = 1;  Pz = 2;     % field point P [m]
P  = [Px, Py, Pz];

%% ---------------- Field calculation ----------------
E1 = pointChargeField(q1, r1, P);  % field from charge 1 [V/m]
E2 = pointChargeField(q2, r2, P);  % field from charge 2 [V/m]
E  = E1 + E2;                      % superposition

fprintf('E1    = [%10.4f %10.4f %10.4f] V/m, |E1| = %.4f\n', E1, norm(E1));
fprintf('E2    = [%10.4f %10.4f %10.4f] V/m, |E2| = %.4f\n', E2, norm(E2));
fprintf('E     = [%10.4f %10.4f %10.4f] V/m, |E|  = %.4f\n', E,  norm(E));

%% ---------------- Visualization ----------------
figure('Color','w','Name','Electric field at P','Position',[100 100 800 650]);
hold on; grid on; box on;

% Scale arrows so the longest one is ~40% of the largest distance in the scene
L     = max([norm(P-r1), norm(P-r2), norm(r1-r2)]);
scale = 0.4 * L / max([norm(E1), norm(E2), norm(E)]);

% Charges (red = positive, blue = negative)
chargeColor = @(q) (q > 0) * [0.85 0.1 0.1] + (q <= 0) * [0.1 0.2 0.85];
scatter3(r1(1), r1(2), r1(3), 160, chargeColor(q1), 'filled', 'MarkerEdgeColor','k');
scatter3(r2(1), r2(2), r2(3), 160, chargeColor(q2), 'filled', 'MarkerEdgeColor','k');
text(r1(1), r1(2), r1(3), sprintf('  q_1 = %.2g C', q1), 'FontSize', 11);
text(r2(1), r2(2), r2(3), sprintf('  q_2 = %.2g C', q2), 'FontSize', 11);

% Field point P
plot3(Px, Py, Pz, 'ko', 'MarkerFaceColor','k', 'MarkerSize', 8);
text(Px, Py, Pz, '  P', 'FontSize', 12, 'FontWeight','bold');

% Dashed lines from each charge to P
plot3([r1(1) Px], [r1(2) Py], [r1(3) Pz], '--', 'Color',[0.6 0.6 0.6]);
plot3([r2(1) Px], [r2(2) Py], [r2(3) Pz], '--', 'Color',[0.6 0.6 0.6]);

% Field vectors drawn at P (scale = 0 disables quiver3's auto-scaling)
h1 = quiver3(Px, Py, Pz, scale*E1(1), scale*E1(2), scale*E1(3), 0, ...
             'Color',[0.9 0.5 0.1], 'LineWidth',2, 'MaxHeadSize',0.6);
h2 = quiver3(Px, Py, Pz, scale*E2(1), scale*E2(2), scale*E2(3), 0, ...
             'Color',[0.1 0.6 0.3], 'LineWidth',2, 'MaxHeadSize',0.6);
h3 = quiver3(Px, Py, Pz, scale*E(1),  scale*E(2),  scale*E(3),  0, ...
             'Color','k', 'LineWidth',3, 'MaxHeadSize',0.6);

legend([h1 h2 h3], {'E_1 (from q_1)', 'E_2 (from q_2)', 'E = E_1 + E_2'}, ...
       'Location','northeastoutside');

xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title(sprintf('Electric field at P(%.2g, %.2g, %.2g):  |E| = %.3g V/m', Px, Py, Pz, norm(E)));
axis equal; view(3); rotate3d on;
hold off;
view(120,35)
%% ---------------- Local function ----------------
function E = pointChargeField(q, rq, P)
% Electric field at P from a point charge q located at rq (Coulomb's law)
    k = 8.9875517923e9;          % Coulomb constant [N*m^2/C^2]
    R = P - rq;                  % vector from charge to field point
    d = norm(R);
    if d == 0
        error('Field point P coincides with a charge; the field is undefined.');
    end
    E = k * q * R / d^3;
end