%% Electric field at point P due to two point charges (3D visualization)
% E_i = k * q_i * (P - r_i) / |P - r_i|^3,   E = E1 + E2
clear; clc; close all;

%% ---- Inputs (edit these) ----
k  = 8.9875517923e9;          % Coulomb constant [N*m^2/C^2]

q1 = +2e-9;   r1 = [ 1,  0,  0];     % charge 1 [C], position [m]
q2 = -3e-9;   r2 = [-1,  0.5, 0];    % charge 2 [C], position [m]

Px = 0.5;  Py = 1.5;  Pz = 1.0;      % field point P [m]
P  = [Px, Py, Pz];

%% ---- Field calculation ----
E1 = point_charge_field(k, q1, r1, P);
E2 = point_charge_field(k, q2, r2, P);
E  = E1 + E2;

fprintf('E1    = [%+.4e  %+.4e  %+.4e] N/C,  |E1| = %.4e\n', E1, norm(E1));
fprintf('E2    = [%+.4e  %+.4e  %+.4e] N/C,  |E2| = %.4e\n', E2, norm(E2));
fprintf('E tot = [%+.4e  %+.4e  %+.4e] N/C,  |E|  = %.4e\n', E,  norm(E));

%% ---- Visualization ----
% Scale arrows so the longest one is ~35% of the scene size
pts   = [r1; r2; P];
span  = max(max(pts) - min(pts));
if span == 0, span = 1; end
Emax  = max([norm(E1), norm(E2), norm(E)]);
s     = 0.35 * span / Emax;          % meters per (N/C), display only

figure('Color','w','Name','Electric field at P'); hold on; grid on; box on;

% Charges (red = positive, blue = negative)
scatter3(r1(1), r1(2), r1(3), 150, charge_color(q1), 'filled', 'MarkerEdgeColor','k');
scatter3(r2(1), r2(2), r2(3), 150, charge_color(q2), 'filled', 'MarkerEdgeColor','k');
text(r1(1), r1(2), r1(3), sprintf('  q_1 = %.2g C', q1), 'FontSize', 10);
text(r2(1), r2(2), r2(3), sprintf('  q_2 = %.2g C', q2), 'FontSize', 10);

% Field point
plot3(Px, Py, Pz, 'ko', 'MarkerFaceColor','k', 'MarkerSize', 7);
text(Px, Py, Pz, sprintf('  P(%.2g, %.2g, %.2g)', Px, Py, Pz), 'FontSize', 10);

% Dashed lines from charges to P
plot3([r1(1) Px], [r1(2) Py], [r1(3) Pz], '--', 'Color',[.6 .6 .6]);
plot3([r2(1) Px], [r2(2) Py], [r2(3) Pz], '--', 'Color',[.6 .6 .6]);

% Field vectors drawn at P
h1 = quiver3(Px,Py,Pz, s*E1(1), s*E1(2), s*E1(3), 0, 'Color',[0.85 0.33 0.10], 'LineWidth',1.8, 'MaxHeadSize',0.6);
h2 = quiver3(Px,Py,Pz, s*E2(1), s*E2(2), s*E2(3), 0, 'Color',[0.00 0.45 0.74], 'LineWidth',1.8, 'MaxHeadSize',0.6);
h3 = quiver3(Px,Py,Pz, s*E(1),  s*E(2),  s*E(3),  0, 'Color',[0.47 0.67 0.19], 'LineWidth',3.0, 'MaxHeadSize',0.6);

% Parallelogram showing the vector sum
tip1 = P + s*E1;  tip2 = P + s*E2;  tipS = P + s*E;
plot3([tip1(1) tipS(1)], [tip1(2) tipS(2)], [tip1(3) tipS(3)], ':', 'Color',[.5 .5 .5]);
plot3([tip2(1) tipS(1)], [tip2(2) tipS(2)], [tip2(3) tipS(3)], ':', 'Color',[.5 .5 .5]);

xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title('Electric field at P due to two point charges');
legend([h1 h2 h3], {'E_1 (from q_1)', 'E_2 (from q_2)', 'E = E_1 + E_2'}, 'Location','best');
axis equal; view(35, 25); camlight; hold off;

%% ---- Local functions ----
function E = point_charge_field(k, q, rq, P)
    % Field at P from a point charge q located at rq
    R = P - rq;
    d = norm(R);
    if d < eps
        error('Field point P coincides with a charge; field is undefined.');
    end
    E = k * q * R / d^3;
end

function c = charge_color(q)
    if q >= 0, c = [0.85 0.1 0.1]; else, c = [0.1 0.2 0.85]; end
end
