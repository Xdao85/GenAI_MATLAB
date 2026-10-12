function GPS_Dynamics_GUI
%======================================================================
% GPS_Dynamics_GUI
%
% Graphical User Interface (GUI) for simulating GPS technology dynamics.
%
% FEATURES
%   1. Displays GPS equations using LaTeX rendering.
%   2. Explains MATLAB functions used in the GPS calculations.
%   3. Dynamically simulates:
%        - Satellite motion
%        - User motion
%        - GPS signal reception
%        - Pseudorange measurements
%        - GPS position estimation
%        - Pseudorange visualization
%   4. Displays the simulation in a 3-D coordinate system.
%   5. GUI controls allow the simulation to be started/stopped/reset.
%
% MATLAB VERSION
%   Designed for modern MATLAB versions supporting uifigure and UIAxes.
%======================================================================


%% =====================================================================
%  SECTION 1: GUI DESIGN
%  Create the main window, panels, axes, buttons and information fields.
%======================================================================

% Create the main application window
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


%% ---------------------------------------------------------------------
% 3-D visualization axes
% ----------------------------------------------------------------------

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


%% ---------------------------------------------------------------------
% Control panel
% ----------------------------------------------------------------------

controlPanel = uipanel(fig, ...
    'Title', 'Simulation Controls', ...
    'FontSize', 13, ...
    'Position', [30 30 850 240]);


% Start button
startButton = uibutton(controlPanel, ...
    'push', ...
    'Text', 'Start Simulation', ...
    'FontSize', 12, ...
    'Position', [30 170 180 40], ...
    'ButtonPushedFcn', @startSimulation);


% Stop button
stopButton = uibutton(controlPanel, ...
    'push', ...
    'Text', 'Stop Simulation', ...
    'FontSize', 12, ...
    'Position', [230 170 180 40], ...
    'ButtonPushedFcn', @stopSimulation);


% Reset button
resetButton = uibutton(controlPanel, ...
    'push', ...
    'Text', 'Reset', ...
    'FontSize', 12, ...
    'Position', [430 170 150 40], ...
    'ButtonPushedFcn', @resetSimulation);


% Simulation speed
uilabel(controlPanel, ...
    'Text', 'Simulation Speed:', ...
    'Position', [30 115 130 25]);

speedSlider = uislider(controlPanel, ...
    'Position', [170 125 350 3], ...
    'Limits', [0.1 2], ...
    'Value', 1);


% Simulation time
uilabel(controlPanel, ...
    'Text', 'Simulation Time:', ...
    'Position', [30 70 130 25]);

timeLabel = uilabel(controlPanel, ...
    'Text', '0.0 s', ...
    'FontWeight', 'bold', ...
    'Position', [170 70 150 25]);


% Position error
uilabel(controlPanel, ...
    'Text', 'Position Error:', ...
    'Position', [350 70 120 25]);

errorLabel = uilabel(controlPanel, ...
    'Text', '0.00 km', ...
    'FontWeight', 'bold', ...
    'Position', [470 70 150 25]);


%% =====================================================================
%  SECTION 2: GPS EQUATIONS WITH LATEX
%
%  MATLAB uilabel supports basic TeX/LaTeX interpretation. For more
%  flexible equation rendering, an axes object is used with text().
%======================================================================

equationPanel = uipanel(fig, ...
    'Title', 'GPS Equations', ...
    'FontSize', 13, ...
    'Position', [910 440 510 340]);


% Create an axes for displaying mathematical equations
eqAx = uiaxes(equationPanel, ...
    'Position', [10 10 490 300], ...
    'Visible', 'off');

axis(eqAx, [0 1 0 1]);
hold(eqAx, 'on');


% Pseudorange equation
text(eqAx, 0.02, 0.88, ...
    '$\rho_i = \sqrt{(x-x_i)^2+(y-y_i)^2+(z-z_i)^2}+c\delta t$', ...
    'Interpreter', 'latex', ...
    'FontSize', 16);


