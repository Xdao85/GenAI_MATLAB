
clc;
clear;
close all;

%% Parameters
mu0 = 4*pi*1e-7;       % Permeability of free space (H/m)
I = 1;                 % Current (A)
L = 2;                 % Conductor length (m)

% Center of the conductor A (m)
Ax = 0.25;
Ay = 0.5;
Az = 0;

% Observation point P (m)
Px = 1;
Py = 1;
Pz = 0;

%% Biot-Savart law
% Conductor is parallel to the z-axis
z1 = Az - L/2;
z2 = Az + L/2;

dx = Px - Ax;
dy = Py - Ay;

Bx = mu0*I/(4*pi) * integral(@(zp) ...
    -dy ./ (dx^2 + dy^2 + (Pz-zp).^2).^(3/2), z1, z2);

By = mu0*I/(4*pi) * integral(@(zp) ...
     dx ./ (dx^2 + dy^2 + (Pz-zp).^2).^(3/2), z1, z2);

Bz = 0;

B = [Bx, By, Bz];
Bmag = norm(B);

%% Display results
fprintf('Bx = %.6e T\n', Bx);
fprintf('By = %.6e T\n', By);
fprintf('Bz = %.6e T\n', Bz);
fprintf('|B| = %.6e T\n', Bmag);

%% 3D plot
figure;
hold on;
grid on;
axis equal;
view(3);

% Finite conductor
plot3([Ax Ax], [Ay Ay], [z1 z2], ...
    'b-', 'LineWidth', 4);

% Center of conductor
plot3(Ax, Ay, Az, 'bo', ...
    'MarkerFaceColor', 'b', 'MarkerSize', 7);

% Observation point
plot3(Px, Py, Pz, 'ro', ...
    'MarkerFaceColor', 'r', 'MarkerSize', 8);

% Vector from conductor center to P
quiver3(Ax, Ay, Az, Px-Ax, Py-Ay, Pz-Az, ...
    0, 'k--', 'LineWidth', 1.5);

% Magnetic flux density vector at P
% Scale the arrow for visualization only
if Bmag > 0
    arrowLength = 0.5;
    quiver3(Px, Py, Pz, ...
        arrowLength*Bx/Bmag, ...
        arrowLength*By/Bmag, ...
        arrowLength*Bz/Bmag, ...
        0, 'r', 'LineWidth', 2.5, 'MaxHeadSize', 0.5);
end

xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
title('Magnetic Flux Density of a Finite Straight Conductor');

legend('Conductor', 'Center A', 'Observation point P', ...
       'Position vector A to P', 'Direction of B', ...
       'Location', 'best');

text(Px, Py, Pz, '  P');
text(Ax, Ay, Az, '  A');

hold off;

% Thêm 
view(120,45)