%% ========================================================================
%  BIOT-SAVART LAW: MAGNETIC FIELD OF A FINITE STRAIGHT CONDUCTOR
%  ------------------------------------------------------------------------
%  A straight wire of length l carries current I and is parallel to the
%  z-axis. Point A = (Ax,Ay,Az) is the LOWER END of the wire, so the wire
%  runs from (Ax,Ay,Az) to (Ax,Ay,Az+l). Current flows in the +z direction.
%  (To use A as the wire's midpoint, see the note in Section 2.)
%
%  The field B at P = (Px,Py,Pz) is computed:
%     (a) numerically, by summing the Biot-Savart contribution of many
%         small current elements, and
%     (b) analytically (closed form), as a cross-check.
%  The result is drawn in 3D with quiver3 (vector arrow).
%
%  Biot-Savart law:   dB = (mu0/4pi) * I * (dl x r) / |r|^3
%     dl : vector element of wire (along the current)
%     r  : vector from the current element to the field point P
% ========================================================================
clear; clc; close all;

%% 1. INPUT PARAMETERS (edit these) --------------------------------------
mu0 = 4*pi*1e-7;          % Permeability of free space [T*m/A]
I   = 1;                 % Current [A]
l   = 2;                  % Wire length [m]

A = [0.25, 0.5, 0];            % Wire start point A = (Ax, Ay, Az) [m]
P = [1, 1, 0];      % Field point P = (Px, Py, Pz) [m]

N = 2000;                 % Number of wire segments for numerical integration

%% 2. WIRE GEOMETRY ------------------------------------------------------
% Wire runs parallel to z: from A to A + [0 0 l].
zStart = A(3);
zEnd   = A(3) + l;
% NOTE: for A at the wire's CENTER use instead:
%   zStart = A(3) - l/2;   zEnd = A(3) + l/2;

% Divide the wire into N segments; use segment midpoints as source points
edges = linspace(zStart, zEnd, N+1);       % segment boundaries
zMid  = (edges(1:end-1) + edges(2:end))/2; % midpoint z of each segment
dz    = l / N;                             % length of each segment

src = [A(1)*ones(N,1), A(2)*ones(N,1), zMid(:)];  % N x 3 source positions
dl  = repmat([0, 0, dz], N, 1);                   % N x 3 vector elements dl
                                                  % (+z = current direction)

%% 3. NUMERICAL BIOT-SAVART SUM ------------------------------------------
r      = P - src;                          % vector from each element to P (N x 3)
rmag   = sqrt(sum(r.^2, 2));               % |r| for each element (N x 1)

if any(rmag < 1e-9)
    error('Point P lies on the wire: field is singular there.');
end

dB = (mu0*I/(4*pi)) * cross(dl, r, 2) ./ rmag.^3;  % contribution of each element
B_num = sum(dB, 1);                        % total field (1 x 3) [T]

%% 4. ANALYTICAL CHECK ---------------------------------------------------
% Perpendicular distance from the wire axis to P
dx = P(1) - A(1);
dy = P(2) - A(2);
d  = hypot(dx, dy);

% z-coordinates of the wire ends measured relative to P
s1 = zStart - P(3);
s2 = zEnd   - P(3);

% Magnitude: B = mu0*I/(4*pi*d) * (sin(theta2) - sin(theta1))
B_mag_an = mu0*I/(4*pi*d) * ( s2/sqrt(s2^2 + d^2) - s1/sqrt(s1^2 + d^2) );

% Direction: azimuthal unit vector  phi_hat = z_hat x rho_hat
phi_hat = [-dy, dx, 0] / d;
B_an    = B_mag_an * phi_hat;              % 1 x 3 [T]

%% 5. DISPLAY RESULTS ----------------------------------------------------
fprintf('--- Magnetic field at P = (%.3f, %.3f, %.3f) m ---\n', P);
fprintf('Numerical  B = [%+.6e, %+.6e, %+.6e] T\n', B_num);
fprintf('Analytical B = [%+.6e, %+.6e, %+.6e] T\n', B_an);
fprintf('|B| (numerical)  = %.6e T\n', norm(B_num));
fprintf('|B| (analytical) = %.6e T\n', norm(B_an));
fprintf('Relative difference = %.2e\n', norm(B_num - B_an)/norm(B_an));

%% 6. 3D VISUALIZATION ---------------------------------------------------
figure('Color','w','Name','Biot-Savart: finite wire','Position',[100 100 800 650]);
hold on; grid on; box on;

% 6a. The wire (thick line) from A to its far end
wireEnd = [A(1), A(2), zEnd];
plot3([A(1) wireEnd(1)], [A(2) wireEnd(2)], [A(3) wireEnd(3)], ...
      'k-', 'LineWidth', 4, 'DisplayName', 'Wire');

% 6b. Arrow showing the current direction (+z) at the wire's middle
quiver3(A(1), A(2), (zStart+zEnd)/2 - 0.1*l, 0, 0, 0.2*l, 0, ...
        'Color', [0.85 0.33 0.10], 'LineWidth', 2.5, 'MaxHeadSize', 2, ...
        'DisplayName', 'Current I');

% 6c. Points A and P
plot3(A(1), A(2), A(3), 'ks', 'MarkerFaceColor', 'k', 'MarkerSize', 8, ...
      'HandleVisibility', 'off');
text(A(1), A(2), A(3), '  A', 'FontWeight', 'bold');
plot3(P(1), P(2), P(3), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8, ...
      'DisplayName', 'Field point P');
text(P(1), P(2), P(3), '  P', 'FontWeight', 'bold', 'Color', 'b');

% 6d. Dashed line from the wire axis to P (perpendicular distance d)
plot3([A(1) P(1)], [A(2) P(2)], [P(3) P(3)], 'b:', 'LineWidth', 1, ...
      'HandleVisibility', 'off');

% 6e. Magnetic field vector at P.
%     B is tiny (microtesla scale), so scale the arrow to ~30% of the wire
%     length for visibility. Only the DIRECTION and relative size matter.
scale = 0.3 * l / norm(B_num);
quiver3(P(1), P(2), P(3), B_num(1)*scale, B_num(2)*scale, B_num(3)*scale, ...
        0, 'Color', 'r', 'LineWidth', 2.5, 'MaxHeadSize', 1.5, ...
        'DisplayName', sprintf('B (|B| = %.2e T, arrow scaled)', norm(B_num)));

% 6f. Labels and appearance
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title('Magnetic field of a finite straight wire (Biot-Savart law)');
legend('Location', 'northeast');
axis equal; view(35, 25);
hold off;

% Thêm 
view(120,45)