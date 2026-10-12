function GPS_Dynamics_GUI
%======================================================================
% GPS_Dynamics_GUI
%
% GPS Technology Dynamics Simulator
%
% Compatible with MATLAB R2024b.
%
% FEATURES
%   1. GUI-based GPS simulation.
%   2. GPS equations rendered using LaTeX.
%   3. Explanation of MATLAB functions used in the simulation.
%   4. Dynamic 3-D satellite and receiver animation.
%   5. Real-time pseudorange visualization.
%   6. Iterative least-squares GPS position estimation.
%   7. Start, Stop, Reset and simulation-speed controls.
%
% SAVE THIS FILE AS:
%       GPS_Dynamics_GUI.m
%
% RUN:
%       GPS_Dynamics_GUI
%======================================================================


%% =====================================================================
% SECTION 1: GUI DESIGN
% Create the main application window and graphical components.
%======================================================================

fig = uifigure( ...
    'Name', 'GPS Technology Dynamics Simulator', ...
    'Position', [100 50 1450 850], ...
    'Color', [0.94 0.94 0.94]);

% Main title
uilabel(fig, ...
    'Text', 'GPS Technology Dynamics Simulator', ...
    'FontSize', 22, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', ...
    'Position', [350 800 750 35]);


%% =====================================================================
% SECTION 2: 3-D VISUALIZATION AREA
% Create the axes used for the Earth, satellites, receiver and
% pseudorange lines.
%======================================================================

ax = uiaxes(fig, ...
    'Position', [30 300 850 480]);

title(ax, 'Real-Time GPS Satellite and User Dynamics');
xlabel(ax, 'X (km)');
ylabel(ax, 'Y (km)');
zlabel(ax, 'Z (km)');

grid(ax, 'on');
axis(ax, 'equal');
view(ax, 3);
hold(ax, 'on');


%% =====================================================================
% SECTION 3: SIMULATION CONTROL PANEL
% Create Start, Stop, Reset and simulation-speed controls.
%======================================================================

controlPanel = uipanel(fig, ...
    'Title', 'Simulation Controls', ...
    'FontSize', 13, ...
    'Position', [30 30 850 240]);


% Start button
uibutton(controlPanel, ...
    'push', ...
    'Text', 'Start Simulation', ...
    'FontSize', 12, ...
    'Position', [30 170 180 40], ...
    'ButtonPushedFcn', @startSimulation);


% Stop button
uibutton(controlPanel, ...
    'push', ...
    'Text', 'Stop Simulation', ...
    'FontSize', 12, ...
    'Position', [230 170 180 40], ...
    'ButtonPushedFcn', @stopSimulation);


% Reset button
uibutton(controlPanel, ...
    'push', ...
    'Text', 'Reset', ...
    'FontSize', 12, ...
    'Position', [430 170 150 40], ...
    'ButtonPushedFcn', @resetSimulation);


% Simulation speed label
uilabel(controlPanel, ...
    'Text', 'Simulation Speed:', ...
    'Position', [30 115 130 25]);


% Simulation speed slider
speedSlider = uislider(controlPanel, ...
    'Position', [170 125 350 3], ...
    'Limits', [0.1 2], ...
    'Value', 1);


% Simulation time label
uilabel(controlPanel, ...
    'Text', 'Simulation Time:', ...
    'Position', [30 70 130 25]);


% Current simulation time
timeLabel = uilabel(controlPanel, ...
    'Text', '0.0 s', ...
    'FontWeight', 'bold', ...
    'Position', [170 70 150 25]);


% Position error label
uilabel(controlPanel, ...
    'Text', 'Position Error:', ...
    'Position', [350 70 120 25]);


% Current position error
errorLabel = uilabel(controlPanel, ...
    'Text', '0.00 km', ...
    'FontWeight', 'bold', ...
    'Position', [470 70 150 25]);


%% =====================================================================
% SECTION 4: GPS EQUATIONS
%
% Equations are rendered using MATLAB's LaTeX interpreter.
%
% IMPORTANT:
% Every equation is stored on ONE source-code line to avoid MATLAB
% character-vector termination errors.
%======================================================================

