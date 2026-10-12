%% Magnetic Field of a Finite Linear Conductor using Biot-Savart Law
% This script models a straight conductor parallel to z-axis and computes
% the magnetic field at a point P using numerical integration

clear; clc; close all;

%% Parameters
% Conductor parameters
l = 2.0;                    % Length of conductor [m]
I = 1.0;                    % Current [A]
A = [0.25, 0.5, 0];              % Starting point of conductor center [m]

% Point where magnetic field is computed
P = [1, 1, 0];        % Observation point [m]

% Physical constants
mu0 = 4*pi*1e-7;            % Permeability of free space [H/m]

%% Conductor Geometry
% The conductor is parallel to z-axis, centered at point A
% It extends from z = Az - l/2 to z = Az + l/2
z_start = A(3) - l/2;
z_end = A(3) + l/2;

% Conductor endpoints
conductor_start = [A(1), A(2), z_start];
conductor_end = [A(1), A(2), z_end];

%% Compute Magnetic Field using Biot-Savart Law
% B = (mu0*I/4*pi) * integral(dl × r_hat / r^2)
% where dl is differential length element along conductor
% r is vector from source to observation point

% Numerical integration parameters
N = 1000;                   % Number of integration segments
z_segments = linspace(z_start, z_end, N);
dz = (z_end - z_start)/(N-1);

% Initialize magnetic field vector
B = [0, 0, 0];

% Numerical integration
for i = 1:N
    % Current source point
    source_point = [A(1), A(2), z_segments(i)];
    
    % Vector from source to observation point
    r_vec = P - source_point;
    r_mag = norm(r_vec);
    
    % Avoid singularity (if P is on the conductor)
    if r_mag < 1e-6
        warning('Observation point is on the conductor!');
        continue;
    end
    
    % Differential length element (along z-direction)
    dl = [0, 0, dz];
    
    % Contribution to magnetic field
    % dB = (mu0*I/4*pi) * (dl × r_vec) / r^3
    dB = (mu0 * I / (4*pi)) * cross(dl, r_vec) / r_mag^3;
    
    % Accumulate
    B = B + dB;
end

%% Display Results
fprintf('Magnetic Field Calculation Results:\n');
fprintf('-----------------------------------\n');
fprintf('Conductor length: %.2f m\n', l);
fprintf('Current: %.2f A\n', I);
fprintf('Conductor center: [%.2f, %.2f, %.2f] m\n', A);
fprintf('Observation point P: [%.2f, %.2f, %.2f] m\n', P);
fprintf('\nMagnetic field B at point P:\n');
fprintf('Bx = %.4e T\n', B(1));
fprintf('By = %.4e T\n', B(2));
fprintf('Bz = %.4e T\n', B(3));
fprintf('|B| = %.4e T\n', norm(B));

%% Visualization
figure('Position', [100, 100, 1200, 500]);

% Subplot 1: 3D visualization
subplot(1, 2, 1);
hold on; grid on; axis equal;
view(45, 30);

% Plot conductor
plot3([conductor_start(1), conductor_end(1)], ...
      [conductor_start(2), conductor_end(2)], ...
      [conductor_start(3), conductor_end(3)], ...
      'k-', 'LineWidth', 3);

% Add arrow to show current direction
mid_point = [A(1), A(2), A(3)];
arrow_length = l/4;
quiver3(mid_point(1), mid_point(2), mid_point(3), ...
        0, 0, arrow_length, ...
        'Color', 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5);

