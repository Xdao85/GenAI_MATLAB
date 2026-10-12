%% Electric Field Visualization due to Two Point Charges in 3D
clear; clc; close all;

%% ================== USER INPUTS ==================
% Point P where electric field is to be calculated
Px = 0;  Py = 1;  Pz = 2;

% Point charge 1
q1 = 2e-9;                    % Charge magnitude (Coulombs)
r1 = [-1, 0, 0];               % Position [x, y, z]

% Point charge 2
q2 = -2e-9;                   % Charge magnitude (Coulombs)
r2 = [1, 0, 0];               % Position [x, y, z]

% Physical constant
k = 8.9875e9;                 % Coulomb's constant (N·m²/C²)

% Visualization scaling
arrowScale = 1;               % Scale factor for display arrow
%% =================================================

% Point P as vector
P = [Px, Py, Pz];

% Distance vectors from charges to P
R1 = P - r1;
R2 = P - r2;

% Distances
d1 = norm(R1);
d2 = norm(R2);

% Guard against division by zero
if d1 < 1e-12 || d2 < 1e-12
    error('Point P coincides with a charge location. Choose different coordinates.');
end

% Unit vectors from each charge toward P
u1 = R1 / d1;
u2 = R2 / d2;

% Electric field contributions (vector form)
E1 = k * q1 / d1^2 * u1;
E2 = k * q2 / d2^2 * u2;

% Total electric field at P
E = E1 + E2;

% Display numerical results
fprintf('Distance from q1 to P : %.4f\n', d1);
fprintf('Distance from q2 to P : %.4f\n', d2);
fprintf('E1 = [%g, %g, %g] N/C\n', E1);
fprintf('E2 = [%g, %g, %g] N/C\n', E2);
fprintf('Total E at P = [%g, %g, %g] N/C\n', E);
fprintf('|E| = %g N/C\n', norm(E));

%% ================== PLOTTING ==================
figure('Color', 'w', 'Position', [100 100 900 700]);
hold on; grid on; box on;

% Plot charges
scatter3(r1(1), r1(2), r1(3), 200, 'r', 'filled');
scatter3(r2(1), r2(2), r2(3), 200, 'b', 'filled');
text(r1(1), r1(2), r1(3), sprintf('  q_1 = %.1e C', q1), ...
     'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold');
text(r2(1), r2(2), r2(3), sprintf('  q_2 = %.1e C', q2), ...
     'Color', 'b', 'FontSize', 11, 'FontWeight', 'bold');

% Plot point P
plot3(P(1), P(2), P(3), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
text(P(1), P(2), P(3), '  P', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold');

% Scale arrows for visibility (normalize direction, scale magnitude)
maxE = max([norm(E1), norm(E2), norm(E)]);
if maxE == 0, maxE = 1; end  % avoid divide-by-zero

arrowLen = 0.5 * arrowScale;    % Base length for arrows
s1 = arrowLen * norm(E1)/maxE;
s2 = arrowLen * norm(E2)/maxE;
sT = arrowLen * norm(E)/maxE;

% Draw arrow for E1
if norm(E1) > 0
    quiver3(P(1), P(2), P(3), E1(1)/norm(E1)*s1, E1(2)/norm(E1)*s1, E1(3)/norm(E1)*s1, ...
        0, 'Color', [1 0.5 0], 'LineWidth', 2, 'MaxHeadSize', 0.5);
end

% Draw arrow for E2
if norm(E2) > 0
    quiver3(P(1), P(2), P(3), E2(1)/norm(E2)*s2, E2(2)/norm(E2)*s2, E2(3)/norm(E2)*s2, ...
        0, 'Color', [0 0.6 0], 'LineWidth', 2, 'MaxHeadSize', 0.5);
end

% Draw arrow for total E
if norm(E) > 0
    quiver3(P(1), P(2), P(3), E(1)/norm(E)*sT, E(2)/norm(E)*sT, E(3)/norm(E)*sT, ...
        0, 'Color', 'm', 'LineWidth', 3, 'MaxHeadSize', 0.6);
end

% Dashed lines from charges to P (geometry aid)
plot3([r1(1) P(1)], [r1(2) P(2)], [r1(3) P(3)], 'r--', 'LineWidth', 0.5);
plot3([r2(1) P(1)], [r2(2) P(2)], [r2(3) P(3)], 'b--', 'LineWidth', 0.5);

% Labels and title
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('Electric Field at Point P due to Two Point Charges');

% Legend (dummy plots)
h1 = plot3(NaN, NaN, NaN, '-', 'Color', [1 0.5 0], 'LineWidth', 2);
h2 = plot3(NaN, NaN, NaN, '-', 'Color', [0 0.6 0], 'LineWidth', 2);
h3 = plot3(NaN, NaN, NaN, '-', 'Color', 'm', 'LineWidth', 3);
legend([h1 h2 h3], {'E_1 (from q_1)', 'E_2 (from q_2)', 'E_{total} at P'}, ...
       'Location', 'best');

% View and axis settings
axis equal;
view(45, 25);
rotate3d on;
hold off;