equationPanel = uipanel(fig, ...
    'Title', 'GPS Equations', ...
    'FontSize', 13, ...
    'Position', [910 440 510 340]);


% Axes used exclusively for mathematical equations
eqAx = uiaxes(equationPanel, ...
    'Position', [10 10 490 300]);

eqAx.Visible = 'off';

xlim(eqAx, [0 1]);
ylim(eqAx, [0 1]);

hold(eqAx, 'on');


% ---------------------------------------------------------------------
% Pseudorange equation
% rho_i = geometric range + clock bias
% ---------------------------------------------------------------------

text(eqAx, 0.02, 0.88, ...
    '$\rho_i = \sqrt{(x-x_i)^2+(y-y_i)^2+(z-z_i)^2}+c\delta t$', ...
    'Interpreter', 'latex', ...
    'FontSize', 16);


% ---------------------------------------------------------------------
% GPS position calculation
% ---------------------------------------------------------------------

text(eqAx, 0.02, 0.62, ...
    '$\hat{\mathbf{x}}=\arg\min_{\mathbf{x}}\sum_i\left(\rho_i-\|\mathbf{x}-\mathbf{s}_i\|\right)^2$', ...
    'Interpreter', 'latex', ...
    'FontSize', 15);


% ---------------------------------------------------------------------
% Signal propagation equation
% ---------------------------------------------------------------------

text(eqAx, 0.02, 0.37, ...
    '$\rho=c\Delta t$', ...
    'Interpreter', 'latex', ...
    'FontSize', 17);


% ---------------------------------------------------------------------
% Speed of light
% ---------------------------------------------------------------------

text(eqAx, 0.02, 0.13, ...
    '$c\approx299\,792.458\ {\rm km/s}$', ...
    'Interpreter', 'latex', ...
    'FontSize', 15);


%% =====================================================================
% SECTION 5: MATLAB FUNCTION EXPLANATION
%
% This panel explains the MATLAB functions used to implement the GPS
% equations and visualization.
%
% NOTE:
% The strings below deliberately avoid unescaped nested single quotes.
% This prevents the "Character vector is not terminated properly" error.
%======================================================================

functionPanel = uipanel(fig, ...
    'Title', 'MATLAB Functions Used', ...
    'FontSize', 13, ...
    'Position', [910 30 510 390]);


functionText = uitextarea(functionPanel, ...
    'Position', [15 15 480 350], ...
    'Editable', 'off', ...
    'FontSize', 11);


% Use a cell array of character vectors.
% No string contains an unmatched single quote.

functionText.Value = { ...
    'GPS simulation functions:'; ...
    ''; ...
    'sqrt()'; ...
    '  Calculates the geometric distance between satellite and user.'; ...
    ''; ...
    'norm()'; ...
    '  Calculates the Euclidean distance between two position vectors.'; ...
    ''; ...
    'plot3()'; ...
    '  Draws satellite and receiver trajectories in 3-D.'; ...
    ''; ...
    'line()'; ...
    '  Draws the pseudorange connection between a satellite and receiver.'; ...
    ''; ...
    'scatter3()'; ...
    '  Displays satellites and the GPS receiver.'; ...
    ''; ...
    'drawnow'; ...
    '  Forces MATLAB to update the GUI graphics immediately.'; ...
    ''; ...
    'pause()'; ...
    '  Can be used to control simulation timing.'; ...
    ''; ...
    'uifigure / uiaxes / uibutton'; ...
    '  Create the MATLAB graphical user interface.'; ...
    ''; ...
    'text with LaTeX Interpreter'; ...
    '  Renders mathematical GPS equations using LaTeX.'; ...
    ''; ...
    'H \ residual'; ...
    '  Solves the linearized least-squares GPS position correction.'; ...
    ''; ...
    'timer'; ...
    '  Calls the GPS simulation update function periodically.' ...
    };


%% =====================================================================
% SECTION 6: GPS SIMULATION PARAMETERS
% Define Earth, satellite and receiver parameters.
%======================================================================

