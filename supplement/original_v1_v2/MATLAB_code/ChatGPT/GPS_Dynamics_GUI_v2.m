function GPS_Dynamics_GUI_v2
% GPS_Dynamics_GUI
% Interactive GUI for GPS technology dynamics simulation.
%
% Features:
%   1. 3-D visualization of GPS satellites and receiver
%   2. Dynamic receiver motion
%   3. Pseudorange calculation
%   4. Receiver position estimation using least squares
%   5. Real-time pseudorange lines
%   6. Display of GPS equations and core MATLAB functions
%
% Save this file as:
%   GPS_Dynamics_GUI.m
%
% Run:
%   GPS_Dynamics_GUI

%% ========================================================================
% 1. GUI DESIGN
% ========================================================================

fig = uifigure( ...
    'Name', 'GPS Technology Dynamics Simulator', ...
    'Position', [50 50 1500 850], ...
    'Color', [0.96 0.97 0.98]);

% Main title
uilabel(fig, ...
    'Position', [30 805 1440 35], ...
    'Text', 'GPS Technology Dynamics Simulation', ...
    'FontSize', 24, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');

% 3-D simulation axes
ax = uiaxes(fig, ...
    'Position', [30 270 850 510]);

title(ax, 'GPS Satellite Constellation and User Position');
xlabel(ax, 'X (km)');
ylabel(ax, 'Y (km)');
zlabel(ax, 'Z (km)');

grid(ax, 'on');
axis(ax, 'equal');
view(ax, 3);

% Equations panel
eqPanel = uipanel(fig, ...
    'Title', 'GPS Mathematical Equations', ...
    'Position', [910 480 560 300], ...
    'FontSize', 14, ...
    'FontWeight', 'bold');

% MATLAB functions panel
funcPanel = uipanel(fig, ...
    'Title', 'Core MATLAB Functions', ...
    'Position', [910 270 560 200], ...
    'FontSize', 14, ...
    'FontWeight', 'bold');

% Simulation control panel
controlPanel = uipanel(fig, ...
    'Title', 'Simulation Control', ...
    'Position', [30 30 850 210], ...
    'FontSize', 14, ...
    'FontWeight', 'bold');


%% ========================================================================
% 2. GPS MATHEMATICAL EQUATIONS
% ========================================================================

uilabel(eqPanel, ...
    'Position', [20 205 520 55], ...
    'Text', ...
    '$$\rho_i = \sqrt{(x-x_i)^2+(y-y_i)^2+(z-z_i)^2}+c\delta t$$', ...
    'Interpreter', 'latex', ...
    'FontSize', 16, ...
    'HorizontalAlignment', 'center');

uilabel(eqPanel, ...
    'Position', [20 130 520 55], ...
    'Text', ...
    '$$\mathbf{r}=\begin{bmatrix}x\\y\\z\end{bmatrix}$$', ...
    'Interpreter', 'latex', ...
    'FontSize', 18, ...
    'HorizontalAlignment', 'center');

uilabel(eqPanel, ...
    'Position', [20 55 520 60], ...
    'Text', ...
    '$$\hat{\mathbf{x}}=\arg\min_{\mathbf{x}}\left\|\boldsymbol{\rho}-h(\mathbf{x})\right\|^2$$', ...
    'Interpreter', 'latex', ...
    'FontSize', 16, ...
    'HorizontalAlignment', 'center');


%% ========================================================================
% 3. CORE MATLAB FUNCTIONS
% ========================================================================

funcText = {
    'satellitePosition()'
    '    Generates dynamic satellite coordinates.'
    ''
    'calculatePseudorange()'
    '    Calculates GPS pseudorange.'
    ''
    'estimatePosition()'
    '    Estimates receiver position using'
    '    iterative least squares.'
    ''
    'scatter3() / plot3()'
    '    Creates 3-D visualization.'
    ''
    'drawnow'
    '    Updates graphics in real time.'
    ''
    'timer'
    '    Controls simulation updates.'
    };

uilabel(funcPanel, ...
    'Position', [15 10 530 165], ...
    'Text', funcText, ...
    'FontName', 'Consolas', ...
    'FontSize', 11, ...
    'VerticalAlignment', 'top');


%% ========================================================================
% 4. SIMULATION PARAMETERS
% ========================================================================

simulationRunning = false;

% Simulation time
t = 0;

% Time step
dt = 0.05;

% Number of satellites
numSatellites = 6;

% Speed of light [km/s]
c = 299792.458;

% GPS orbital radius [km]
orbitalRadius = 26560;

% Initial receiver position [km]
receiverPosition = [-5000 -5000 1500];

% Receiver velocity [km/s]
receiverVelocity = [10 8 3];

% Receiver clock bias [s]
clockBias = 0.000001;

% Satellite orbital phase
satellitePhase = linspace(0, 2*pi, numSatellites + 1);
satellitePhase(end) = [];

% Satellite inclination
satelliteInclination = deg2rad( ...
    [55 55 55 55 55 55]);

% Satellite orbital orientation
satelliteOmega = deg2rad( ...
    [0 60 120 180 240 300]);


%% ========================================================================
% 5. SIMULATION CONTROL
% ========================================================================

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
% 6. INFORMATION DISPLAY
% ========================================================================

infoLabel = uilabel(controlPanel, ...
    'Position', [30 65 800 40], ...
    'Text', 'Simulation time: 0.00 s | Satellites: 6', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');

positionLabel = uilabel(controlPanel, ...
    'Position', [30 20 800 35], ...
    'Text', 'True position: [-5000, -5000, 1500] km', ...
    'FontSize', 12);


%% ========================================================================
% 7. INITIAL SATELLITE POSITIONS
% ========================================================================

satPositions = satellitePosition( ...
    t, ...
    orbitalRadius, ...
    satellitePhase, ...
    satelliteInclination, ...
    satelliteOmega);


%% ========================================================================
% 8. INITIAL 3-D GRAPHICS
% ========================================================================

% Satellites
satellitePlot = scatter3(ax, ...
    satPositions(:,1), ...
    satPositions(:,2), ...
    satPositions(:,3), ...
    100, ...
    'filled');

% Receiver
receiverPlot = scatter3(ax, ...
    receiverPosition(1), ...
    receiverPosition(2), ...
    receiverPosition(3), ...
    150, ...
    'filled');

% Receiver label
userLabel = text(ax, ...
    receiverPosition(1), ...
    receiverPosition(2), ...
    receiverPosition(3), ...
    '  USER', ...
    'FontWeight', 'bold');

% Satellite labels
satelliteLabels = gobjects(numSatellites, 1);

for k = 1:numSatellites

    satelliteLabels(k) = text(ax, ...
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
% 9. PSEUDORANGE LINES
% ========================================================================

rangeLines = gobjects(numSatellites, 1);

for k = 1:numSatellites

    rangeLines(k) = plot3(ax, ...
        [receiverPosition(1) satPositions(k,1)], ...
        [receiverPosition(2) satPositions(k,2)], ...
        [receiverPosition(3) satPositions(k,3)], ...
        '--');

end


%% ========================================================================
% 10. SIMULATION TIMER
% ========================================================================

simulationTimer = timer( ...
    'ExecutionMode', 'fixedRate', ...
    'Period', dt, ...
    'TimerFcn', @updateSimulation);


%% ========================================================================
% 11. START SIMULATION
% ========================================================================

function startSimulation(~, ~)

    if ~simulationRunning

        simulationRunning = true;

        start(simulationTimer);

    end

end


%% ========================================================================
% 12. STOP SIMULATION
% ========================================================================

function stopSimulation(~, ~)

    if simulationRunning

        simulationRunning = false;

        stop(simulationTimer);

    end

end


%% ========================================================================
% 13. RESET SIMULATION
% ========================================================================

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
% 14. MAIN SIMULATION UPDATE
% ========================================================================

function updateSimulation(~, ~)

    % Advance simulation time
    t = t + dt;


    % ---------------------------------------------------------------------
    % Update receiver position
    % ---------------------------------------------------------------------

    receiverPosition = receiverPosition + ...
        receiverVelocity * dt;


    % ---------------------------------------------------------------------
    % Calculate satellite positions
    % ---------------------------------------------------------------------

    satPositions = satellitePosition( ...
        t, ...
        orbitalRadius, ...
        satellitePhase, ...
        satelliteInclination, ...
        satelliteOmega);


    % ---------------------------------------------------------------------
    % Calculate pseudoranges
    % ---------------------------------------------------------------------

    pseudoranges = calculatePseudorange( ...
        receiverPosition, ...
        satPositions, ...
        clockBias, ...
        c);


    % ---------------------------------------------------------------------
    % Estimate receiver position
    % ---------------------------------------------------------------------

    estimatedPosition = estimatePosition( ...
        satPositions, ...
        pseudoranges, ...
        c);


    % ---------------------------------------------------------------------
    % Update satellite graphics
    % ---------------------------------------------------------------------

    satellitePlot.XData = satPositions(:,1);
    satellitePlot.YData = satPositions(:,2);
    satellitePlot.ZData = satPositions(:,3);


    % ---------------------------------------------------------------------
    % Update receiver graphics
    % ---------------------------------------------------------------------

    receiverPlot.XData = receiverPosition(1);
    receiverPlot.YData = receiverPosition(2);
    receiverPlot.ZData = receiverPosition(3);

    userLabel.Position = receiverPosition;


    % ---------------------------------------------------------------------
    % Update satellite labels
    % ---------------------------------------------------------------------

    for k = 1:numSatellites

        satelliteLabels(k).Position = ...
            satPositions(k,:);

    end


    % ---------------------------------------------------------------------
    % Update pseudorange lines
    % ---------------------------------------------------------------------

    for k = 1:numSatellites

        rangeLines(k).XData = ...
            [receiverPosition(1) satPositions(k,1)];

        rangeLines(k).YData = ...
            [receiverPosition(2) satPositions(k,2)];

        rangeLines(k).ZData = ...
            [receiverPosition(3) satPositions(k,3)];

    end


    % ---------------------------------------------------------------------
    % Update information
    % ---------------------------------------------------------------------

    infoLabel.Text = sprintf( ...
        'Simulation time: %.2f s | Satellites: %d', ...
        t, ...
        numSatellites);


    positionLabel.Text = sprintf( ...
        ['True position: [%.2f, %.2f, %.2f] km | ' ...
         'Estimated: [%.2f, %.2f, %.2f] km'], ...
        receiverPosition(1), ...
        receiverPosition(2), ...
        receiverPosition(3), ...
        estimatedPosition(1), ...
        estimatedPosition(2), ...
        estimatedPosition(3));


    % Update graphics
    drawnow limitrate;

end


%% ========================================================================
% 15. UPDATE GRAPHICS AFTER RESET
% ========================================================================

function updateGraphics()

    satPositions = satellitePosition( ...
        t, ...
        orbitalRadius, ...
        satellitePhase, ...
        satelliteInclination, ...
        satelliteOmega);


    % Update satellites
    satellitePlot.XData = satPositions(:,1);
    satellitePlot.YData = satPositions(:,2);
    satellitePlot.ZData = satPositions(:,3);


    % Update receiver
    receiverPlot.XData = receiverPosition(1);
    receiverPlot.YData = receiverPosition(2);
    receiverPlot.ZData = receiverPosition(3);

    userLabel.Position = receiverPosition;


    % Update satellite labels
    for k = 1:numSatellites

        satelliteLabels(k).Position = ...
            satPositions(k,:);

    end


    % Update range lines
    for k = 1:numSatellites

        rangeLines(k).XData = ...
            [receiverPosition(1) satPositions(k,1)];

        rangeLines(k).YData = ...
            [receiverPosition(2) satPositions(k,2)];

        rangeLines(k).ZData = ...
            [receiverPosition(3) satPositions(k,3)];

    end


    % Update information
    infoLabel.Text = ...
        'Simulation time: 0.00 s | Satellites: 6';

    positionLabel.Text = ...
        'True position: [-5000, -5000, 1500] km';


    drawnow;

end


%% ========================================================================
% 16. SATELLITE POSITION FUNCTION
% ========================================================================

function positions = satellitePosition( ...
        time, radius, phase, inclination, omega)

    % Simplified circular GPS satellite model.
    %
    % Inputs:
    %   time        Simulation time [s]
    %   radius      Orbital radius [km]
    %   phase       Initial phase [rad]
    %   inclination Orbital inclination [rad]
    %   omega       Orbital orientation [rad]
    %
    % Output:
    %   positions   N x 3 satellite coordinates [km]


    % Simplified orbital angular velocity
    orbitalAngularVelocity = ...
        2*pi/(12*3600);


    % Number of satellites
    number = length(phase);


    % Allocate position matrix
    positions = zeros(number, 3);


    % Calculate each satellite position
    for n = 1:number

        theta = phase(n) + ...
            orbitalAngularVelocity * time;


        % Position in orbital plane
        x = radius * cos(theta);

        y = radius * sin(theta);

        z = 0;


        % Inclination rotation
        yRot = ...
            y*cos(inclination(n)) - ...
            z*sin(inclination(n));

        zRot = ...
            y*sin(inclination(n)) + ...
            z*cos(inclination(n));

        xRot = x;


        % Orbital-plane rotation
        xFinal = ...
            xRot*cos(omega(n)) - ...
            yRot*sin(omega(n));

        yFinal = ...
            xRot*sin(omega(n)) + ...
            yRot*cos(omega(n));


        % Store position
        positions(n,:) = ...
            [xFinal yFinal zRot];

    end

end


%% ========================================================================
% 17. PSEUDORANGE CALCULATION
% ========================================================================

function rho = calculatePseudorange( ...
        receiver, satellites, clockBias, c)

    % GPS pseudorange:
    %
    % rho_i = geometric_range + c * clockBias
    %
    % receiver  : 1 x 3 receiver position [km]
    % satellites: N x 3 satellite positions [km]
    % clockBias : receiver clock bias [s]
    % c         : speed of light [km/s]


    number = size(satellites, 1);


    % Allocate pseudorange vector
    rho = zeros(number, 1);


    % Calculate range to each satellite
    for n = 1:number

        geometricRange = norm( ...
            satellites(n,:) - receiver);


        rho(n) = ...
            geometricRange + c*clockBias;

    end

end


%% ========================================================================
% 18. RECEIVER POSITION ESTIMATION
% ========================================================================

function position = estimatePosition( ...
        satellites, pseudoranges, c)

    % Estimates receiver position using iterative
    % least-squares solution.
    %
    % Unknown vector:
    %
    % x = [x y z clockBias]'


    number = size(satellites, 1);


    % Initial estimate
    x = [0; 0; 0; 0];


    % Iterative least squares
    for iteration = 1:10

        H = zeros(number, 4);

        predicted = zeros(number, 1);


        % Calculate predicted measurements
        for n = 1:number

            dx = x(1) - satellites(n,1);

            dy = x(2) - satellites(n,2);

            dz = x(3) - satellites(n,3);


            range = sqrt( ...
                dx^2 + ...
                dy^2 + ...
                dz^2);


            % Predicted pseudorange
            predicted(n) = ...
                range + c*x(4);


            % Geometry matrix
            H(n,1) = dx/range;

            H(n,2) = dy/range;

            H(n,3) = dz/range;

            H(n,4) = c;

        end


        % Measurement residual
        residual = ...
            pseudoranges - predicted;


        % Least-squares correction
        delta = ...
            (H' * H) \ ...
            (H' * residual);


        % Update solution
        x = x + delta;


        % Stop if converged
        if norm(delta) < 1e-8

            break;

        end

    end


    % Return estimated position
    position = x(1:3)';

end


%% ========================================================================
% 19. CLOSE GUI
% ========================================================================

fig.CloseRequestFcn = @closeGUI;


function closeGUI(~, ~)

    try

        if isvalid(simulationTimer)

            stop(simulationTimer);

            delete(simulationTimer);

        end

    catch

        % Ignore timer cleanup errors

    end


    delete(fig);

end

end