% GPS position equation
text(eqAx, 0.02, 0.60, ...
    '$\hat{\mathbf{x}} =
    \arg\min_{\mathbf{x}}\sum_i
    \left(\rho_i-\|\mathbf{x}-\mathbf{s}_i\|\right)^2$', ...
    'Interpreter', 'latex', ...
    'FontSize', 15);


% Signal propagation equation
text(eqAx, 0.02, 0.35, ...
    '$\rho = c\Delta t$', ...
    'Interpreter', 'latex', ...
    'FontSize', 17);


% Speed of light
text(eqAx, 0.02, 0.12, ...
    '$c \approx 299\,792.458\ {\rm km/s}$', ...
    'Interpreter', 'latex', ...
    'FontSize', 15);


%% =====================================================================
%  SECTION 3: MATLAB FUNCTION EXPLANATION
%  This panel explains important functions used in the simulation.
%======================================================================

functionPanel = uipanel(fig, ...
    'Title', 'MATLAB Functions Used', ...
    'FontSize', 13, ...
    'Position', [910 30 510 390]);


functionText = uitextarea(functionPanel, ...
    'Position', [15 15 480 350], ...
    'Editable', 'off', ...
    'FontSize', 11);

functionText.Value = {
    'GPS simulation functions:'
    ''
    '• sqrt()'
    '  Calculates geometric distance between satellite and user.'
    ''
    '• norm()'
    '  Calculates the Euclidean distance between two position vectors.'
    ''
    '• plot3()'
    '  Draws satellite/user trajectories in 3-D.'
    ''
    '• line()'
    '  Draws the pseudorange connection between a satellite and user.'
    ''
    '• scatter3()'
    '  Displays satellites and the GPS receiver.'
    ''
    '• drawnow'
    '  Forces MATLAB to immediately update the GUI graphics.'
    ''
    '• pause()'
    '  Controls simulation timing.'
    ''
    '• uifigure / uiaxes / uibutton'
    '  Create the MATLAB graphical user interface.'
    ''
    '• text(...,''Interpreter'',''latex'')'
    '  Renders GPS mathematical equations using LaTeX.'
    ''
    'Position estimation uses a linearized least-squares solution.'
    };


%% =====================================================================
%  SECTION 4: GPS SIMULATION PARAMETERS
%======================================================================

% Number of GPS satellites
N = 6;

% Earth radius in km
earthRadius = 6371;

% Approximate GPS orbital altitude in km
gpsAltitude = 20200;

% GPS orbit radius
orbitRadius = earthRadius + gpsAltitude;

% Speed of light in km/s
c = 299792.458;

% Simulation time
simulationTime = 0;

% Simulation time step
dt = 0.05;

% User trajectory radius
userTrajectoryRadius = 1500;

% User initial position
userInitialPosition = [earthRadius, 0, 0];


%% =====================================================================
%  SECTION 5: SATELLITE INITIALIZATION
%
%  Satellites are distributed around an artificial GPS constellation.
%  Their positions are updated continuously to create orbital motion.
%======================================================================

% Satellite inclination angles
inclination = deg2rad([20 40 55 70 110 135]);

% Initial orbital phases
phase0 = linspace(0, 2*pi, N+1);
phase0(end) = [];

% Orbital angular velocity.
% This value is intentionally accelerated so orbital motion is visible
% during the GUI demonstration.
orbitalRate = 0.015;


%% =====================================================================
%  SECTION 6: GRAPHICAL OBJECT INITIALIZATION
%======================================================================

% Create Earth sphere
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


% User graphical object
userPlot = scatter3(ax, ...
    userInitialPosition(1), ...
    userInitialPosition(2), ...
    userInitialPosition(3), ...
    120, ...
    'filled');


% User trajectory
trajectoryPlot = plot3(ax, ...
    NaN, NaN, NaN, ...
    'LineWidth', 2);


% Pseudorange lines
rangeLines = gobjects(N,1);

