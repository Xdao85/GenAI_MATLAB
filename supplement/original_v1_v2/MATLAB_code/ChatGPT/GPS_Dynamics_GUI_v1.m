function GPS_Dynamics_GUI1
% =========================================================================
% GPS_Dynamics_GUI
%
% Graphical User Interface for simulating GPS technology dynamics.
%
% MAIN FEATURES
%   1. Displays GPS mathematical equations using LaTeX.
%   2. Displays MATLAB functions used in the simulation.
%   3. Simulates moving GPS satellites and a moving receiver in 3-D.
%   4. Calculates pseudoranges and estimates receiver position.
%   5. Animates pseudorange lines in real time.
%
% MATLAB VERSION
%   Designed for MATLAB R2020b or newer.
%
% =========================================================================


%% ========================================================================
%  1. GUI DESIGN
% =========================================================================

% Create main GUI window
fig = uifigure( ...
    'Name', 'GPS Technology Dynamics Simulator', ...
    'Position', [50 50 1500 850], ...
    'Color', [0.96 0.97 0.98]);

% -------------------------------------------------------------------------
% Main title
% -------------------------------------------------------------------------
uilabel(fig, ...
    'Position', [30 805 1440 35], ...
    'Text', 'GPS Technology Dynamics Simulation', ...
    'FontSize', 24, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');

% -------------------------------------------------------------------------
% 3-D simulation axes
% -------------------------------------------------------------------------
ax = uiaxes(fig, ...
    'Position', [30 270 850 510]);

title(ax, 'GPS Satellite Constellation and User Position');
xlabel(ax, 'X (km)');
ylabel(ax, 'Y (km)');
zlabel(ax, 'Z (km)');

grid(ax, 'on');
axis(ax, 'equal');
view(ax, 3);

% -------------------------------------------------------------------------
% Equations panel
% -------------------------------------------------------------------------
eqPanel = uipanel(fig, ...
    'Title', 'GPS Mathematical Equations', ...
    'Position', [910 480 560 300], ...
    'FontSize', 14, ...
    'FontWeight', 'bold');

% -------------------------------------------------------------------------
% MATLAB functions panel
% -------------------------------------------------------------------------
funcPanel = uipanel(fig, ...
    'Title', 'Core MATLAB Functions', ...
    'Position', [910 270 560 200], ...
    'FontSize', 14, ...
    'FontWeight', 'bold');

% -------------------------------------------------------------------------
% Simulation control panel
% -------------------------------------------------------------------------
controlPanel = uipanel(fig, ...
    'Title', 'Simulation Control', ...
    'Position', [30 30 850 210], ...
    'FontSize', 14, ...
    'FontWeight', 'bold');


%% ========================================================================
%  2. LATEX EQUATION DISPLAY
% =========================================================================
%
% MATLAB uilabel does not provide full mathematical LaTeX rendering.
% Therefore, we use annotation objects with the Interpreter property
% set to 'latex'.
%
% The annotations are placed in normalized figure coordinates.
% =========================================================================

% Pseudorange equation
annotation(fig, 'textbox', ...
    [0.625 0.735 0.32 0.055], ...
    'String', ...
    '$$\rho_i =
    \sqrt{(x-x_i)^2+(y-y_i)^2+(z-z_i)^2}
    +c\,\delta t+b_i$$', ...
    'Interpreter', 'latex', ...
    'FontSize', 17, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');

% Position equation
annotation(fig, 'textbox', ...
    [0.625 0.625 0.32 0.055], ...
    'String', ...
    '$$\mathbf{r} =
    \begin{bmatrix}
    x\\y\\z
    \end{bmatrix}$$', ...
    'Interpreter', 'latex', ...
    'FontSize', 18, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');

% Least-squares concept
annotation(fig, 'textbox', ...
    [0.625 0.515 0.32 0.055], ...
    'String', ...
    '$$\hat{\mathbf{x}} =
    \arg\min_{\mathbf{x}}
    \left\|
    \boldsymbol{\rho}-h(\mathbf{x})
    \right\|^2$$', ...
    'Interpreter', 'latex', ...
    'FontSize', 17, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');


%% ========================================================================
%  3. CORE MATLAB FUNCTIONS
% =========================================================================

funcText = {
    'satellitePosition()'
    '    Generates dynamic satellite coordinates.'
    ''
    'calculatePseudorange()'
    '    Calculates GPS pseudorange from geometry.'
    ''
    'estimatePosition()'
    '    Estimates receiver position using least squares.'
    ''
    'plot3() / scatter3()'
    '    Visualizes satellites and receiver in 3-D.'
    ''
    'drawnow'
    '    Updates the GUI animation in real time.'
    ''
    'timer'
    '    Controls continuous simulation updates.'
    };

uilabel(funcPanel, ...
    'Position', [15 10 530 165], ...
    'Text', funcText, ...
    'FontName', 'Consolas', ...
    'FontSize', 11, ...
    'VerticalAlignment', 'top');


%% ========================================================================
%  4. SIMULATION PARAMETERS
% =========================================================================

% Simulation state
simulationRunning = false;

% Simulation time
t = 0;

% Time step
dt = 0.05;

% Number of GPS satellites
numSatellites = 6;

% Speed of light (km/s)
c = 299792.458;

% GPS orbital radius (simplified)
orbitalRadius = 26560;

% Receiver initial position (km)
receiverPosition = [-5000 -5000 1500];

% Receiver velocity (km/s)
receiverVelocity = [10 8 3];

% Receiver clock bias (km)
clockBias = 0.01;

% Generate initial satellite orbital parameters
satellitePhase = linspace(0, 2*pi, numSatellites + 1);
satellitePhase(end) = [];

satelliteInclination = ...
    deg2rad([55 55 55 55 55 55]);

satelliteOmega = ...
    deg2rad([0 60 120 180 240 300]);


%% ========================================================================
%  5. SIMULATION CONTROL GUI
% =========================================================================

% Start button
startButton = uibutton(controlPanel, ...
    'push', ...
    'Text', 'Start Simulation', ...
    'Position', [30 130 170 40], ...
    'FontSize', 13, ...
    'ButtonPushedFcn', @startSimulation);

% Stop button
stopButton = uibutton(controlPanel, ...
    'push', ...
    'Text', 'Stop Simulation', ...
    'Position', [220 130 170 40], ...
    'FontSize', 13, ...
    'ButtonPushedFcn', @stopSimulation);

% Reset button
resetButton = uibutton(controlPanel, ...
    'push', ...
    'Text', 'Reset', ...
    'Position', [410 130 120 40], ...
    'FontSize', 13, ...
    'ButtonPushedFcn', @resetSimulation);


%% ========================================================================
%  6. REAL-TIME INFORMATION DISPLAY
% =========================================================================

infoLabel = uilabel(controlPanel, ...
    'Position', [30 65 800 40], ...
    'Text', 'Simulation time: 0.00 s', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');

positionLabel = uilabel(controlPanel, ...
    'Position', [30 20 800 35], ...
    'Text', 'User position: [0 0 0] km', ...
    'FontSize', 12);


%% ========================================================================
%  7. INITIALIZE 3-D GRAPHICS
% =========================================================================

% Generate initial satellite positions
satPositions = satellitePosition( ...
    t, ...
    orbitalRadius, ...
    satellitePhase, ...
    satelliteInclination, ...
    satelliteOmega);

% Plot satellites
satellitePlot = scatter3(ax, ...
    satPositions(:,1), ...
    satPositions(:,2), ...
    satPositions(:,3), ...
    100, ...
    'filled');

% Plot receiver
receiverPlot = scatter3(ax, ...
    receiverPosition(1), ...
    receiverPosition(2), ...
    receiverPosition(3), ...
    150, ...
    'filled');

% Labels
text(ax, ...
    receiverPosition(1), ...
    receiverPosition(2), ...
    receiverPosition(3), ...
    '  USER', ...
    'FontWeight', 'bold');

% Satellite labels
for k = 1:numSatellites

    text(ax, ...
        satPositions(k,1), ...
        satPositions(k,2), ...
        satPositions(k,3), ...
        sprintf('  S%d', k), ...
        'FontSize', 9);

end

% Axis limits
axisLimit = 30000;

xlim(ax, [-axisLimit axisLimit]);
ylim(ax, [-axisLimit axisLimit]);
zlim(ax, [-axisLimit axisLimit]);


%% ========================================================================
%  8. PSEUDORANGE LINE GRAPHICS
% =========================================================================

% Create line objects connecting receiver to satellites
rangeLines = gobjects(numSatellites,1);

for k = 1:numSatellites

    rangeLines(k) = plot3(ax, ...
        [receiverPosition(1) satPositions(k,1)], ...
        [receiverPosition(2) satPositions(k,2)], ...
        [receiverPosition(3) satPositions(k,3)], ...
        '--');

end


%% ========================================================================
%  9. CREATE SIMULATION TIMER
% =========================================================================

simulationTimer = timer( ...
    'ExecutionMode', 'fixedRate', ...
    'Period', dt, ...
    'TimerFcn', @updateSimulation);


%% ========================================================================
%  10. START SIMULATION CALLBACK
% =========================================================================

function startSimulation(~, ~)

    if ~simulationRunning

        simulationRunning = true;

        start(simulationTimer);

    end

end


%% ========================================================================
%  11. STOP SIMULATION CALLBACK
% =========================================================================

function stopSimulation(~, ~)

    if simulationRunning

        simulationRunning = false;

        stop(simulationTimer);

    end

end


%% ========================================================================
%  12. RESET SIMULATION
% =========================================================================

function resetSimulation(~, ~)

    if simulationRunning

        stop(simulationTimer);

    end

    simulationRunning = false;

    t = 0;

    receiverPosition = [-5000 -5000 1500];

    updateGraphics();

end


%% ========================================================================
%  13. MAIN SIMULATION UPDATE
% =========================================================================

function updateSimulation(~, ~)

    % Advance simulation time
    t = t + dt;

    % -------------------------------------------------------------
    % Update user/receiver position
    % -------------------------------------------------------------

    receiverPosition = receiverPosition + ...
        receiverVelocity * dt;

    % -------------------------------------------------------------
    % Calculate satellite positions
    % -------------------------------------------------------------

    satPositions = satellitePosition( ...
        t, ...
        orbitalRadius, ...
        satellitePhase, ...
        satelliteInclination, ...
        satelliteOmega);

    % -------------------------------------------------------------
    % Calculate pseudoranges
    % -------------------------------------------------------------

    pseudoranges = calculatePseudorange( ...
        receiverPosition, ...
        satPositions, ...
        clockBias, ...
        c);

    % -------------------------------------------------------------
    % Estimate receiver position
    % -------------------------------------------------------------

    estimatedPosition = estimatePosition( ...
        satPositions, ...
        pseudoranges, ...
        c);

    % -------------------------------------------------------------
    % Update graphics
    % -------------------------------------------------------------

    satellitePlot.XData = satPositions(:,1);
    satellitePlot.YData = satPositions(:,2);
    satellitePlot.ZData = satPositions(:,3);

    receiverPlot.XData = receiverPosition(1);
    receiverPlot.YData = receiverPosition(2);
    receiverPlot.ZData = receiverPosition(3);

    % -------------------------------------------------------------
    % Update pseudorange lines
    % -------------------------------------------------------------

    for k = 1:numSatellites

        rangeLines(k).XData = ...
            [receiverPosition(1) satPositions(k,1)];

        rangeLines(k).YData = ...
            [receiverPosition(2) satPositions(k,2)];

        rangeLines(k).ZData = ...
            [receiverPosition(3) satPositions(k,3)];

    end

    % -------------------------------------------------------------
    % Update information panel
    % -------------------------------------------------------------

    infoLabel.Text = sprintf( ...
        'Simulation time: %.2f s     |     Satellites: %d', ...
        t, numSatellites);

    positionLabel.Text = sprintf( ...
        ['True position: [%.2f, %.2f, %.2f] km    |    ' ...
         'Estimated: [%.2f, %.2f, %.2f] km'], ...
        receiverPosition(1), ...
        receiverPosition(2), ...
        receiverPosition(3), ...
        estimatedPosition(1), ...
        estimatedPosition(2), ...
        estimatedPosition(3));

    % Force graphics update
    drawnow limitrate;

end


%% ========================================================================
%  14. UPDATE GRAPHICS AFTER RESET
% =========================================================================

function updateGraphics()

    satPositions = satellitePosition( ...
        t, ...
        orbitalRadius, ...
        satellitePhase, ...
        satelliteInclination, ...
        satelliteOmega);

    satellitePlot.XData = satPositions(:,1);
    satellitePlot.YData = satPositions(:,2);
    satellitePlot.ZData = satPositions(:,3);

    receiverPlot.XData = receiverPosition(1);
    receiverPlot.YData = receiverPosition(2);
    receiverPlot.ZData = receiverPosition(3);

    for k = 1:numSatellites

        rangeLines(k).XData = ...
            [receiverPosition(1) satPositions(k,1)];

        rangeLines(k).YData = ...
            [receiverPosition(2) satPositions(k,2)];

        rangeLines(k).ZData = ...
            [receiverPosition(3) satPositions(k,3)];

    end

    infoLabel.Text = ...
        'Simulation time: 0.00 s     |     Satellites: 6';

    positionLabel.Text = ...
        'True position: [-5000, -5000, 1500] km';

    drawnow;

end


%% ========================================================================
%  15. SATELLITE POSITION FUNCTION
% =========================================================================

function positions = satellitePosition( ...
    time, radius, phase, inclination, omega)

% Simplified circular GPS satellite model.
%
% Inputs:
%   time       - simulation time [s]
%   radius     - orbital radius [km]
%   phase      - initial satellite phase [rad]
%   inclination- orbital inclination [rad]
%   omega      - orbital orientation [rad]
%
% Output:
%   positions  - N x 3 satellite coordinates [km]

    % Simplified angular velocity
    orbitalAngularVelocity = 2*pi/(12*3600);

    positions = zeros(length(phase),3);

    for n = 1:length(phase)

        theta = phase(n) + ...
            orbitalAngularVelocity*time;

        % Position in orbital plane
        x = radius*cos(theta);

        y = radius*sin(theta);

        z = 0;

        % Inclination rotation
        yRot = y*cos(inclination(n)) ...
             - z*sin(inclination(n));

        zRot = y*sin(inclination(n)) ...
             + z*cos(inclination(n));

        xRot = x;

        % Longitude/orbital-plane rotation
        xFinal = ...
            xRot*cos(omega(n)) ...
            - yRot*sin(omega(n));

        yFinal = ...
            xRot*sin(omega(n)) ...
            + yRot*cos(omega(n));

        positions(n,:) = ...
            [xFinal yFinal zRot];

    end

end


%% ========================================================================
%  16. PSEUDORANGE CALCULATION
% =========================================================================

function rho = calculatePseudorange( ...
    receiver, satellites, clockBias, c)

% Calculates GPS pseudorange:
%
% rho_i = geometric_range + c*delta_t + b_i
%
% In this simplified simulation, satellite clock errors b_i are neglected.

    numSat = size(satellites,1);

    rho = zeros(numSat,1);

    for n = 1:numSat

        geometricRange = norm( ...
            satellites(n,:) - receiver);

        rho(n) = geometricRange + ...
            c*clockBias;

    end

end


%% ========================================================================
%  17. RECEIVER POSITION ESTIMATION
% =========================================================================

function position = estimatePosition( ...
    satellites, pseudoranges, c)

% Estimates receiver position using iterative least squares.
%
% Unknown vector:
%
%   x = [x y z clockBias]'
%
% Linearization is performed around an initial estimate.

    numSat = size(satellites,1);

    % Initial estimate
    x = [0; 0; 0; 0];

    % Iterative least squares
    for iteration = 1:8

        H = zeros(numSat,4);

        predicted = zeros(numSat,1);

        for n = 1:numSat

            dx = x(1) - satellites(n,1);
            dy = x(2) - satellites(n,2);
            dz = x(3) - satellites(n,3);

            range = sqrt( ...
                dx^2 + dy^2 + dz^2);

            predicted(n) = ...
                range + c*x(4);

            % Geometry matrix
            H(n,1) = dx/range;
            H(n,2) = dy/range;
            H(n,3) = dz/range;
            H(n,4) = c;

        end

        % Measurement residual
        residual = pseudoranges - predicted;

        % Least-squares correction
        delta = (H' * H) \ ...
                (H' * residual);

        x = x + delta;

    end

    position = x(1:3)';

end


%% ========================================================================
%  18. CLEAN UP TIMER WHEN GUI IS CLOSED
% =========================================================================

fig.CloseRequestFcn = @closeGUI;

function closeGUI(~,~)

    try

        if isvalid(simulationTimer)

            stop(simulationTimer);

            delete(simulationTimer);

        end

    catch

    end

    delete(fig);

end

end
