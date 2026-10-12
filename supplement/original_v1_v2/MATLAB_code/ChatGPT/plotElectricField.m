function plotElectricField(P, E, r1, q1, r2, q2)
% plotElectricField
%
% Visualizes the electric field vector at point P using quiver3.
%
% INPUTS:
%   P  - Observation point [x, y, z]
%   E  - Electric field vector [Ex, Ey, Ez]
%   r1 - Position of charge 1
%   q1 - Magnitude of charge 1
%   r2 - Position of charge 2
%   q2 - Magnitude of charge 2

    %% Create a new figure
    figure('Color', 'w');

    hold on;
    grid on;
    axis equal;

    %% ------------------------------------------------------------
    % Plot charge 1
    % -------------------------------------------------------------
    if q1 > 0
        plot3(r1(1), r1(2), r1(3), ...
            'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
    else
        plot3(r1(1), r1(2), r1(3), ...
            'bo', 'MarkerSize', 12, 'MarkerFaceColor', 'b');
    end

    %% ------------------------------------------------------------
    % Plot charge 2
    % -------------------------------------------------------------
    if q2 > 0
        plot3(r2(1), r2(2), r2(3), ...
            'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
    else
        plot3(r2(1), r2(2), r2(3), ...
            'bo', 'MarkerSize', 12, 'MarkerFaceColor', 'b');
    end

    %% ------------------------------------------------------------
    % Plot observation point P
    % -------------------------------------------------------------
    plot3(P(1), P(2), P(3), ...
        'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'y');

    %% ------------------------------------------------------------
    % Plot electric field vector using quiver3
    % -------------------------------------------------------------
    quiver3(P(1), P(2), P(3), ...
            E(1), E(2), E(3), ...
            0, ...                 % No automatic vector scaling
            'LineWidth', 2, ...
            'MaxHeadSize', 0.5);

    %% ------------------------------------------------------------
    % Add labels and title
    % -------------------------------------------------------------
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');

    title('Electric Field Vector Due to Two Point Charges');

    %% Legend
    legend('Charge 1', ...
           'Charge 2', ...
           'Observation Point P', ...
           'Electric Field E', ...
           'Location', 'best');

    %% Improve 3D visualization
    view(3);
    axis padded;

    hold off;
    view(120,35)
end