%% Magnetic Field of a Finite Linear Conductor using Biot-Savart Law
% This script models a straight conductor carrying current I and computes
% the magnetic field at a point P using numerical integration of the
% Biot-Savart law.

clear; clc; close all;

%% ==================== USER INPUTS ====================
% Conductor parameters
l  = 2;        % Length of conductor [m]
I  = 1;        % Current magnitude [A] (positive = +z direction)

% Conductor center location A = (Ax, Ay, Az)
Ax = 0.25; 
Ay = 0.5; 
Az = 0;

% Field point P = (Px, Py, Pz)
Px = 1; 
Py = 1; 
Pz = 0;

% Numerical integration resolution
N = 1000;        % Number of segments along the conductor

%% ==================== CONSTANTS ====================
mu0 = 4*pi*1e-7;   % Permeability of free space [H/m]

%% ==================== CONDUCTOR GEOMETRY ====================
% Conductor is parallel to z-axis, centered at (Ax, Ay, Az)
% Endpoints: from z = Az - l/2 to z = Az + l/2
z1 = Az - l/2;
z2 = Az + l/2;

% Discretize the conductor into N segments
z_nodes = linspace(z1, z2, N+1);
dz = (z2 - z1)/N;     % Segment length

%% ==================== BIOT-SAVART NUMERICAL INTEGRATION ====================
% B(r) = (mu0 * I / (4*pi)) * Integral[ dl x (r - r') / |r - r'|^3 ]

B = [0, 0, 0];   % Initialize magnetic field vector

for k = 1:N
    % Midpoint of the k-th segment on the source conductor
    zk = (z_nodes(k) + z_nodes(k+1))/2;
    source = [Ax, Ay, zk];
    
    % Differential length element vector dl (directed along +z, current direction)
    dl = [0, 0, I*dz];   % Note: current magnitude folded in here
    
    % Vector from source point to field point P
    r_vec = [Px - source(1), Py - source(2), Pz - source(3)];
    r_mag = norm(r_vec);
    
    % Avoid singularity if P lies on the conductor
    if r_mag < 1e-9
        error('Field point P lies on the conductor. Choose a different P.');
    end
    
    % Contribution to B from this segment
    dB = (mu0/(4*pi)) * cross(dl, r_vec) / r_mag^3;
    
    % Accumulate
    B = B + dB;
end

%% ==================== DISPLAY RESULTS ====================
fprintf('===== Magnetic Field Computation =====\n');
fprintf('Conductor length l    = %.3f m\n', l);
fprintf('Current I             = %.3f A (along +z)\n', I);
fprintf('Conductor center A    = (%.3f, %.3f, %.3f) m\n', Ax, Ay, Az);
fprintf('Field point P         = (%.3f, %.3f, %.3f) m\n', Px, Py, Pz);
fprintf('\nMagnetic field B at P:\n');
fprintf('  Bx = %.6e T\n', B(1));
fprintf('  By = %.6e T\n', B(2));
fprintf('  Bz = %.6e T\n', B(3));
fprintf('  |B| = %.6e T\n', norm(B));

%% ==================== COMPARISON WITH ANALYTICAL SOLUTION ====================
% For an infinite wire along z: B = mu0*I/(2*pi*rho) * phi_hat
% For a finite wire, closed-form exists. We'll just print for reference.
rho = sqrt((Px - Ax)^2 + (Py - Ay)^2);
if rho > 1e-9
    B_inf = mu0 * I / (2*pi*rho);
    fprintf('\nReference: |B| for infinite wire = %.6e T\n', B_inf);
    fprintf('Ratio |B_finite| / |B_infinite| = %.4f\n', norm(B)/B_inf);
end

%% ==================== 3D PLOT ====================
figure('Color','w','Position',[100 100 900 700]);
hold on; grid on; axis equal;
view(35, 25);

% --- Plot conductor ---
plot3([Ax Ax], [Ay Ay], [z1 z2], 'k-', 'LineWidth', 4);

% Arrow to show current direction
quiver3(Ax, Ay, z2, 0, 0, 0.3*l, ...
    'Color', [0.8 0.1 0.1], 'LineWidth', 2, 'MaxHeadSize', 1.5);
text(Ax, Ay, z2 + 0.35*l, 'I', 'Color', [0.8 0.1 0.1], ...
    'FontSize', 14, 'FontWeight', 'bold');

% --- Plot field point P ---
plot3(Px, Py, Pz, 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
text(Px, Py, Pz + 0.15*l, 'P', 'Color', 'b', ...
    'FontSize', 14, 'FontWeight', 'bold');

% --- Plot magnetic field vector at P (scaled for visibility) ---
B_mag = norm(B);
if B_mag > 0
    scale = 0.5 * l / B_mag;     % Scale arrow for visualization
    quiver3(Px, Py, Pz, B(1)*scale, B(2)*scale, B(3)*scale, ...
        'Color', [0 0.6 0], 'LineWidth', 2.5, 'MaxHeadSize', 0.8);
    text(Px + B(1)*scale, Py + B(2)*scale, Pz + B(3)*scale + 0.1*l, ...
        'B', 'Color', [0 0.6 0], 'FontSize', 14, 'FontWeight', 'bold');
end

% --- Optional: visualize a few other field vectors to show B direction ---
% Sample ring of points around the wire
theta = linspace(0, 2*pi, 9);
r_ring = max(rho, 0.3*l);
for th = theta(1:end-1)
    xp = Ax + r_ring*cos(th);
    yp = Ay + r_ring*sin(th);
    zp = Pz;
    % Compute B at this ring point using same numerical integral
    Bp = [0 0 0];
    for k = 1:N
        zk = (z_nodes(k)+z_nodes(k+1))/2;
        src = [Ax, Ay, zk];
        rv  = [xp-src(1), yp-src(2), zp-src(3)];
        rm  = norm(rv);
        dlv = [0, 0, I*dz];
        Bp  = Bp + (mu0/(4*pi)) * cross(dlv, rv)/rm^3;
    end
    if norm(Bp) > 0
        s = 0.4*l/norm(Bp);
        quiver3(xp, yp, zp, Bp(1)*s, Bp(2)*s, Bp(3)*s, ...
            'Color', [0.3 0.7 0.3], 'LineWidth', 1, 'MaxHeadSize', 0.5);
    end
end

% --- Labels & formatting ---
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title({'Magnetic Field of a Finite Linear Conductor (Biot–Savart)', ...
       sprintf('l = %.2f m, I = %.2f A, P = (%.2f, %.2f, %.2f)', ...
       l, I, Px, Py, Pz)});
legend({'Conductor', 'Current direction', 'Field point P', ...
        'B at P', 'B samples around wire'}, 'Location', 'northeastoutside');

% Adjust axis limits for good view
xlim([min([Ax,Px])-l, max([Ax,Px])+l]);
ylim([min([Ay,Py])-l, max([Ay,Py])+l]);
zlim([min([z1,Pz])-0.5*l, max([z2,Pz])+0.5*l]);

hold off;