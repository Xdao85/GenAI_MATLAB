%% Electric field at point P due to two point charges (3D visualization)
clear; clc; close all;

%% ---------------- User inputs ----------------
k  = 8.9875517923e9;          % Coulomb constant [N*m^2/C^2]

q1 = +2e-9;   r1 = [ 1.0,  0.0,  0.0];   % charge 1 [C] and position [m]
q2 = -3e-9;   r2 = [-1.0,  0.5,  0.5];   % charge 2 [C] and position [m]

P  = [0.5, 1.5, 1.0];                    % field point P = (Px, Py, Pz) [m]

%% ---------------- Field calculation ----------------
E1 = efield(q1, r1, P, k);    % field of charge 1 at P
E2 = efield(q2, r2, P, k);    % field of charge 2 at P
Et = E1 + E2;                 % superposition

fprintf('E1    = [%+.4g %+.4g %+.4g] N/C, |E1| = %.4g N/C\n', E1, norm(E1));
fprintf('E2    = [%+.4g %+.4g %+.4g] N/C, |E2| = %.4g N/C\n', E2, norm(E2));
fprintf('Etot  = [%+.4g %+.4g %+.4g] N/C, |Etot| = %.4g N/C\n', Et, norm(Et));

%% ---------------- Plot ----------------
figure('Color','w','Name','E field at P','Position',[100 100 800 650]);
hold on; grid on; axis equal; view(35, 25);
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title('Electric field at P due to two point charges');

% Charges as spheres (red = positive, blue = negative)
[sx, sy, sz] = sphere(24);
rad = 0.08;
drawCharge(q1, r1, rad, sx, sy, sz);
drawCharge(q2, r2, rad, sx, sy, sz);
text(r1(1), r1(2), r1(3)+0.2, sprintf('q_1 = %+.1f nC', q1*1e9), 'HorizontalAlignment','center');
text(r2(1), r2(2), r2(3)+0.2, sprintf('q_2 = %+.1f nC', q2*1e9), 'HorizontalAlignment','center');

% Field point
plot3(P(1), P(2), P(3), 'ko', 'MarkerFaceColor','k', 'MarkerSize', 7);
text(P(1), P(2), P(3)+0.2, 'P', 'FontWeight','bold', 'HorizontalAlignment','center');

% Dashed lines from each charge to P
plot3([r1(1) P(1)], [r1(2) P(2)], [r1(3) P(3)], 'k:');
plot3([r2(1) P(1)], [r2(2) P(2)], [r2(3) P(3)], 'k:');

% Scale arrows so the largest has a fixed visual length (field magnitudes are huge/small)
L     = max([norm(r1-r2), norm(P-r1), norm(P-r2)]);   % characteristic length
scale = 0.6 * L / max([norm(E1), norm(E2), norm(Et)]);

h1 = quiver3(P(1),P(2),P(3), scale*E1(1),scale*E1(2),scale*E1(3), 0, ...
             'Color',[0.85 0.33 0.10], 'LineWidth',2, 'MaxHeadSize',0.6);
h2 = quiver3(P(1),P(2),P(3), scale*E2(1),scale*E2(2),scale*E2(3), 0, ...
             'Color',[0.00 0.45 0.74], 'LineWidth',2, 'MaxHeadSize',0.6);
ht = quiver3(P(1),P(2),P(3), scale*Et(1),scale*Et(2),scale*Et(3), 0, ...
             'Color',[0.47 0.67 0.19], 'LineWidth',3, 'MaxHeadSize',0.6);

% Dashed parallelogram showing the vector addition
plot3(P(1)+scale*[E1(1) Et(1)], P(2)+scale*[E1(2) Et(2)], P(3)+scale*[E1(3) Et(3)], 'k--');
plot3(P(1)+scale*[E2(1) Et(1)], P(2)+scale*[E2(2) Et(2)], P(3)+scale*[E2(3) Et(3)], 'k--');

legend([h1 h2 ht], {'E_1 (from q_1)','E_2 (from q_2)','E_{total}'}, 'Location','best');
camlight; lighting gouraud;
hold off;

%% ---------------- Local functions ----------------
function E = efield(q, rq, P, k)
    % Electric field at P from point charge q located at rq
    R = P - rq;                 % vector from charge to field point
    d = norm(R);
    if d == 0
        error('Field point coincides with a charge: field is undefined.');
    end
    E = k * q * R / d^3;        % E = k q R / |R|^3
end

function drawCharge(q, pos, rad, sx, sy, sz)
    if q >= 0, c = [1 0 0]; else, c = [0 0 1]; end
    surf(pos(1)+rad*sx, pos(2)+rad*sy, pos(3)+rad*sz, ...
         'FaceColor', c, 'EdgeColor','none');
end
