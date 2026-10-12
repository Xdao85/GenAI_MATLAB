%% Magnetic flux density of a finite straight conductor parallel to the z axis
% The conductor starts at A(Ax,Ay,Az) and extends a length l in +z.
% Biot-Savart result:
%   B = mu0*I/(4*pi*rho) * (sin(a2) - sin(a1)) * phi_hat
% with rho = perpendicular distance from the wire to P.
clear; clc; close all;

%% ---------------- Inputs ----------------
mu0 = 4*pi*1e-7;          % permeability of free space [H/m]
I   = 1;                 % current [A] (positive = +z direction)
l   = 2;                  % conductor length [m]
A   = [0.25, 0.5, 0];          % start point of the conductor [Ax Ay Az]
P   = [1, 1, 0];    % field point [Px Py Pz]

%% ---------------- Field computation ----------------
B = wireB(P, A, l, I, mu0);
fprintf('B at P = [%.4e  %.4e  %.4e] T,  |B| = %.4e T\n', B, norm(B));

%% ---------------- Plot ----------------
figure('Color','w'); hold on; grid on; axis equal; view(35,25);

% conductor
zEnd = A(3) + l;
plot3([A(1) A(1)], [A(2) A(2)], [A(3) zEnd], 'r', 'LineWidth', 4);
quiver3(A(1), A(2), zEnd - 0.3*l, 0, 0, 0.3*l, 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 2); % current direction

% field point and perpendicular foot on the wire's line
plot3(P(1), P(2), P(3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 7);
plot3([A(1) P(1)], [A(2) P(2)], [P(3) P(3)], 'k--');

% B vector at P (scaled for visibility)
scale = 0.5*max(l, norm(P - A)) / norm(B);
quiver3(P(1), P(2), P(3), B(1)*scale, B(2)*scale, B(3)*scale, 0, ...
        'b', 'LineWidth', 2.5, 'MaxHeadSize', 1);

% optional: field on a ring of points around the wire at the height of P
rho = hypot(P(1)-A(1), P(2)-A(2));
th  = linspace(0, 2*pi, 13); th(end) = [];
for k = 1:numel(th)
    Q  = [A(1)+rho*cos(th(k)), A(2)+rho*sin(th(k)), P(3)];
    Bq = wireB(Q, A, l, I, mu0);
    quiver3(Q(1), Q(2), Q(3), Bq(1)*scale, Bq(2)*scale, Bq(3)*scale, 0, ...
            'Color', [0.4 0.6 1], 'LineWidth', 1);
end

text(P(1), P(2), P(3), sprintf('  P, |B| = %.2e T', norm(B)));
text(A(1), A(2), A(3), '  A');
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title('Magnetic flux density of a finite current-carrying conductor');
legend({'Conductor','Current direction','Point P','Perpendicular','B at P','B around wire'}, ...
       'Location','best');

%% ---------------- Local function ----------------
function B = wireB(P, A, l, I, mu0)
    dx  = P(1) - A(1);
    dy  = P(2) - A(2);
    rho = hypot(dx, dy);
    if rho < 1e-12
        B = [0 0 0];          % P on the wire axis: field undefined, return 0
        return
    end
    z1 = A(3)     - P(3);     % wire ends relative to P
    z2 = A(3) + l - P(3);
    Bmag = mu0*I/(4*pi*rho) * ( z2/sqrt(rho^2 + z2^2) - z1/sqrt(rho^2 + z1^2) );
    phi_hat = [-dy, dx, 0] / rho;   % z_hat x rho_hat (right-hand rule)
    B = Bmag * phi_hat;
end