for k = 1:N

    rangeLines(k) = line(ax, ...
        [0 0], [0 0], [0 0], ...
        'LineWidth', 1);

end


%% =====================================================================
%  SECTION 7: SIMULATION STATE VARIABLES
%======================================================================

running = false;

userTrajectory = zeros(0,3);

timerObject = [];


%% =====================================================================
%  SECTION 8: START SIMULATION
%======================================================================

function startSimulation(~, ~)

    % Prevent creation of multiple timers
    if running
        return;
    end

    running = true;

    % Create MATLAB timer for real-time simulation
    timerObject = timer( ...
        'ExecutionMode', 'fixedSpacing', ...
        'Period', dt, ...
        'TimerFcn', @updateSimulation);

    start(timerObject);

end


%% =====================================================================
%  SECTION 9: STOP SIMULATION
%======================================================================

function stopSimulation(~, ~)

    running = false;

    if ~isempty(timerObject)

        if isvalid(timerObject)

            stop(timerObject);
            delete(timerObject);

        end

    end

    timerObject = [];

end


%% =====================================================================
%  SECTION 10: RESET SIMULATION
%======================================================================

function resetSimulation(~, ~)

    % Stop current simulation
    stopSimulation();

    % Reset time
    simulationTime = 0;

    % Clear user trajectory
    userTrajectory = zeros(0,3);

    % Reset graphics
    set(userPlot, ...
        'XData', userInitialPosition(1), ...
        'YData', userInitialPosition(2), ...
        'ZData', userInitialPosition(3));

    set(trajectoryPlot, ...
        'XData', NaN, ...
        'YData', NaN, ...
        'ZData', NaN);

    set(timeLabel, 'Text', '0.0 s');

    set(errorLabel, 'Text', '0.00 km');

end


%% =====================================================================
%  SECTION 11: MAIN GPS SIMULATION LOOP
%
%  This function is called repeatedly by the MATLAB timer.
%======================================================================

