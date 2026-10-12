function gps_gui_simulation()
    % GPS_GUI_SIMULATION - Interactive 3D GPS Satellite Constellation & Receiver Simulator
    %
    % Highlights:
    %   1. Real-Time 3D Orbital Dynamics & Signal Propagation Visualizer
    %   2. Mathematical Formula Panel rendered with LaTeX
    %   3. Interactive Controls (Noise, Clock Bias, Speed, Start/Pause)
    %   4. Core MATLAB Function Documentation Panel
    %   5. Iterative Gauss-Newton Least-Squares Solver for 3D Position & Clock Bias

    clear; close all;

    % =========================================================================
    % SECTION 1: GLOBAL SIMULATION PARAMETERS & CONSTANTS
    % =========================================================================
    R_earth = 6371;             % Mean Earth radius (km)
    R_orbit = 26560;            % GPS orbit radius (km)
    c_speed = 299792.458;       % Speed of light (km/s) - normalized
    
    % Constellation setup (6 Satellites across multiple orbital planes)
    num_sats = 6;
    sat_inclinations = [55, 55, 55, -55, -55, 55] * (pi/180); % Radian inclinations
    sat_RAAN = [0, 60, 120, 180, 240, 300] * (pi/180);         % Right Ascension of Ascending Node
    sat_angles = [0, 45, 90, 135, 180, 225] * (pi/180);       % Initial orbital phases
    sat_speed = 0.015;                                        % Angular speed (rad/frame)

    % Dynamic state variables container
    sim_data = struct(...
        'running', false, ...
        'time', 0, ...
        'noise_std', 5.0, ...         % Pseudorange noise std dev (km)
        'clock_bias', 15.0, ...       % Receiver clock bias error (km equivalent)
        'speed_factor', 1.0, ...
        'sat_pos', zeros(num_sats, 3), ...
        'user_pos_true', zeros(1, 3), ...
        'user_pos_est', zeros(1, 3), ...
        'est_bias', 0 ...
    );

    % =========================================================================
    % SECTION 2: GUI LAYOUT & COMPONENT CREATION
    % =========================================================================
    % Main Figure Window
    main_fig = uifigure('Name', 'GPS Technology Dynamics & Multilateration Simulator', ...
        'Position', [100, 100, 1300, 750], ...
        'Color', [0.10, 0.12, 0.15]);

    % Grid Layout: 1 Row, 2 Main Columns (Visualizer | Control & Math Panel)
    main_layout = uigridlayout(main_fig, [1, 2]);
    main_layout.ColumnWidth = {'1.2x', '1x'};

    % -------------------------------------------------------------------------
    % LEFT COLUMN: 3D Graphics Panel
    % -------------------------------------------------------------------------
    pnl_vis = uipanel(main_layout, 'Title', '3D Constellation & Receiver Tracking', ...
        'BackgroundColor', [0.14, 0.16, 0.20], 'ForegroundColor', 'white', ...
        'FontSize', 12, 'FontWeight', 'bold');
    vis_layout = uigridlayout(pnl_vis, [1, 1]);
    
    ax3d = uiaxes(vis_layout);
    ax3d.BackgroundColor = [0.05, 0.05, 0.08];
    ax3d.XColor = [0.7 0.7 0.7]; ax3d.YColor = [0.7 0.7 0.7]; ax3d.ZColor = [0.7 0.7 0.7];
    grid(ax3d, 'on'); hold(ax3d, 'on');
    view(ax3d, 3);
    title(ax3d, 'Real-Time Earth, Satellites & Pseudorange Rays', 'Color', 'w');
    xlabel(ax3d, 'X (km)'); ylabel(ax3d, 'Y (km)'); zlabel(ax3d, 'Z (km)');
    axis(ax3d, 'equal');
    xlim(ax3d, [-30000 30000]); ylim(ax3d, [-30000 30000]); zlim(ax3d, [-30000 30000]);

    % Draw static 3D Earth model
    [Xe, Ye, Ze] = sphere(35);
    surf(ax3d, Xe*R_earth, Ye*R_earth, Ze*R_earth, ...
        'FaceColor', [0.1, 0.4, 0.8], 'EdgeColor', [0.2, 0.3, 0.5], 'FaceAlpha', 0.85);

    % Plot Handles initialization
    h_sat_dots = plot3(ax3d, 0, 0, 0, 'y^', 'MarkerSize', 9, 'MarkerFaceColor', 'yellow', 'DisplayName', 'Satellites');
    h_user_true = plot3(ax3d, 0, 0, 0, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'green', 'DisplayName', 'True Position');
    h_user_est  = plot3(ax3d, 0, 0, 0, 'rx', 'MarkerSize', 12, 'LineWidth', 2.5, 'DisplayName', 'Estimated Position');
    h_rays = plot3(ax3d, nan, nan, nan, 'c--', 'LineWidth', 0.8, 'DisplayName', 'Pseudoranges (\rho_i)');
    legend(ax3d, [h_sat_dots, h_user_true, h_user_est, h_rays], 'TextColor', 'w', 'Location', 'northeast');

    % -------------------------------------------------------------------------
    % RIGHT COLUMN: Math Formulas, Control Controls, MATLAB Doc Panels
    % -------------------------------------------------------------------------
    right_container = uigridlayout(main_layout, [3, 1]);
    right_container.RowHeight = {'1.1x', '1x', '1.2x'};

    % 1. LaTeX Mathematical Equations Display Panel
    pnl_math = uipanel(right_container, 'Title', 'Core Mathematical Equations (LaTeX)', ...
        'BackgroundColor', [0.14, 0.16, 0.20], 'ForegroundColor', 'cyan', ...
        'FontSize', 11, 'FontWeight', 'bold');
    
    ax_math = uiaxes(pnl_math, 'Position', [10 10 560 180]);
    ax_math.BackgroundColor = [0.14 0.16 0.20];
    ax_math.XColor = 'none'; ax_math.YColor = 'none';
    
    % Render LaTeX equations inside GUI axes
    text(ax_math, 0.02, 0.85, '$$\mathbf{1.\ Pseudorange\ Model:}\quad \rho_i = \|\mathbf{r}_i - \mathbf{r}_u\| + c \cdot b_u + \epsilon_i$$', ...
        'Interpreter', 'latex', 'FontSize', 11, 'Color', [0.9 0.9 0.4]);
    text(ax_math, 0.02, 0.55, '$$\mathbf{2.\ Geometry\ Matrix:}\quad \mathbf{H}_i = \left[-\frac{(x_i-\hat{x})}{\hat{d}_i},\ -\frac{(y_i-\hat{y})}{\hat{d}_i},\ -\frac{(z_i-\hat{z})}{\hat{d}_i},\ 1\right]$$', ...
        'Interpreter', 'latex', 'FontSize', 11, 'Color', [0.4 0.9 0.9]);
    text(ax_math, 0.02, 0.22, '$$\mathbf{3.\ Gauss\text{-}Newton\ Step:}\quad \Delta\mathbf{x} = (\mathbf{H}^T\mathbf{H})^{-1}\mathbf{H}^T \Delta\mathbf{\rho} = \mathbf{H} \backslash \Delta\mathbf{\rho}$$', ...
        'Interpreter', 'latex', 'FontSize', 11, 'Color', [0.4 1.0 0.4]);

    % 2. Control Interactive Dashboard
    pnl_ctrl = uipanel(right_container, 'Title', 'Interactive Simulation Controls', ...
        'BackgroundColor', [0.14, 0.16, 0.20], 'ForegroundColor', 'white', ...
        'FontSize', 11, 'FontWeight', 'bold');
    ctrl_grid = uigridlayout(pnl_ctrl, [3, 4]);
    ctrl_grid.RowHeight = {'1x', '1x', '1x'};

    % Buttons
    btn_toggle = uibutton(ctrl_grid, 'state', 'Text', 'START SIMULATION', ...
        'BackgroundColor', [0.2 0.7 0.3], 'FontWeight', 'bold', 'FontSize', 11, ...
        'ValueChangedFcn', @(src, event) toggle_sim(src));
    btn_toggle.Layout.Row = 1; btn_toggle.Layout.Column = [1 2];

    lbl_error = uilabel(ctrl_grid, 'Text', 'Pos Error: 0.00 km', ...
        'FontColor', [1 0.4 0.4], 'FontWeight', 'bold', 'FontSize', 11);
    lbl_error.Layout.Row = 1; lbl_error.Layout.Column = [3 4];

    % Noise Slider
    uilabel(ctrl_grid, 'Text', 'Noise (\sigma):', 'FontColor', 'w');
    sld_noise = uislider(ctrl_grid, 'Limits', [0 20], 'Value', sim_data.noise_std, ...
        'ValueChangedFcn', @(src, event) update_param('noise', src.Value));
    sld_noise.Layout.Column = [2 4];

    % Clock Bias Slider
    uilabel(ctrl_grid, 'Text', 'Clock Bias:', 'FontColor', 'w');
    sld_bias = uislider(ctrl_grid, 'Limits', [0 50], 'Value', sim_data.clock_bias, ...
        'ValueChangedFcn', @(src, event) update_param('bias', src.Value));
    sld_bias.Layout.Column = [2 4];

    % 3. Core MATLAB Functions Documentation Panel
    pnl_docs = uipanel(right_container, 'Title', 'Core MATLAB Functions Documentation', ...
        'BackgroundColor', [0.14, 0.16, 0.20], 'ForegroundColor', 'yellow', ...
        'FontSize', 11, 'FontWeight', 'bold');
    
    doc_txt = sprintf([...
        '• norm(r_sat - r_user): Computes Euclidean distance d_i = ||r_i - r_u||\n' ...
        '• mldivide (\\): Solves H * dx = d_rho via Least-Squares regression [dx = H \\ d_rho]\n' ...
        '• trace(inv(H''*H)): Calculates Geometric Dilution of Precision (GDOP)\n' ...
        '• randn(N, 1): Generates zero-mean Gaussian measurement noise e_i\n' ...
        '• drawnow limitrate: Executes smooth real-time animation updates']);
    
    uitextarea(pnl_docs, 'Value', doc_txt, 'Editable', 'off', ...
        'BackgroundColor', [0.08 0.10 0.13], 'FontColor', [0.8 0.9 1.0], ...
        'FontSize', 10, 'Position', [10 10 560 130]);

    % Static Satellite Orbit Lines Visualization
    draw_orbit_rings(ax3d, num_sats, sat_inclinations, sat_RAAN, R_orbit);

    % =========================================================================
    % SECTION 3: CALLBACKS & REAL-TIME SIMULATION LOOP
    % =========================================================================
    function toggle_sim(btn)
        sim_data.running = btn.Value;
        if sim_data.running
            btn.Text = 'PAUSE SIMULATION';
            btn.BackgroundColor = [0.8 0.3 0.2];
            run_simulation();
        else
            btn.Text = 'RESUME SIMULATION';
            btn.BackgroundColor = [0.2 0.7 0.3];
        end
    end

    function update_param(param_type, val)
        switch param_type
            case 'noise', sim_data.noise_std = val;
            case 'bias',  sim_data.clock_bias = val;
        end
    end

    function run_simulation()
        while sim_data.running && isvalid(main_fig)
            sim_data.time = sim_data.time + 0.05;
            t = sim_data.time;

            % -----------------------------------------------------------------
            % 3.1 Satellite Orbit Kinematics
            % -----------------------------------------------------------------
            sat_positions = zeros(num_sats, 3);
            for i = 1:num_sats
                angle = sat_angles(i) + sat_speed * t;
                % Primary orbital plane coordinates
                x_orb = R_orbit * cos(angle);
                y_orb = R_orbit * sin(angle);
                
                % 3D Euler coordinate rotation matrix (RAAN & Inclination)
                R_z = [cos(sat_RAAN(i)) -sin(sat_RAAN(i)) 0; sin(sat_RAAN(i)) cos(sat_RAAN(i)) 0; 0 0 1];
                R_x = [1 0 0; 0 cos(sat_inclinations(i)) -sin(sat_inclinations(i)); 0 sin(sat_inclinations(i)) cos(sat_inclinations(i))];
                
                pos_3d = R_z * R_x * [x_orb; y_orb; 0];
                sat_positions(i, :) = pos_3d';
            end
            sim_data.sat_pos = sat_positions;

            % -----------------------------------------------------------------
            % 3.2 Dynamic True User Trajectory on Earth Surface
            % -----------------------------------------------------------------
            lat = 0.3 * sin(0.2 * t); % Dynamic latitude shift
            lon = 0.5 * t;            % Dynamic longitude shift
            u_x = R_earth * cos(lat) * cos(lon);
            u_y = R_earth * cos(lat) * sin(lon);
            u_z = R_earth * sin(lat);
            sim_data.user_pos_true = [u_x, u_y, u_z];

            % -----------------------------------------------------------------
            % 3.3 Pseudorange Generation with Noise & Clock Bias
            % -----------------------------------------------------------------
            pseudoranges = zeros(num_sats, 1);
            for i = 1:num_sats
                true_dist = norm(sat_positions(i, :) - sim_data.user_pos_true);
                noise = sim_data.noise_std * randn(); % Gaussian Noise
                pseudoranges(i) = true_dist + sim_data.clock_bias + noise;
            end

            % -----------------------------------------------------------------
            % 3.4 Multilateration Solver (Gauss-Newton Iterative Method)
            % -----------------------------------------------------------------
            [est_pos, est_b] = solve_gps_position(sat_positions, pseudoranges);
            sim_data.user_pos_est = est_pos;
            sim_data.est_bias = est_b;

            % -----------------------------------------------------------------
            % 3.5 Real-Time Graphical Updates
            % -----------------------------------------------------------------
            % Update Satellite Points
            set(h_sat_dots, 'XData', sat_positions(:, 1), ...
                            'YData', sat_positions(:, 2), ...
                            'ZData', sat_positions(:, 3));

            % Update True & Estimated User Markers
            set(h_user_true, 'XData', u_x, 'YData', u_y, 'ZData', u_z);
            set(h_user_est,  'XData', est_pos(1), 'YData', est_pos(2), 'ZData', est_pos(3));

            % Update Pseudorange Ray Lines
            ray_x = []; ray_y = []; ray_z = [];
            for i = 1:num_sats
                ray_x = [ray_x, sat_positions(i, 1), u_x, nan]; %#ok<AGROW>
                ray_y = [ray_y, sat_positions(i, 2), u_y, nan]; %#ok<AGROW>
                ray_z = [ray_z, sat_positions(i, 3), u_z, nan]; %#ok<AGROW>
            end
            set(h_rays, 'XData', ray_x, 'YData', ray_y, 'ZData', ray_z);

            % Update Error Metrics Panel
            pos_err = norm(sim_data.user_pos_true - sim_data.user_pos_est);
            lbl_error.Text = sprintf('Pos Error: %.2f km', pos_err);

            drawnow limitrate;
            pause(0.03); % Maintain ~30 FPS
        end
    end
