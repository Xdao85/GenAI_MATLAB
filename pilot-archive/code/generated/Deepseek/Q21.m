%% Magnetic Flux Density of a Finite Linear Conductor (Parallel to z-axis)
% Computes B at point P due to a straight wire of length l carrying current I
% Author: (Generated)
clear; clc; close all;

%% ---------------- USER PARAMETERS ----------------
mu0 = 4*pi*1e-7;      % Permeability of free space (H/m)

% Conductor parameters
I  = 1;              % Current (A) - sign gives direction along z
l  = 2;               % Length of conductor (m)

% Reference point A (one end of the conductor, or its midpoint - see note)
Ax = 0.25;  Ay = 0.5;  Az = 0;   % A is the LOWER end of the wire

% Observation point P
Px = 1;  Py = 1;  Pz = 0;

% Number of segments for numerical verification (optional)
Nseg = 2000;

%% ---------------- GEOMETRY ----------------
% Wire runs parallel to z-axis from z1 to z2
z1 = Az;            % lower end
z2 = Az + l;        % upper end (if I > 0, current flows +z)

% Vector from A to P (perpendicular distance vector in xy-plane)
dx = Px - Ax;
dy = Py - Ay;
rho = sqrt(dx^2 + dy^2);   % perpendicular distance from wire axis

if rho < 1e-12
    error('Point P lies on the conductor axis. B is singular there.');
end

%% ---------------- ANALYTICAL SOLUTION ----------------
% Unit azimuthal vector phi_hat = (-dy, dx, 0)/rho
phi_hat = [-dy, dx, 0]/rho;

% Perpendicular distances along wire
% sin(theta) terms using the standard finite-wire formula
cos_th1 = (z1 - Pz)/sqrt(rho^2 + (z1 - Pz)^2);
cos_th2 = (z2 - Pz)/sqrt(rho^2 + (z2 - Pz)^2);

% B magnitude (azimuthal)
Bmag = (mu0*I/(4*pi*rho)) * (cos_th1 - cos_th2);

% B vector (analytical)
B_analytic = Bmag * phi_hat;

fprintf('--- Analytical Result ---\n');
fprintf('B = [%g, %g, %g] T\n', B_analytic);
fprintf('|B| = %g T\n\n', norm(B_analytic));

%% ---------------- NUMERICAL VERIFICATION (Biot-Savart) ----------------
z = linspace(z1, z2, Nseg);
dz = z(2) - z(1);
B_num = [0 0 0];
for k = 1:Nseg
    % Source point on wire
    rs = [Ax, Ay, z(k)];
    % Vector from source to field point
    R  = [Px, Py, Pz] - rs;
    Rm = norm(R);
    % dl x R  with dl = [0 0 I*dz]
    dl = [0, 0, I*dz];
    B_num = B_num + cross(dl, R)/Rm^3;
end
B_num = (mu0/(4*pi)) * B_num;

fprintf('--- Numerical (Biot-Savart) Result ---\n');
fprintf('B = [%g, %g, %g] T\n', B_num);
fprintf('|B| = %g T\n\n', norm(B_num));

%% ---------------- 3D PLOT ----------------
figure('Color','w','Position',[100 100 900 700]);
hold on; grid on; axis equal;
view(35, 25);

% --- Plot the conductor ---
plot3([Ax Ax],[Ay Ay],[z1 z2],'k-','LineWidth',4);
% Arrowhead showing current direction
quiver3(Ax, Ay, (z1+z2)/2, 0, 0, sign(I)*l/4, ...
        'k','LineWidth',2,'MaxHeadSize',2,'AutoScale','off');
text(Ax, Ay, z2+0.1*max(l,1), 'I', 'FontSize',14,'FontWeight','bold');

% --- Plot point A ---
plot3(Ax, Ay, Az,'ko','MarkerFaceColor','k','MarkerSize',8);
text(Ax+0.05, Ay+0.05, Az-0.1, 'A','FontSize',12,'FontWeight','bold');

% --- Plot point P ---
plot3(Px, Py, Pz,'ro','MarkerFaceColor','r','MarkerSize',8);
text(Px+0.05, Py+0.05, Pz, 'P','FontSize',12,'FontWeight','bold');

% --- Perpendicular foot on wire (same z as P, projected onto wire axis) ---
foot = [Ax, Ay, Pz];
plot3([Px foot(1)],[Py foot(2)],[Pz foot(3)],'b--','LineWidth',1.2);
plot3(foot(1),foot(2),foot(3),'bs','MarkerSize',6,'MarkerFaceColor','b');
text(foot(1)+0.05, foot(2)+0.05, foot(3)-0.1, '\rho','Color','b','FontSize',12);

% --- Plot the B vector at P (scaled for visibility) ---
Bscale = 0.4*max(l,1) / max(norm(B_analytic),eps);
Bplot  = B_analytic * Bscale;
quiver3(Px, Py, Pz, Bplot(1), Bplot(2), Bplot(3), ...
        0, 'r', 'LineWidth', 2.5, 'MaxHeadSize', 0.8);
text(Px+Bplot(1), Py+Bplot(2), Pz+Bplot(3), ...
     sprintf('  B (|B|=%.3e T)', norm(B_analytic)), ...
     'Color','r','FontSize',11,'FontWeight','bold');

% --- Plot a few additional B-vectors around the wire for context ---
[Zg, Ag] = meshgrid(linspace(z1, z2, 6), linspace(0, 2*pi, 12));
Rring = 0.6*max(l,1);
Xg = Ax + Rring*cos(Ag);
Yg = Ay + Rring*sin(Ag);
for i = 1:size(Zg,1)
    for j = 1:size(Zg,2)
        Ppx = Xg(i,j); Ppy = Yg(i,j); Ppz = Zg(i,j);
        dxr = Ppx - Ax; dyr = Ppy - Ay;
        rhor = sqrt(dxr^2 + dyr^2);
        if rhor < 1e-9, continue; end
        ph = [-dyr, dxr, 0]/rhor;
        c1 = (z1 - Ppz)/sqrt(rhor^2 + (z1 - Ppz)^2);
        c2 = (z2 - Ppz)/sqrt(rhor^2 + (z2 - Ppz)^2);
        Bm = (mu0*I/(4*pi*rhor))*(c1 - c2);
        Bv = Bm*ph;
        s  = 0.15*max(l,1)/max(norm(Bv),eps);
        quiver3(Ppx,Ppy,Ppz, Bv(1)*s, Bv(2)*s, Bv(3)*s, ...
                0,'Color',[0.4 0.6 1],'LineWidth',0.8,'MaxHeadSize',0.4);
    end
end

xlabel('x (m)','FontWeight','bold');
ylabel('y (m)','FontWeight','bold');
zlabel('z (m)','FontWeight','bold');
title(sprintf(['Magnetic Flux Density of a Finite Linear Conductor\n' ...
               'I = %.2f A,  l = %.2f m,  P = (%.2f, %.2f, %.2f)'], ...
               I, l, Px, Py, Pz), 'FontSize',12);
legend({'Conductor','Current direction','Point A','Point P', ...
        '\rho (perp.)','B at P','B-field samples'}, ...
        'Location','northeastoutside');
hold off;

% Thêm 
view(120,45)