% Number of simulated GPS satellites
N = 6;

% Mean Earth radius in km
earthRadius = 6371;

% Approximate GPS satellite orbital altitude in km
gpsAltitude = 20200;

% GPS orbit radius
orbitRadius = earthRadius + gpsAltitude;

% Speed of light in km/s
c = 299792.458;

% Simulation time
simulationTime = 0;

% Base simulation time step
dt = 0.05;


%% =====================================================================
% SECTION 7: SATELLITE CONSTELLATION
% Initialize satellite orbital inclinations and phases.
%======================================================================

% Satellite inclination angles
inclination = deg2rad([20 40 55 70 110 135]);

% Initial orbital phases
phase0 = linspace(0, 2*pi, N + 1);
phase0(end) = [];

% Artificially accelerated orbital rate.
% Real GPS orbital motion is much slower; this value is increased so
% that the motion is clearly visible during a GUI demonstration.
orbitalRate = 0.015;


%% =====================================================================
% SECTION 8: INITIAL USER POSITION
% Define the starting receiver position.
%======================================================================

userInitialPosition = [earthRadius 0 0];


%% =====================================================================
% SECTION 9: GRAPHICAL OBJECT INITIALIZATION
% Create Earth, satellite, receiver, trajectory and pseudorange objects.
%======================================================================

% Create a sphere representing Earth.
[xe, ye, ze] = sphere(40);

surf(ax, ...
    earthRadius * xe, ...
    earthRadius * ye, ...
    earthRadius * ze, ...
    'FaceAlpha', 0.25, ...
    'EdgeColor', 'none');


% Satellite graphical object
satellitePlot = scatter3(ax, ...
    zeros(N,1), ...
    zeros(N,1), ...
    zeros(N,1), ...
    100, ...
    'filled');


% Receiver graphical object
userPlot = scatter3(ax, ...
    userInitialPosition(1), ...
    userInitialPosition(2), ...
    userInitialPosition(3), ...
    120, ...
    'filled');


% Receiver trajectory
trajectoryPlot = plot3(ax, ...
    NaN, NaN, NaN, ...
    'LineWidth', 2);


% Pseudorange lines
rangeLines = gobjects(N,1);

for k = 1:N

    rangeLines(k) = line(ax, ...
        [0 0], ...
        [0 0], ...
        [0 0], ...
        'LineWidth', 1);

end


%% =====================================================================
% SECTION 10: AXIS LIMITS
% Set the 3-D visualization range so both Earth and GPS satellites
% remain visible.
%======================================================================

displayLimit = orbitRadius * 1.15;

xlim(ax, [-displayLimit displayLimit]);
ylim(ax, [-displayLimit displayLimit]);
zlim(ax, [-displayLimit displayLimit]);


%% =====================================================================
% SECTION 11: SIMULATION STATE
% Define variables used by the timer and callbacks.
%======================================================================

running = false;

userTrajectory = zeros(0, 3);

timerObject = [];


%% =====================================================================
% SECTION 12: START SIMULATION CALLBACK
% Start the MATLAB timer that drives the real-time simulation.
%======================================================================

function startSimulation(~, ~)

    % Do not create another timer if the simulation is already running.
    if running
        return;
    end

    running = true;

    % Create timer.
    timerObject = timer( ...
        'ExecutionMode', 'fixedSpacing', ...
        'Period', dt, ...
        'BusyMode', 'drop', ...
        'TimerFcn', @updateSimulation);

    start(timerObject);

end


%% =====================================================================
% SECTION 13: STOP SIMULATION CALLBACK
% Stop and delete the timer.
%======================================================================

function stopSimulation(~, ~)

    running = false;

    if ~isempty(timerObject)

        try

            if isvalid(timerObject)

                stop(timerObject);
                delete(timerObject);

            end

        catch
            % Ignore cleanup errors during application shutdown.
        end

    end

    timerObject = [];

end


%% =====================================================================
% SECTION 14: RESET SIMULATION CALLBACK
% Return the simulation to its initial state.
%======================================================================