function updateSimulation(~, ~)

    % Advance simulation time
    simulationTime = simulationTime + ...
        dt * speedSlider.Value;


    %% ---------------------------------------------------------------
    % USER MOTION
    %
    % The receiver follows a circular trajectory around the Earth.
    % ---------------------------------------------------------------

    thetaUser = 0.05 * simulationTime;

    userPosition = [ ...
        earthRadius * cos(thetaUser), ...
        earthRadius * sin(thetaUser), ...
        0.15 * earthRadius * sin(0.5 * thetaUser)];


    %% ---------------------------------------------------------------
    % SATELLITE MOTION
    %
    % Calculate satellite positions using simple circular orbital
    % dynamics.
    % ---------------------------------------------------------------

    satellitePositions = zeros(N,3);

    for k = 1:N

        theta = phase0(k) + ...
            orbitalRate * simulationTime;

        inc = inclination(k);

        % Satellite orbital coordinates
        x = orbitRadius * cos(theta);

        y = orbitRadius * sin(theta) * cos(inc);

        z = orbitRadius * sin(theta) * sin(inc);

        satellitePositions(k,:) = [x y z];

    end


    %% ---------------------------------------------------------------
    % PSEUDORANGE CALCULATION
    %
    % rho_i = geometric range + receiver clock bias
    %
    % A small clock bias is introduced to demonstrate the concept.
    % ---------------------------------------------------------------

    clockBias = 0.002;     % seconds

    pseudorange = zeros(N,1);

    for k = 1:N

        % Geometric distance
        geometricRange = norm( ...
            satellitePositions(k,:) - userPosition);

        % Pseudorange measurement
        pseudorange(k) = ...
            geometricRange + c * clockBias;

    end


    %% ---------------------------------------------------------------
    % GPS POSITION ESTIMATION
    %
    % Estimate receiver position from pseudorange measurements.
    %
    % Unknown state:
    %
    %     [x y z b]
    %
    % where b is the receiver clock error expressed in distance units.
    % ---------------------------------------------------------------

    estimatedState = estimatePosition( ...
        satellitePositions, ...
        pseudorange);


    estimatedPosition = estimatedState(1:3);


    %% ---------------------------------------------------------------
    % POSITION ERROR
    % ---------------------------------------------------------------

    positionError = norm( ...
        estimatedPosition - userPosition);


    %% ---------------------------------------------------------------
    % UPDATE 3-D SATELLITE GRAPHICS
    % ---------------------------------------------------------------

    set(satellitePlot, ...
        'XData', satellitePositions(:,1), ...
        'YData', satellitePositions(:,2), ...
        'ZData', satellitePositions(:,3));


    %% ---------------------------------------------------------------
    % UPDATE USER POSITION
    % ---------------------------------------------------------------

    set(userPlot, ...
        'XData', userPosition(1), ...
        'YData', userPosition(2), ...
        'ZData', userPosition(3));


    %% ---------------------------------------------------------------
    % UPDATE USER TRAJECTORY
    % ---------------------------------------------------------------

    userTrajectory(end+1,:) = userPosition;

    set(trajectoryPlot, ...
        'XData', userTrajectory(:,1), ...
        'YData', userTrajectory(:,2), ...
        'ZData', userTrajectory(:,3));


    %% ---------------------------------------------------------------
    % UPDATE PSEUDORANGE LINES
    %
    % Each satellite is connected to the receiver by a line
    % representing the measured GPS signal range.
    % ---------------------------------------------------------------

    for k = 1:N

        set(rangeLines(k), ...
            'XData', [satellitePositions(k,1) userPosition(1)], ...
            'YData', [satellitePositions(k,2) userPosition(2)], ...
            'ZData', [satellitePositions(k,3) userPosition(3)]);

    end


    %% ---------------------------------------------------------------
    % UPDATE GUI INFORMATION
    % ---------------------------------------------------------------

    set(timeLabel, ...
        'Text', sprintf('%.1f s', simulationTime));

    set(errorLabel, ...
        'Text', sprintf('%.3f km', positionError));


    %% ---------------------------------------------------------------
    % FORCE GRAPHICS UPDATE
    % ---------------------------------------------------------------

    drawnow limitrate;

end


%% =====================================================================
%  SECTION 12: GPS POSITION ESTIMATION FUNCTION
%
%  Estimate [x,y,z,b] from pseudorange measurements using iterative
%  least squares.
%
%  The measurement model is:
%
%  rho_i = ||r - s_i|| + b
%
%  where:
%       r = receiver position
%       s_i = satellite position
%       b = clock bias in km
%======================================================================

function state = estimatePosition(satPos, rho)

    numSatellites = size(satPos,1);

    % Initial state estimate
    state = [ ...
        earthRadius; ...
        0; ...
        0; ...
        0];


    % Iterative least-squares solution
    for iteration = 1:8

        H = zeros(numSatellites,4);
        residual = zeros(numSatellites,1);

        for i = 1:numSatellites

            % Receiver estimate
            receiver = state(1:3);

            % Satellite position
            satellite = satPos(i,:).';

            % Geometric distance
            distance = norm(receiver - satellite);

            % Predicted pseudorange
            predictedRange = distance + state(4);

            % Measurement residual
            residual(i) = rho(i) - predictedRange;

            % Linearized measurement matrix
            H(i,1:3) = ...
                ((receiver - satellite) / distance).';

            H(i,4) = 1;

        end

        % Least-squares correction
        delta = H \ residual;

        % Update state
        state = state + delta;

    end

end


%% =====================================================================
%  SECTION 13: CLEANUP WHEN GUI IS CLOSED
%
%  Delete the MATLAB timer when the application window is closed.
%======================================================================

fig.CloseRequestFcn = @closeApplication;


function closeApplication(~, ~)

    % Stop timer if it exists
    stopSimulation();

    % Delete GUI
    delete(fig);

end

end