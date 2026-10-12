%% Magnetic Field of a Finite Straight Conductor using Biot-Savart Law
% This script models a straight wire of length l carrying current I,
% oriented parallel to z-axis, centered at point A = (Ax, Ay, Az).
% It computes B at point P = (Px, Py, Pz) via numerical integration of
% the Biot-Savart law and visualizes everything in 3D.
%
% Biot-Savart law (differential form):
%       dB = (mu0 * I / (4*pi)) * (dl x r_hat) / |r|^2
%
% For a straight wire along z, this reduces to:
%       B_phi = (mu0 * I / (4*pi*rho)) * (sin(theta2) - sin(theta1))
% where rho is the perpendicular distance from wire to P and theta's are
% the angles subtended by the wire ends at P. We use numerical integration
% here (general and pedagogical).

clear; clc; close all;

%% ---------------- User-defined parameters ----------------
I  = 10;        % Current (A) — positive = +z direction
l  = 2.0;       % Length of conductor (m)

% Location of the center (or reference point) of the conductor
Ax = 0;  Ay = 0;  Az = 0;

% Field point P
Px = 0.5;  Py = 0.5;  Pz = 0.3;

% Physical constant
mu0 = 4*pi*1e-7;   % Permeability of free space (H/m)

%% ---------------- Discretize the conductor ----------------
% Wire runs from z = Az - l/2 to z = Az + l/2 at (Ax, Ay)
N    = 2000;                                  % Number of segments
z1   = Az - l/2;                              % Start z
z2   = Az + l/2;                              % End z
zseg = linspace(z1, z2, N+1);                 % Segment edges
zmid = 0.5*(zseg(1:end-1) + zseg(2:end));     % Segment midpoints
dz   = zseg(2) - zseg(1);                     % Segment length

%% ---------------- Compute B via Biot-Savart ----------------
B = [0 0 0];   % Initialize magnetic field vector

for k = 1:N
    % Source point (midpoint of current element) — on the wire
    S = [Ax, Ay, zmid(k)];
    
    % Current element vector (dl along +z, direction of current)
    dl = [0, 0, dz];
    
    % Vector from source to field point P
    rvec = [Px - S(1), Py - S(2), Pz - S(3)];
    rmag = norm(rvec);
    
    if rmag < 1e-12
        warning('Field point lies on the wire — B is singular here.');
        continue;
    end
    
    rhat = rvec / rmag;                        % Unit vector
    dB   = (mu0 * I / (4*pi)) * cross(dl, rhat) / rmag^2;
    B    = B + dB;                             % Accumulate
end

%% ---------------- Report the result ----------------
fprintf('Conductor: length l = %.3f m, current I = %.3f A (along +z)\n', l, I);
fprintf('Conductor reference point A = (%.3f, %.3f, %.3f)\n', Ax, Ay, Az);
fprintf('Field point P = (%.3f, %.3f, %.3f)\n', Px, Py, Pz);
fprintf('Magnetic field B at P (T):\n');
fprintf('   Bx = %+ .4e\n   By = %+ .4e\n   Bz = %+ .4e\n', B(1), B(2), B(3));
fprintf('   |B| = %.4e T\n', norm(B));
fprintf('   Direction (unit): [%.4f, %.4f, %.4f]\n', B/norm(B));

%% ---------------- 3D Visualization ----------------
figure('Color','w','Position',[100 100 900 700]);
hold on; grid on; axis equal;
view(45, 25);
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('Magnetic Field at P due to Finite Straight Conductor');

% --- Plot the conductor (thick blue line along z) ---
plot3([Ax Ax], [Ay Ay], [z1 z2], 'b-', 'LineWidth', 4);

% --- Arrowhead markers showing current direction ---
nArrows = 5;
zc = linspace(z1, z2, nArrows+2); zc = zc(2:end-1);
for k = 1:nArrows
    quiver3(Ax, Ay, zc(k), 0, 0, 0.08*l, 0, ...
        'Color','b','LineWidth',1.5,'MaxHeadSize',2);
end

% --- Mark the field point P ---
plot3(Px, Py, Pz, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');

% --- Draw the magnetic field vector at P (scaled for visibility) ---
Bmag    = norm(B);
scaleB  = 0.4 * l / max(Bmag, eps);   % Scale so arrow is visible
Barrow  = B * scaleB;
quiver3(Px, Py, Pz, Barrow(1), Barrow(2), Barrow(3), ...
        'Color','m', 'LineWidth', 2.5, 'MaxHeadSize', 0.8);

% --- Dashed line from conductor axis to P (shows rho) ---
plot3([Ax Px], [Ay Py], [Pz Pz], 'k--', 'LineWidth', 1);
text((Ax+Px)/2, (Ay+Py)/2, Pz, '  \rho', 'FontSize', 11);

% --- Labels ---
text(Ax, Ay, z2+0.15*l, sprintf('  I = %.1f A', I), ...
     'Color','b','FontSize',11,'FontWeight','bold');
text(Px, Py, Pz+0.1*l, sprintf('  P (|B|=%.2e T)', Bmag), ...
     'Color','r','FontSize',11);
text(Px+Barrow(1), Py+Barrow(2), Pz+Barrow(3)+0.05*l, '  B', ...
     'Color','m','FontSize',12,'FontWeight','bold');

% --- Legend ---
legend({'Conductor', 'Current direction', 'Field point P', ...
        'B at P', 'Perp. distance \rho'}, ...
        'Location','northeastoutside');

hold off;