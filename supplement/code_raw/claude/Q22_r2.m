%% ========================================================================
%  BIOT-SAVART LAW: MAGNETIC FIELD OF A FINITE STRAIGHT CONDUCTOR
%  ------------------------------------------------------------------------
%  Model:
%    - Straight wire of length l, parallel to the z-axis.
%    - Point A(Ax,Ay,Az) is the LOWER END of the wire; the wire runs from
%      (Ax,Ay,Az) to (Ax,Ay,Az+l). (Change z0/z1 below if A is the centre.)
%    - Current I flows in the +z direction.
%    - Field is evaluated at point P(Px,Py,Pz).
%
%  Biot-Savart law:   dB = (mu0*I / 4*pi) * (dl x r) / |r|^3
%    where r = P - (source point on the wire)
%
%  The field is computed two ways:
%    (a) numerically, by summing dB over many small wire segments;
%    (b) analytically (closed-form result for a finite straight wire),
%        used here as a cross-check.
%  ========================================================================
clear; clc; close all;

%% ---------------------------- 1. INPUT DATA -----------------------------
mu0 = 4*pi*1e-7;          % Vacuum permeability [T*m/A]

I   = 10;                 % Current [A] (positive = +z direction)
l   = 2;                  % Wire length [m]

A   = [0, 0, 0];          % Point A: lower end of the wire [m]
P   = [0.5, 0.3, 1.2];    % Observation point P [m]

N   = 2000;               % Number of segments for numerical integration

%% ------------------------ 2. WIRE GEOMETRY ------------------------------
Ax = A(1);  Ay = A(2);  Az = A(3);
z0 = Az;                  % bottom end of wire
z1 = Az + l;              % top end of wire (wire is parallel to z-axis)

%% -------------- 3. NUMERICAL BIOT-SAVART (SEGMENT SUMMATION) ------------
% Divide the wire into N segments and use the midpoint of each one.
dz   = l / N;                                   % segment length
zs   = linspace(z0 + dz/2, z1 - dz/2, N)';      % segment midpoints (N x 1)
src  = [Ax*ones(N,1), Ay*ones(N,1), zs];        % source points (N x 3)

dl   = repmat([0, 0, dz], N, 1) * sign(I);      % current element vectors
                                                % (direction of current)
r    = P - src;                                 % vectors source -> P (N x 3)
rmag = sqrt(sum(r.^2, 2));                      % distances |r| (N x 1)

if any(rmag < 1e-9)
    error('Point P lies on the wire: the field is singular there.');
end

% dB = mu0*|I|/(4*pi) * (dl x r)/|r|^3   (summed over all segments)
dB = (mu0*abs(I)/(4*pi)) * cross(dl, r, 2) ./ rmag.^3;
B_num = sum(dB, 1);                             % total field [Bx By Bz] (T)

%% ------------------ 4. ANALYTICAL SOLUTION (CHECK) ----------------------
% Perpendicular distance from P to the wire axis
rx  = Px_minus(P(1), Ax);
ry  = Px_minus(P(2), Ay);
rho = hypot(rx, ry);

if rho < 1e-9
    B_ana = [0, 0, 0];      % on the wire axis (outside the wire): B = 0
else
    ua = P(3) - z0;         % height of P above the bottom end
    ub = P(3) - z1;         % height of P above the top end
    % |B| = mu0*I/(4*pi*rho) * (sin(theta_a) - sin(theta_b))
    Bmag = mu0*I/(4*pi*rho) * ( ua/sqrt(rho^2 + ua^2) ...
                              - ub/sqrt(rho^2 + ub^2) );
    % Direction: azimuthal unit vector (right-hand rule about +z)
    phi_hat = [-ry, rx, 0] / rho;
    B_ana   = Bmag * phi_hat;
end

%% --------------------------- 5. RESULTS ---------------------------------
B = B_num;                                      % field used for plotting
fprintf('--------------------------------------------\n');
fprintf('Wire: from (%.2f, %.2f, %.2f) to (%.2f, %.2f, %.2f) m\n', ...
        Ax, Ay, z0, Ax, Ay, z1);
fprintf('Current I = %.2f A,  Point P = (%.2f, %.2f, %.2f) m\n', I, P);
fprintf('--------------------------------------------\n');
fprintf('Numerical  B = [%.4e, %.4e, %.4e] T\n', B_num);
fprintf('Analytical B = [%.4e, %.4e, %.4e] T\n', B_ana);
fprintf('|B| (numerical)  = %.4e T\n', norm(B_num));
fprintf('|B| (analytical) = %.4e T\n', norm(B_ana));
fprintf('Relative difference = %.2e %%\n', ...
        100*norm(B_num - B_ana)/max(norm(B_ana), eps));

%% ------------------------ 6. 3D VISUALISATION ---------------------------
figure('Color','w','Name','Biot-Savart: finite straight wire');
hold on; grid on; box on;

% --- Wire (thick line) and current direction arrow
plot3([Ax Ax], [Ay Ay], [z0 z1], 'k-', 'LineWidth', 4);
quiver3(Ax, Ay, z0 + 0.35*l, 0, 0, 0.3*l*sign(I), 0, ...
        'Color', [0.5 0.5 0.5], 'LineWidth', 2, 'MaxHeadSize', 2);

% --- Marker points
plot3(Ax, Ay, Az, 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 9);  % A
plot3(P(1), P(2), P(3), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8); % P
text(Ax, Ay, Az, '  A', 'FontSize', 12, 'FontWeight', 'bold');
text(P(1), P(2), P(3), '  P', 'FontSize', 12, 'FontWeight', 'bold');

% --- Magnetic field vector at P (scaled so the arrow is clearly visible)
scale = 0.4*l / norm(B);            % arrow length = 40% of the wire length
quiver3(P(1), P(2), P(3), B(1)*scale, B(2)*scale, B(3)*scale, 0, ...
        'Color', 'b', 'LineWidth', 2.5, 'MaxHeadSize', 1.5);

% --- Perpendicular line from the wire axis to P (helps to see geometry)
plot3([Ax P(1)], [Ay P(2)], [P(3) P(3)], 'r--', 'LineWidth', 1);

% --- Formatting
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title(sprintf('Magnetic field of a finite wire (I = %.1f A, l = %.1f m)', I, l));
legend({'Wire','Current direction','Point A','Point P', ...
        'B at P (scaled)','Perpendicular to P'}, 'Location','northeastoutside');
axis equal; view(35, 25);
hold off;

fprintf('\nNote: the plotted B arrow is scaled for visibility; its true\n');
fprintf('magnitude is |B| = %.4e T.\n', norm(B));

%% ----------------------------- LOCAL FUNCTION ---------------------------
function d = Px_minus(a, b)
    % Simple coordinate difference (kept as a function for readability)
    d = a - b;
end
