
clc;
clear;
close all;

% Physical constant
epsilon0 = 8.854e-12;
k = 1/(4*pi*epsilon0);

% Two point charges (C)
q1 =  2e-9;
q2 = -2e-9;

% Charge positions (m)
r1 = [-1, 0, 0];
r2 = [ 1, 0, 0];

% Observation point P (m)
Px = 0;
Py = 1;
Pz = 2;
rP = [Px, Py, Pz];

% Displacement vectors from charges to P
R1 = rP - r1;
R2 = rP - r2;

% Distances
d1 = norm(R1);
d2 = norm(R2);

% Electric field vectors (V/m or N/C)
E1 = k*q1*R1/d1^3;
E2 = k*q2*R2/d2^3;

% Total electric field
E = E1 + E2;

% Display results
fprintf('E1 = [%.3e, %.3e, %.3e] V/m\n', E1);
fprintf('E2 = [%.3e, %.3e, %.3e] V/m\n', E2);
fprintf('Total E = [%.3e, %.3e, %.3e] V/m\n', E);
fprintf('|E| = %.3e V/m\n', norm(E));

% Plot charges, observation point, and electric field vector
figure;
hold on;
grid on;
axis equal;

% Plot positive and negative charges
plot3(r1(1), r1(2), r1(3), 'ro', ...
    'MarkerSize', 12, 'MarkerFaceColor', 'r');
plot3(r2(1), r2(2), r2(3), 'bo', ...
    'MarkerSize', 12, 'MarkerFaceColor', 'b');

% Plot observation point
plot3(Px, Py, Pz, 'ko', ...
    'MarkerSize', 8, 'MarkerFaceColor', 'k');

% Draw electric field vector (normalized for visualization)
quiver3(Px, Py, Pz, E(1), E(2), E(3), 0, ...
    'g', 'LineWidth', 2, 'MaxHeadSize', 0.5);

% Labels
text(r1(1), r1(2), r1(3), '  q_1 > 0');
text(r2(1), r2(2), r2(3), '  q_2 < 0');
text(Px, Py, Pz, '  P');

xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
title('Electric Field Vector at Point P');
legend('Positive charge', 'Negative charge', ...
    'Observation point P', 'Electric field E', ...
    'Location', 'best');

view(3);
hold off;

view(120,35)