% Plot point A (conductor center)
plot3(A(1), A(2), A(3), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
text(A(1)+0.1, A(2)+0.1, A(3), 'A', 'FontSize', 12, 'FontWeight', 'bold');

% Plot observation point P
plot3(P(1), P(2), P(3), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(P(1)+0.1, P(2)+0.1, P(3), 'P', 'FontSize', 12, 'FontWeight', 'bold');

% Plot magnetic field vector at P (scaled for visibility)
B_scale = 0.5 / max(abs(B));  % Scale factor for visualization
if norm(B) > 0
    quiver3(P(1), P(2), P(3), ...
            B(1)*B_scale, B(2)*B_scale, B(3)*B_scale, ...
            'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);
end

% Labels and title
xlabel('x [m]', 'FontSize', 11);
ylabel('y [m]', 'FontSize', 11);
zlabel('z [m]', 'FontSize', 11);
title('3D Visualization of Conductor and Magnetic Field', 'FontSize', 12);

% Legend
legend('Conductor', 'Current direction', 'Point A', 'Point P', ...
       'Magnetic field B', 'Location', 'best');


% Subplot 2: Detailed view of magnetic field
subplot(1, 2, 2);
hold on; grid on; axis equal;
view(45, 30);

% Plot conductor (zoomed view)
plot3([conductor_start(1), conductor_end(1)], ...
      [conductor_start(2), conductor_end(2)], ...
      [conductor_start(3), conductor_end(3)], ...
      'k-', 'LineWidth', 3);

% Plot observation point
plot3(P(1), P(2), P(3), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');

% Plot magnetic field vector with larger scale
if norm(B) > 0
    quiver3(P(1), P(2), P(3), ...
            B(1)*B_scale*2, B(2)*B_scale*2, B(3)*B_scale*2, ...
            'b', 'LineWidth', 3, 'MaxHeadSize', 0.5);
end

% Plot position vector from conductor to P
plot3([A(1), P(1)], [A(2), P(2)], [A(3), P(3)], ...
      'g--', 'LineWidth', 1.5);
text((A(1)+P(1))/2, (A(2)+P(2))/2, (A(3)+P(3))/2, 'r', ...
     'FontSize', 10, 'Color', 'g');

% Set axis limits for better view
axis_range = 1.5 * max([abs(P - A), l/2]);
xlim([min([A(1), P(1)]) - 0.5, max([A(1), P(1)]) + 0.5]);
ylim([min([A(2), P(2)]) - 0.5, max([A(2), P(2)]) + 0.5]);
zlim([min([A(3), P(3)]) - 0.5, max([A(3), P(3)]) + 0.5]);

% Labels and title
xlabel('x [m]', 'FontSize', 11);
ylabel('y [m]', 'FontSize', 11);
zlabel('z [m]', 'FontSize', 11);
title('Detailed View: Magnetic Field Vector at P', 'FontSize', 12);

% Add text with field magnitude
text_str = sprintf('|B| = %.3e T', norm(B));
text(P(1)+0.2, P(2)+0.2, P(3)+0.2, text_str, ...
     'FontSize', 10, 'BackgroundColor', 'w', 'EdgeColor', 'k');


%% Additional Analysis: Field along a line
% Optional: Compute and plot field magnitude along a line

figure('Position', [100, 100, 800, 400]);
hold on; grid on;

% Define a line along x-axis at y = P(2), z = P(3)
x_line = linspace(-2, 2, 100);
B_mag_line = zeros(size(x_line));

for j = 1:length(x_line)
    P_temp = [x_line(j), P(2), P(3)];
    B_temp = [0, 0, 0];
    
    for i = 1:N
        source_point = [A(1), A(2), z_segments(i)];
        r_vec = P_temp - source_point;
        r_mag = norm(r_vec);
        
        if r_mag < 1e-6
            continue;
        end
        
        dl = [0, 0, dz];
        dB = (mu0 * I / (4*pi)) * cross(dl, r_vec) / r_mag^3;
        B_temp = B_temp + dB;
    end
    
    B_mag_line(j) = norm(B_temp);
end

plot(x_line, B_mag_line, 'b-', 'LineWidth', 2);
xlabel('x position [m]', 'FontSize', 12);
ylabel('|B| [T]', 'FontSize', 12);
title('Magnetic Field Magnitude along x-axis', 'FontSize', 12);
grid on;

% Mark the point P
plot(P(1), norm(B), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(P(1)+0.1, norm(B), 'P', 'FontSize', 12, 'FontWeight', 'bold');

%% Verification: Analytical solution for infinite wire
% For comparison, compute field for infinite wire
if abs(P(1) - A(1)) > 1e-6 || abs(P(2) - A(2)) > 1e-6
    rho = sqrt((P(1)-A(1))^2 + (P(2)-A(2))^2);
    B_infinite = mu0 * I / (2*pi*rho);
    fprintf('\nComparison with infinite wire approximation:\n');
    fprintf('|B| (finite wire) = %.4e T\n', norm(B));
    fprintf('|B| (infinite wire) = %.4e T\n', B_infinite);
    fprintf('Ratio = %.4f\n', norm(B)/B_infinite);
end

figure;

hold on; grid on; axis equal;
view(45, 30);

% Plot conductor
plot3([conductor_start(1), conductor_end(1)], ...
      [conductor_start(2), conductor_end(2)], ...
      [conductor_start(3), conductor_end(3)], ...
      'k-', 'LineWidth', 3);

% Add arrow to show current direction
mid_point = [A(1), A(2), A(3)];
arrow_length = l/4;
quiver3(mid_point(1), mid_point(2), mid_point(3), ...
        0, 0, arrow_length, ...
        'Color', 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5);

% Plot point A (conductor center)
plot3(A(1), A(2), A(3), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
text(A(1)+0.1, A(2)+0.1, A(3), 'A', 'FontSize', 12, 'FontWeight', 'bold');

% Plot observation point P
plot3(P(1), P(2), P(3), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(P(1)+0.1, P(2)+0.1, P(3), 'P', 'FontSize', 12, 'FontWeight', 'bold');

% Plot magnetic field vector at P (scaled for visibility)
B_scale = 0.5 / max(abs(B));  % Scale factor for visualization
if norm(B) > 0
    quiver3(P(1), P(2), P(3), ...
            B(1)*B_scale, B(2)*B_scale, B(3)*B_scale, ...
            'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);
end

% Labels and title
xlabel('x [m]', 'FontSize', 11);
ylabel('y [m]', 'FontSize', 11);
zlabel('z [m]', 'FontSize', 11);
title('3D Visualization of Conductor and Magnetic Field', 'FontSize', 12);

% Legend
legend('Conductor', 'Current direction', 'Point A', 'Point P', ...
       'Magnetic field B', 'Location', 'best');
% Thêm 
view(120,45)