function resetSimulation(~, ~)

    % Stop simulation first.
    stopSimulation([], []);

    % Reset simulation time.
    simulationTime = 0;

    % Clear trajectory history.
    userTrajectory = zeros(0, 3);

    % Reset receiver graphics.
    set(userPlot, ...
        'XData', userInitialPosition(1), ...
        'YData', userInitialPosition(2), ...
        'ZData', userInitialPosition(3));

    % Clear receiver trajectory.
    set(trajectoryPlot, ...
        'XData', NaN, ...
        'YData', NaN, ...
        'ZData', NaN);

    % Reset information labels.
    set(timeLabel, ...
        'Text', '0.0 s');

    set(errorLabel, ...
        'Text', '0.00 km');

    % Redraw GUI.
    drawnow;

end


%% =====================================================================
% SECTION 15: MAIN GPS SIMULATION LOOP
%
% This function is called periodically by the MATLAB timer.
%
% It performs:
%   1. Receiver movement
%   2. Satellite orbital movement
%   3. Pseudorange calculation
%   4. Position estimation
%   5. Error calculation
%   6. 3-D visualization update
%======================================================================

function updateSimulation(~, ~)

    % Make sure the GUI still exists.
    if ~isvalid(fig)
        return;
    end


    %% -----------------------------------------------------------------
    % 15.1 ADVANCE SIMULATION TIME
    % ------------------------------------------------------------------

    simulationTime = simulationTime + ...
        dt * speedSlider.Value;


    %% -----------------------------------------------------------------
    % 15.2 USER / RECEIVER MOTION
    %
    % The receiver follows a slowly changing trajectory over Earth.
    % This is a simplified educational model rather than a geographic
    % latitude/longitude navigation model.
    % ------------------------------------------------------------------

    thetaUser = 0.05 * simulationTime;

    userPosition = [ ...
        earthRadius * cos(thetaUser), ...
        earthRadius * sin(thetaUser), ...
        0.15 * earthRadius * sin(0.5 * thetaUser)];


    %% -----------------------------------------------------------------
    % 15.3 SATELLITE MOTION
    %
    % Calculate the instantaneous position of every satellite.
    % ------------------------------------------------------------------

    satellitePositions = zeros(N, 3);

    for k = 1:N

        theta = phase0(k) + ...
            orbitalRate * simulationTime;

        inc = inclination(k);

        % Simplified circular orbital coordinates.
        x = orbitRadius * cos(theta);

        y = orbitRadius * sin(theta) * cos(inc);

        z = orbitRadius * sin(theta) * sin(inc);

        satellitePositions(k,:) = [x y z];

    end


    %% -----------------------------------------------------------------
    % 15.4 PSEUDORANGE CALCULATION
    %
    % GPS pseudorange model:
    %
    % rho_i = geometric_range_i + c * clock_bias
    %
    % clockBias is represented in seconds.
    % ------------------------------------------------------------------

    clockBias = 0.002;       % Receiver clock bias in seconds

    pseudorange = zeros(N, 1);

    for k = 1:N

        % Geometric satellite-to-receiver distance.
        geometricRange = norm( ...
            satellitePositions(k,:) - userPosition);

        % Add receiver clock bias.
        pseudorange(k) = ...
            geometricRange + c * clockBias;

    end


    %% -----------------------------------------------------------------
    % 15.5 GPS POSITION ESTIMATION
    %
    % Estimate:
    %
    %       [x y z b]
    %
    % using iterative linearized least squares.
    % ------------------------------------------------------------------

    estimatedState = estimatePosition( ...
        satellitePositions, ...
        pseudorange);

    estimatedPosition = estimatedState(1:3);


    %% -----------------------------------------------------------------
    % 15.6 POSITION ERROR
    % ------------------------------------------------------------------

    positionError = norm( ...
        estimatedPosition - userPosition);


    %% -----------------------------------------------------------------
    % 15.7 UPDATE SATELLITE GRAPHICS
    % ------------------------------------------------------------------

    set(satellitePlot, ...
        'XData', satellitePositions(:,1), ...
        'YData', satellitePositions(:,2), ...
        'ZData', satellitePositions(:,3));


    %% -----------------------------------------------------------------
    % 15.8 UPDATE USER GRAPHICS
    % ------------------------------------------------------------------

    set(userPlot, ...
        'XData', userPosition(1), ...
        'YData', userPosition(2), ...
        'ZData', userPosition(3));


    %% -----------------------------------------------------------------
    % 15.9 UPDATE USER TRAJECTORY
    % ------------------------------------------------------------------

    userTrajectory(end+1,:) = userPosition;

    set(trajectoryPlot, ...
        'XData', userTrajectory(:,1), ...
        'YData', userTrajectory(:,2), ...
        'ZData', userTrajectory(:,3));


    %% -----------------------------------------------------------------
    % 15.10 UPDATE PSEUDORANGE LINES
    %
    % Each line represents the instantaneous measured GPS range between
    % one satellite and the receiver.
    % ------------------------------------------------------------------

    for k = 1:N

        set(rangeLines(k), ...
            'XData', [satellitePositions(k,1) userPosition(1)], ...
            'YData', [satellitePositions(k,2) userPosition(2)], ...
            'ZData', [satellitePositions(k,3) userPosition(3)]);

    end


    %% -----------------------------------------------------------------
    % 15.11 UPDATE GUI INFORMATION
    % ------------------------------------------------------------------

    set(timeLabel, ...
        'Text', sprintf('%.1f s', simulationTime));

    set(errorLabel, ...
        'Text', sprintf('%.3f km', positionError));


    %% -----------------------------------------------------------------
    % 15.12 FORCE GRAPHICS UPDATE
    % ------------------------------------------------------------------

    drawnow limitrate;

