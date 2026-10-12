% reference_q1_point_charges.m
% Reference solution for case-study task Q1: electric field of two point charges.
% Parameters as used in the case study:
%   q1 = +2 nC at (-1, 0, 0) m,  q2 = -2 nC at (1, 0, 0) m,  P = (0, 1, 2) m
% Expected result: E1 = (1.2231, 1.2231, 2.4461) V/m
%                  E2 = (1.2231, -1.2231, -2.4461) V/m
%                  E  = (2.4461, 0, 0) V/m,  |E| = 2.4461 V/m

clear; clc;
k  = 8.9875517923e9;            % Coulomb constant (N m^2 / C^2)
q  = [2e-9, -2e-9];             % charges (C)
rq = [-1 0 0; 1 0 0];           % charge positions (m)
P  = [0 1 2];                   % observation point (m)

E = zeros(2, 3);
for n = 1:2
    E(n, :) = pointChargeField(q(n), rq(n, :), P, k);
end
Et = sum(E, 1);

fprintf('E1 = [%.4f %.4f %.4f] V/m\n', E(1, :));
fprintf('E2 = [%.4f %.4f %.4f] V/m\n', E(2, :));
fprintf('E  = [%.4f %.4f %.4f] V/m, |E| = %.4f V/m\n', Et, norm(Et));

% Visualization
figure; hold on; grid on; axis equal; view(3);
plot3(rq(1,1), rq(1,2), rq(1,3), 'ro', 'MarkerFaceColor', 'r');
plot3(rq(2,1), rq(2,2), rq(2,3), 'bo', 'MarkerFaceColor', 'b');
plot3(P(1), P(2), P(3), 'ko', 'MarkerFaceColor', 'k');
s = 0.5 / norm(Et);             % arrow scaling for display only
quiver3(P(1), P(2), P(3), s*Et(1), s*Et(2), s*Et(3), 0, 'g', 'LineWidth', 2);
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
legend('q_1 > 0', 'q_2 < 0', 'P', 'E (scaled)');
title('Electric field at P due to two point charges');

function E = pointChargeField(q, rq, P, k)
% Coulomb's law: E = k q (P - rq) / |P - rq|^3
    R = P - rq;
    E = k * q * R / norm(R)^3;
end
