clc;
clear;
close all;

%% Constants
epsilon0 = 8.854e-12;              % Permittivity of free space (F/m)
k = 1/(4*pi*epsilon0);             % Coulomb constant

%% Point charges
q1 = 2e-9;                          % Charge 1 (C)
q2 = -3e-9;                         % Charge 2 (C)

r1 = [0, 0, 0];                     % Position of charge 1 (m)
r2 = [0.5, 0, 0];                   % Position of charge 2 (m)

%% Observation point P(Px, Py, Pz)
Px = 0.25;
Py = 0.30;
Pz = 0.20;

P = [Px, Py, Pz];

%% Electric field due to charge 1
R1 = P - r1;
d1 = norm(R1);

E1 = k*q1/d1^3 * R1;

%% Electric field due to charge 2
R2 = P - r2;
d2 = norm(R2);

E2 = k*q2/d2^3 * R2;

%% Resultant electric field
E = E1 + E2;

%% Display results
fprintf('Electric field due to Q1:\n');
fprintf('E1 = [%g, %g, %g] N/C\n\n', E1);

fprintf('Electric field due to Q2:\n');
fprintf('E2 = [%g, %g, %g] N/C\n\n', E2);

fprintf('Resultant electric field:\n');
fprintf('E = [%g, %g, %g] N/C\n', E);

fprintf('Magnitude of E = %g N/C\n', norm(E));

%% 3D Visualization

figure;
hold on;
grid on;
axis equal;

% Plot charge positions
plot3(r1(1), r1(2), r1(3), 'ro', ...
    'MarkerSize', 10, 'MarkerFaceColor', 'r');

plot3(r2(1), r2(2), r2(3), 'bo', ...
    'MarkerSize', 10, 'MarkerFaceColor', 'b');

% Plot observation point P
plot3(P(1), P(2), P(3), 'ko', ...
    'MarkerSize', 8, 'MarkerFaceColor', 'k');

%% Scale vectors for visualization
scale = 0.1 / max([norm(E1), norm(E2), norm(E)]);

% Electric field vectors
quiver3(P(1), P(2), P(3), ...
        E1(1)*scale, E1(2)*scale, E1(3)*scale, ...
        0, 'r', 'LineWidth', 2);

quiver3(P(1), P(2), P(3), ...
        E2(1)*scale, E2(2)*scale, E2(3)*scale, ...
        0, 'b', 'LineWidth', 2);

% Resultant field vector
quiver3(P(1), P(2), P(3), ...
        E(1)*scale, E(2)*scale, E(3)*scale, ...
        0, 'k', 'LineWidth', 3);

%% Labels
text(r1(1), r1(2), r1(3), '  Q_1', 'FontSize', 12);
text(r2(1), r2(2), r2(3), '  Q_2', 'FontSize', 12);
text(P(1), P(2), P(3), '  P', 'FontSize', 12);

xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');

title('Electric Field at Point P Due to Two Point Charges');

legend('Q_1', 'Q_2', 'Point P', ...
       'E_1', 'E_2', 'Resultant E', ...
       'Location', 'best');

view(3);