end

% =============================================================================
% SECTION 4: HELPER FUNCTIONS (MULTILATERATION & VISUALIZATION)
% =============================================================================

function [r_est, b_est] = solve_gps_position(sat_pos, rho)
    % SOLVE_GPS_POSITION Solves 3D GPS receiver position & clock bias.
    % Uses Gauss-Newton Iterative Non-Linear Least Squares.
    
    N = size(sat_pos, 1);
    % State vector initialization: [x, y, z, c*b]' starting from origin
    x_state = [0; 0; 0; 0]; 

    for iter = 1:8
        r_hat = x_state(1:3)';
        b_hat = x_state(4);

        H = zeros(N, 4);
        delta_rho = zeros(N, 1);

        for i = 1:N
            d_vec = sat_pos(i, :) - r_hat;
            d_est = norm(d_vec); % Core MATLAB Function: Euclidean distance
            if d_est == 0, d_est = 1e-6; end

            % Partial Derivatives for Design Matrix H
            H(i, 1:3) = -d_vec / d_est; 
            H(i, 4)   = 1.0;            % Derivative w.r.t clock bias

            % Predicted pseudorange given current estimate
            rho_pred = d_est + b_hat;
            delta_rho(i) = rho(i) - rho_pred;
        end

        % Core MATLAB Operator: Matrix Left Division (\) for Least-Squares Solution
        delta_x = H \ delta_rho; 
        x_state = x_state + delta_x;

        % Convergence threshold
        if norm(delta_x) < 1e-4
            break;
        end
    end

    r_est = x_state(1:3)';
    b_est = x_state(4);
end

function draw_orbit_rings(ax, num_sats, inclinations, RAAN, R_orbit)
    % DRAWORBITRINGS Visualizes circular 3D trajectory orbits for satellites
    theta = linewidth_space_circle(100);
    for i = 1:num_sats
        x_ring = R_orbit * cos(theta);
        y_ring = R_orbit * sin(theta);
        z_ring = zeros(size(theta));

        R_z = [cos(RAAN(i)) -sin(RAAN(i)) 0; sin(RAAN(i)) cos(RAAN(i)) 0; 0 0 1];
        R_x = [1 0 0; 0 cos(inclinations(i)) -sin(inclinations(i)); 0 sin(inclinations(i)) cos(inclinations(i))];

        pts = R_z * R_x * [x_ring; y_ring; z_ring];
        plot3(ax, pts(1, :), pts(2, :), pts(3, :), 'Color', [0.3 0.4 0.5], 'LineStyle', ':');
    end
end

function t = linewidth_space_circle(N)
    t = linspace(0, 2*pi, N);
end