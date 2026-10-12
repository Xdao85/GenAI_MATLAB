%% Visualize Electric Field Vector at Point P due to Two Point Charges (3D)
clear; clc; close all;

%% ---------------- USER INPUTS ----------------
% Point P where E is evaluated
Px = 1.0;  Py = 1.0;  Pz = 1.0;
P  = [Px, Py, Pz];

% Charge 1: value (C) and position (m)
q1 =  2e-9;            % charge value
r1 = [-1.0,  0.0,  0.0];   % position of q1

% Charge 2: value (C) and position (m)
q2 = -1.5e-9;
r2 = [ 1.0,  1.0,  0.5];   % position of q2

% Physical constant
k = 8.9875517923e9;   % Coulomb's constant (N·m²/C²)
%% ----------------------------------------------


%% Compute electric field vectors
E1 = k * q1 * (P - r1) / norm(P - r1)^3;   % field due to q1
E2 = k * q2 * (P - r2) / norm(P - r2)^3;   % field due to q2
E  = E1 + E2;                              % total field

% Display numerical results
fprintf('Field due to q1 : [% .3e, % .3e, % .3e] N/C\n', E1);
fprintf('Field due to q2 : [% .3e, % .3e, % .3e] N/C\n', E2);
fprintf('Total field E   : [% .3e, % .3e, % .3e] N/C\n', E);
fprintf('|E| = %.3e N/C\n', norm(E));


%% ---------------- PLOTTING ----------------
figure('Color','w');
hold on; grid on; axis equal;
view(45, 25);
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('Electric Field Vector at P due to Two Point Charges');

% --- Draw charges ---
plot3(r1(1), r1(2), r1(3), 'o', ...
    'MarkerSize',12, 'MarkerFaceColor',[0.85 0.1 0.1], ...
    'MarkerEdgeColor','k');
plot3(r2(1), r2(2), r2(3), 'o', ...
    'MarkerSize',12, 'MarkerFaceColor',[0.1 0.3 0.85], ...
    'MarkerEdgeColor','k');

text(r1(1), r1(2), r1(3)+0.15, sprintf('q_1 = %.2g C', q1), ...
     'Color','r','FontWeight','bold');
text(r2(1), r2(2), r2(3)+0.15, sprintf('q_2 = %.2g C', q2), ...
     'Color','b','FontWeight','bold');

% --- Draw point P ---
plot3(P(1), P(2), P(3), 'ks', 'MarkerSize',10, ...
      'MarkerFaceColor','y');
text(P(1), P(2), P(3)+0.15, 'P', 'FontWeight','bold');

% --- Draw position vectors r1->P and r2->P (dashed) ---
quiver3(r1(1),r1(2),r1(3), P(1)-r1(1), P(2)-r1(2), P(3)-r1(3), ...
        0, 'Color',[0.5 0.5 0.5], 'LineStyle','--', 'LineWidth',1);
quiver3(r2(1),r2(2),r2(3), P(1)-r2(1), P(2)-r2(2), P(3)-r2(3), ...
        0, 'Color',[0.5 0.5 0.5], 'LineStyle','--', 'LineWidth',1);

% --- Draw E-field vectors (scaled for visibility) ---
scale = 0.5 * max([norm(r1-P), norm(r2-P), 1]) / max(norm(E), eps);

quiver3(P(1),P(2),P(3), scale*E1(1), scale*E1(2), scale*E1(3), ...
        0, 'Color',[0.85 0.1 0.1], 'LineWidth',2, 'MaxHeadSize',0.5);
quiver3(P(1),P(2),P(3), scale*E2(1), scale*E2(2), scale*E2(3), ...
        0, 'Color',[0.1 0.3 0.85], 'LineWidth',2, 'MaxHeadSize',0.5);
quiver3(P(1),P(2),P(3), scale*E(1),  scale*E(2),  scale*E(3), ...
        0, 'Color',[0 0.6 0], 'LineWidth',3, 'MaxHeadSize',0.6);

% --- Legend ---
legend({'q_1','q_2','Point P', ...
        'r_1 \rightarrow P','r_2 \rightarrow P', ...
        'E_1','E_2','E_{total}'}, ...
        'Location','northeastoutside');

hold off;