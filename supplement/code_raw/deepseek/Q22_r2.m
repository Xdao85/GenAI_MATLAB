%% Magnetic Field of a Finite Linear Conductor using Biot-Savart Law
% This script models a straight conductor carrying current I and computes
% the magnetic field at a point P using the Biot-Savart law.
%
% Biot-Savart law for a finite straight wire:
%   B = (mu0*I/(4*pi)) * (sin(theta2) - sin(theta1)) / r_perp  (magnitude)
% Vector form is computed by numerical integration.

clear; clc; close all;

%% ---------------- User Parameters ----------------
I  = 10;              % Current [A] (positive => +z direction)
l  = 2.0;             % Length of conductor [m]

% Conductor location (its midpoint) at point A
Ax = 0.0;
Ay = 0.0;
Az = 0.0;
A  = [Ax, Ay, Az];

% Field evaluation point P
P  = [0.5, 0.0, 0.0];   % [Px, Py, Pz] in meters

mu0 = 4*pi*1e-7;        % Permeability of free space [H/m]

%% ---------------- Conductor Geometry ----------------
% Conductor is parallel to z-axis, centered at A with length l.
% Endpoints:
z1 = Az - l/2;
z2 = Az + l/2;

% Wire path (for plotting)
nWire = 100;
zw    = linspace(z1, z2, nWire);
xw    = Ax * ones(1, nWire);
yw    = Ay * ones(1, nWire);

%% ---------------- Biot-Savart Integration ----------------
% B(P) = (mu0*I/4*pi) * integral( dl x (r_hat) / |r|^2 )
% Here dl = dz * z_hat, and r = P - source_point

N = 5000;                       % Number of integration segments
z_seg = linspace(z1, z2, N);
dz    = (z2 - z1)/(N-1);

B = [0, 0, 0];                  % Initialize B vector

for k = 1:N
    % Source point on wire (single point at this step for midpoint rule)
    src = [Ax, Ay, z_seg(k)];
    
    % Vector from source to field point
    rvec = P - src;
    rmag = norm(rvec);
    
    if rmag < 1e-12
        error('Point P lies on the conductor; B is singular there.');
    end
    
    % dl vector (along +z) for this segment
    dl = [0, 0, dz];
    
    % Contribution: (dl x r_hat) / |r|^2
    dB = (mu0 * I / (4*pi)) * cross(dl, rvec) / rmag^3;
    
    B = B + dB;
end

% Display results
fprintf('Conductor centered at A = (%.3f, %.3f, %.3f), length = %.3f m\n', A, l);
fprintf('Current I = %.3f A (direction +z)\n', I);
fprintf('Field point P = (%.3f, %.3f, %.3f) m\n', P);
fprintf('\nMagnetic field B at P:\n');
fprintf('  Bx = %e T\n', B(1));
fprintf('  By = %e T\n', B(2));
fprintf('  Bz = %e T\n', B(3));
fprintf('  |B| = %e T\n', norm(B));

%% ---------------- Analytical Check (Infinite wire approximation) ----------------
% For a finite wire, magnitude along the perpendicular direction:
r_perp = sqrt((P(1)-Ax)^2 + (P(2)-Ay)^2);
if r_perp > 0
    % Angles from perpendicular foot to wire endpoints
    sin1 = (z1 - P(3)) / sqrt((z1 - P(3))^2 + r_perp^2);
    sin2 = (z2 - P(3)) / sqrt((z2 - P(3))^2 + r_perp^2);
    B_analytic = (mu0*I/(4*pi*r_perp)) * (sin2 - sin1);
    fprintf('\nAnalytical magnitude (finite wire): |B| = %e T\n', abs(B_analytic));
end

%% ---------------- 3D Visualization ----------------
figure('Color','w','Position',[100 100 900 700]);
hold on; grid on; axis equal; box on;

% Plot the conductor
plot3(xw, yw, zw, 'b-', 'LineWidth', 4);
plot3(Ax, Ay, Az, 'ko', 'MarkerFaceColor','k', 'MarkerSize', 8);

% Plot the field point P
plot3(P(1), P(2), P(3), 'ro', 'MarkerFaceColor','r', 'MarkerSize', 10);

% Draw a dashed line from conductor to P (to show displacement r)
[~, idxMid] = min(abs(z_seg - P(3)));
srcMid = [Ax, Ay, z_seg(idxMid)];
plot3([srcMid(1), P(1)], [srcMid(2), P(2)], [srcMid(3), P(3)], ...
      'k--', 'LineWidth', 1);

% Scale B vector for visualization
Bmag = norm(B);
if Bmag > 0
    scaleArrow = 1.5;    % Visual scaling (in data units)
    Bplot = B / Bmag * scaleArrow;
    quiver3(P(1), P(2), P(3), Bplot(1), Bplot(2), Bplot(3), ...
            0, 'r', 'LineWidth', 2.5, 'MaxHeadSize', 0.8);
end

% Labels and title
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title(sprintf(['Linear conductor (I = %.2f A, l = %.2f m) and ', ...
               'magnetic field at P\n|B| = %.3e T'], I, l, Bmag));
legend({'Conductor', 'Center A', 'Point P', 'r vector', 'B at P'}, ...
       'Location','northeast');

% Adjust view
view(35, 25);

% Text annotation with vector components
txt = sprintf('B = (%.2e, %.2e, %.2e) T', B(1), B(2), B(3));
text(P(1)+0.1, P(2)+0.1, P(3)+0.1, txt, 'FontSize', 10, ...
     'BackgroundColor','w', 'EdgeColor','k');

hold off;