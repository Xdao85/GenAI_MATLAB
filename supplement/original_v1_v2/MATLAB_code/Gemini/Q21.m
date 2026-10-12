% Magnetic Flux Density B of a Finite Straight Conductor in 3D
clear; clc; close all;

%% 1. Physical Constants and Conductor Parameters
mu0 = 4*pi*1e-7;       % Permeability of free space (H/m)
I = 1;                 % Current in Amperes (A)
l = 2.0;                % Length of conductor along z-axis (m)
A = [0.25, 0.5, 0];          % Center position of conductor [Ax, Ay, Az] (m)

% Conductor endpoints
z_start = A(3) - l/2;
z_end   = A(3) + l/2;

%% 2. Define 3D Observation Grid (Evaluation Volume)
grid_range = 1.5;
num_points = 20;

x = linspace(-grid_range, grid_range, num_points) + A(1);
y = linspace(-grid_range, grid_range, num_points) + A(2);
z = linspace(-grid_range, grid_range, num_points) + A(3);

[Px, Py, Pz] = meshgrid(x, y, z);

%% 3. Analytical Field Calculation using Biot-Savart Law
% Radial distance from the conductor axis in the xy-plane
rho = sqrt((Px - A(1)).^2 + (Py - A(2)).^2);

% Avoid singularity exactly at the conductor location
rho(rho < 0.05) = NaN; 

% Distances from field point to conductor endpoints
dz1 = Pz - z_start;
dz2 = Pz - z_end;

R1 = sqrt(rho.^2 + dz1.^2);
R2 = sqrt(rho.^2 + dz2.^2);

% Analytical magnitude B_phi for finite straight segment
% B_phi = (mu0 * I / (4 * pi * rho)) * (cos(alpha1) - cos(alpha2))
cos_alpha1 = dz1 ./ R1;
cos_alpha2 = dz2 ./ R2;

B_phi = (mu0 * I ./ (4 * pi * rho)) .* (cos_alpha1 - cos_alpha2);

% Convert azimuthal vector (phi-direction) to Cartesian components (Bx, By, Bz)
% phi_hat = -sin(phi)*i + cos(phi)*j = (-y/rho)*i + (x/rho)*j
Bx = -B_phi .* (Py - A(2)) ./ rho;
By =  B_phi .* (Px - A(1)) ./ rho;
Bz = zeros(size(Px));  % No z-component for parallel z-oriented wire

%% 4. 3D Plotting
figure('Color', 'w', 'Position', [100, 100, 900, 700]);

% Plot 3D Vector Field (Quiver)
q = quiver3(Px, Py, Pz, Bx, By, Bz, 1.2, 'LineWidth', 1.2);
hold on;

% Plot Current Conductor
plot3([A(1), A(1)], [A(2), A(2)], [z_start, z_end], 'r-', 'LineWidth', 4, 'DisplayName', 'Conductor');
plot3(A(1), A(2), z_end, 'r^', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'DisplayName', 'Current Direction (+z)');

% Formatting
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
title(sprintf('Magnetic Flux Density \\vec{B} around Finite Wire (I = %.1f A, Length = %.1f m)', I, l));
grid on; axis equal;
view(37.5, 30);
colormap(jet);
cb = colorbar;
ylabel(cb, 'Magnetic Field Intensity Scale');

% Add a highlight point P(Px, Py, Pz) demo calculation
P_sample = [1, 1, 0];
[Bx_p, By_p, Bz_p, B_mag] = calculate_B_at_point(P_sample, A, l, I, mu0)
plot3(P_sample(1), P_sample(2), P_sample(3), 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
text(P_sample(1)+0.05, P_sample(2)+0.05, P_sample(3), ...
    sprintf(' P(%.1f, %.1f, %.1f)\n |B| = %.2e T', P_sample(1), P_sample(2), P_sample(3), B_mag), ...
    'FontSize', 9, 'FontWeight', 'bold');

hold off;

% Thêm 
view(120,45)

%% Function: Compute B at a single point P(Px, Py, Pz)
function [Bx, By, Bz, B_mag] = calculate_B_at_point(P, A, l, I, mu0)
    Px = P(1); Py = P(2); Pz = P(3);
    z1 = A(3) - l/2;
    z2 = A(3) + l/2;
    
    rho = sqrt((Px - A(1))^2 + (Py - A(2))^2);
    if rho == 0
        Bx = 0; By = 0; Bz = 0; B_mag = 0;
        return;
    end
    
    R1 = sqrt(rho^2 + (Pz - z1)^2);
    R2 = sqrt(rho^2 + (Pz - z2)^2);
    
    cos_a1 = (Pz - z1) / R1;
    cos_a2 = (Pz - z2) / R2;
    
    B_phi = (mu0 * I / (4 * pi * rho)) * (cos_a1 - cos_a2);
    
    Bx = -B_phi * (Py - A(2)) / rho;
    By =  B_phi * (Px - A(1)) / rho;
    Bz = 0;
    B_mag = sqrt(Bx^2 + By^2 + Bz^2);
end