end


%% =====================================================================
% SECTION 16: GPS POSITION ESTIMATION
%
% Iterative least-squares solution for:
%
%       rho_i = ||r - s_i|| + b
%
% where:
%
%   r = receiver position [x y z]
%   s_i = satellite position
%   b = receiver clock bias expressed as distance
%
% Four unknown quantities require at least four satellites.
% Six satellites are used in this simulation.
%======================================================================

function state = estimatePosition(satPos, rho)

    numSatellites = size(satPos, 1);


    % Initial state estimate.
    % The initial receiver position is placed approximately on Earth.
    state = [ ...
        earthRadius; ...
        0; ...
        0; ...
        0];


    % Number of Gauss-Newton / linearized least-squares iterations.
    numberOfIterations = 8;


    for iteration = 1:numberOfIterations

        % Measurement sensitivity matrix.
        H = zeros(numSatellites, 4);

        % Pseudorange residual vector.
        residual = zeros(numSatellites, 1);


        for i = 1:numSatellites

            % Current receiver position estimate.
            receiver = state(1:3);

            % Current satellite position.
            satellite = satPos(i,:).';


            % Geometric distance.
            distance = norm(receiver - satellite);


            % Protect against division by zero.
            if distance < eps
                distance = eps;
            end


            % Predicted pseudorange.
            predictedRange = distance + state(4);


            % Difference between measured and predicted range.
            residual(i) = rho(i) - predictedRange;


            % Linearized geometry matrix.
            H(i,1:3) = ...
                ((receiver - satellite) / distance).';


            % Derivative with respect to clock bias.
            H(i,4) = 1;

        end


        % Least-squares correction.
        %
        % MATLAB's backslash operator solves:
        %
        %       H * delta = residual
        %
        % in the least-squares sense when H has more rows than columns.
        delta = H \ residual;


        % Update receiver position and clock bias.
        state = state + delta;

    end

end


%% =====================================================================
% SECTION 17: APPLICATION CLEANUP
%
% Ensure the timer is stopped when the GUI window is closed.
%======================================================================

fig.CloseRequestFcn = @closeApplication;


function closeApplication(~, ~)

    % Stop and delete the simulation timer.
    stopSimulation([], []);

    % Delete GUI.
    delete(fig);

end

end