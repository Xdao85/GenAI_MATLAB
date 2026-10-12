function GPS_Dynamics_GUI
% GPS_Dynamics_GUI
% -------------------------------------------------------------------------
% Interactive GUI for simulating GPS technology dynamics.
%
% Sections:
%   1. GUI DESIGN
%   2. LATEX EQUATION INTEGRATION
%   3. MATLAB FUNCTION EXPLANATIONS
%   4. GPS SIMULATION LOGIC
%   5. 3-D VISUALIZATION AND ANIMATION
%
% The simulation demonstrates:
%   - Satellite motion
%   - User movement
%   - GPS pseudorange generation
%   - Position estimation using nonlinear least squares
%   - Real-time pseudorange visualization
%
% MATLAB version: R2020b or newer recommended.
% -------------------------------------------------------------------------

%% ========================================================================
% 1. GUI DESIGN
% ========================================================================

% Create the main application window
fig = uifigure( ...
    'Name','GPS Dynamics Simulator', ...
    'Position',[50 50 1500 850], ...
    'Color',[0.94 0.94 0.94]);

% Main title
uilabel(fig, ...
    'Text','GPS Technology Dynamics Simulation', ...
    'FontSize',24, ...
    'FontWeight','bold', ...
    'HorizontalAlignment','center', ...
    'Position',[400 805 700 35]);

% -------------------------------------------------------------------------
% 3-D visualization axes
% -------------------------------------------------------------------------

ax = uiaxes(fig, ...
    'Position',[30 300 900 480]);

title(ax,'GPS Satellite / User Dynamics');
xlabel(ax,'X Position (km)');
ylabel(ax,'Y Position (km)');
zlabel(ax,'Z Position (km)');
grid(ax,'on');
view(ax,3);

% -------------------------------------------------------------------------
% Equation panel
% -------------------------------------------------------------------------

eqPanel = uipanel(fig, ...
    'Title','GPS Equations', ...
    'FontWeight','bold', ...
    'Position',[950 470 520 310]);

% MATLAB text objects with LaTeX rendering
uilabel(eqPanel, ...
    'Text','Pseudorange equation', ...
    'FontWeight','bold', ...
    'Position',[20 250 200 25]);

eq1 = uilabel(eqPanel, ...
    'Text','$\rho_i = \sqrt{(x-x_i)^2+(y-y_i)^2+(z-z_i)^2}+c\Delta t$');

eq1.Interpreter = 'latex';
eq1.FontSize = 17;
eq1.Position = [20 205 470 40];

uilabel(eqPanel, ...
    'Text','Position calculation', ...
    'FontWeight','bold', ...
    'Position',[20 160 200 25]);

eq2 = uilabel(eqPanel, ...
    'Text','$\hat{\mathbf{x}} =
[\hat{x},\hat{y},\hat{z},\widehat{\Delta t}]^T$');

eq2.Interpreter = 'latex';
eq2.FontSize = 17;
eq2.Position = [20 115 470 40];

uilabel(eqPanel, ...
    'Text','Least-squares objective', ...
    'FontWeight','bold', ...
    'Position',[20 70 250 25]);

eq3 = uilabel(eqPanel, ...
    'Text','$\min_{\mathbf{x}}\sum_i
(\rho_i-\hat{\rho}_i)^2$');

eq3.Interpreter = 'latex';
eq3.FontSize = 17;
eq3.Position = [20 25 470 40];

% -------------------------------------------------------------------------
% Function explanation panel
% -------------------------------------------------------------------------

functionPanel = uipanel(fig, ...
    'Title','MATLAB Functions Used', ...
    'FontWeight','bold', ...
    'Position',[950 30 520 420]);

functionText = uitextarea(functionPanel, ...
    'Position',[15 15 490 375], ...
    'Editable','off', ...
    'FontName','Consolas', ...
    'FontSize',12);

functionText.Value = {
    '1. uifigure / uiaxes'
    '   Creates the GUI window and 3-D plotting area.'
    ''
    '2. plot3 / scatter3'
    '   Displays satellite and user positions in 3-D.'
    ''
    '3. line'
    '   Draws the instantaneous pseudorange geometry.'
    ''
    '4. timer'
    '   Updates the GPS simulation continuously.'
    ''
    '5. sqrt / sum'
    '   Calculates geometric ranges and residuals.'
    ''
    '6. fminsearch'
    '   Estimates receiver position and clock bias.'
    ''
    '7. drawnow'
    '   Forces the GUI graphics to update in real time.'
    ''
    '8. LaTeX interpreter'
    '   Renders GPS equations using mathematical notation.'
    ''
    'GPS state vector:'
    'x = [X Y Z clock_bias]'
    ''
    'The receiver estimates four unknowns:'
    'X, Y, Z and receiver clock bias.'
    };

% -------------------------------------------------------------------------
% Simulation controls
% -------------------------------------------------------------------------

controlPanel = uipanel(fig, ...
    'Title','Simulation Controls', ...
    'FontWeight','bold', ...
    'Position',[30 30 900 240]);

% Start button
startButton = uibutton(controlPanel, ...
    'Text','Start Simulation', ...
    'FontWeight','bold', ...
    'Position',[30 175 150 40], ...
    'ButtonPushedFcn',@startSimulation);

% Stop button
stopButton = uibutton(controlPanel, ...
    'Text','Stop Simulation', ...
    'Position',[200 175 150 40], ...
    'ButtonPushedFcn',@stopSimulation);

% Reset button
resetButton = uibutton(controlPanel, ...
    'Text','Reset', ...
    'Position',[370 175 120 40], ...
    'ButtonPushedFcn',@resetSimulation);

% Speed control
uilabel(controlPanel, ...
    'Text','Simulation speed:', ...
    'Position',[30 125 150 25]);

speedSlider = uislider(controlPanel, ...
    'Position',[170 137 300 3], ...
    'Limits',[0.1 5], ...
    'Value',1);

% Noise control
uilabel(controlPanel, ...
    'Text','Measurement noise (km):', ...
    'Position',[30 80 160 25]);

noiseSlider = uislider(controlPanel, ...
    'Position',[190 92 280 3], ...
    'Limits',[0 1], ...
    'Value',0.05);

% Status display
statusLabel = uilabel(controlPanel, ...
    'Text','Status: Ready', ...
    'FontWeight','bold', ...
    'Position',[520 175 300 35]);

positionLabel = uilabel(controlPanel, ...
    'Text','Estimated Position: ---', ...
    'Position',[520 120 350 30]);

errorLabel = uilabel(controlPanel, ...
    'Text','Position Error: ---', ...
    'Position',[520 80 350 30]);

timeLabel = uilabel(controlPanel, ...
    'Text','Simulation Time: 0 s', ...
    'Position',[520 40 350 30]);


%% ========================================================================
% 2. SIMULATION INITIALIZATION
% ========================================================================

% Number of satellites.
% At least four satellites are required for a full 3-D GPS solution.
numSat = 6;

% Approximate Earth radius in km.
earthRadius = 6371;

% Satellite orbital radius.
% GPS satellites orbit approximately 20,200 km above Earth's surface.
satRadius = earthRadius + 20200;

% Create six satellites distributed around the Earth.
satAngles = linspace(0,2*pi,numSat+1);
satAngles(end) = [];

% Inclination angles for the satellites.
satInclination = deg2rad([55 55 55 -55 -55 -55]);

% Initial satellite positions.
satPos = zeros(numSat,3);

for k = 1:numSat

    % Satellite orbital angle
    theta = satAngles(k);

    % Satellite Cartesian coordinates
    satPos(k,1) = satRadius*cos(theta);
    satPos(k,2) = satRadius*sin(theta)*cos(satInclination(k));
    satPos(k,3) = satRadius*sin(theta)*sin(satInclination(k));

end

% Initial user position.
userPos = [earthRadius+2, 0, 0];

% Estimated receiver position.
estimatedPos = userPos;

% Receiver clock bias in km.
clockBias = 0.08;

% Simulation time.
simulationTime = 0;

% Simulation state.
running = false;

% Timer object.
simTimer = timer( ...
    'ExecutionMode','fixedSpacing', ...
    'Period',0.05, ...
    'TimerFcn',@updateSimulation);


%% ========================================================================
% 3. INITIAL 3-D VISUALIZATION
% ========================================================================

% Draw Earth.
hold(ax,'on');

[xe,ye,ze] = sphere(40);

earthSurface = surf(ax, ...
    earthRadius*xe, ...
    earthRadius*ye, ...
    earthRadius*ze);

earthSurface.FaceAlpha = 0.25;
earthSurface.EdgeColor = 'none';

% Satellite markers.
satellitePlot = scatter3(ax, ...
    satPos(:,1), ...
    satPos(:,2), ...
    satPos(:,3), ...
    100,'filled');

% User marker.
userPlot = scatter3(ax, ...
    userPos(1), ...
    userPos(2), ...
    userPos(3), ...
    150,'filled');

% Estimated position marker.
estimatePlot = scatter3(ax, ...
    estimatedPos(1), ...
    estimatedPos(2), ...
    estimatedPos(3), ...
    150,'d','filled');

% Create pseudorange lines.
rangeLines = gobjects(numSat,1);

for k = 1:numSat

    rangeLines(k) = plot3(ax, ...
        [satPos(k,1) userPos(1)], ...
        [satPos(k,2) userPos(2)], ...
        [satPos(k,3) userPos(3)], ...
        '--');

end

% Keep axes scaling fixed.
axis(ax,'equal');

xlim(ax,[-30000 30000]);
ylim(ax,[-30000 30000]);
zlim(ax,[-30000 30000]);

legend(ax, ...
    {'Earth','Satellites','True User','Estimated User'}, ...
    'Location','northeast');

hold(ax,'off');


%% ========================================================================
% 4. SIMULATION CALLBACK FUNCTIONS
% ========================================================================

    function startSimulation(~,~)
        % Start the real-time GPS simulation.

        if ~running

            running = true;

            statusLabel.Text = 'Status: Simulation running...';

            start(simTimer);

        end

    end


    function stopSimulation(~,~)
        % Stop the real-time GPS simulation.

        running = false;

        statusLabel.Text = 'Status: Simulation stopped';

        if isvalid(simTimer)

            stop(simTimer);

        end

    end


    function resetSimulation(~,~)
        % Reset simulation time and receiver position.

        if isvalid(simTimer)
            stop(simTimer);
        end

        running = false;

        simulationTime = 0;

        userPos = [earthRadius+2, 0, 0];

        estimatedPos = userPos;

        statusLabel.Text = 'Status: Ready';

        positionLabel.Text = 'Estimated Position: ---';

        errorLabel.Text = 'Position Error: ---';

        timeLabel.Text = 'Simulation Time: 0 s';

        updatePlots();

    end


%% ========================================================================
% 5. GPS SIMULATION LOGIC
% ========================================================================

    function updateSimulation(~,~)
        % This function executes at every timer step.
        %
        % It:
        %   1. Advances simulation time.
        %   2. Moves satellites.
        %   3. Moves the receiver.
        %   4. Calculates pseudoranges.
        %   5. Estimates receiver position.
        %   6. Updates the visualization.

        if ~running
            return;
        end

        % Simulation timestep.
        dt = 0.05 * speedSlider.Value;

        simulationTime = simulationTime + dt;

        % -------------------------------------------------------------
        % User movement
        % -------------------------------------------------------------

        % Angular motion around Earth.
        userAngle = 0.00004 * simulationTime;

        userAltitude = earthRadius + 2;

        userPos = [ ...
            userAltitude*cos(userAngle), ...
            userAltitude*sin(userAngle), ...
            0.1*sin(0.5*userAngle)];


        % -------------------------------------------------------------
        % Satellite motion
        % -------------------------------------------------------------

        orbitalRate = 0.00008;

        for k = 1:numSat

            theta = satAngles(k) + orbitalRate*simulationTime;

            satPos(k,1) = satRadius*cos(theta);

            satPos(k,2) = satRadius*sin(theta) ...
                *cos(satInclination(k));

            satPos(k,3) = satRadius*sin(theta) ...
                *sin(satInclination(k));

        end


        % -------------------------------------------------------------
        % Pseudorange generation
        % -------------------------------------------------------------

        pseudoranges = zeros(numSat,1);

        for k = 1:numSat

            % True geometric distance.
            geometricRange = norm(satPos(k,:) - userPos);

            % Add receiver clock bias.
            pseudoranges(k) = geometricRange + clockBias;

            % Add measurement noise.
            noise = noiseSlider.Value * randn;

            pseudoranges(k) = pseudoranges(k) + noise;

        end


        % -------------------------------------------------------------
        % Receiver position estimation
        % -------------------------------------------------------------

        estimatedPos = estimatePosition( ...
            satPos, ...
            pseudoranges, ...
            estimatedPos, ...
            clockBias);


        % -------------------------------------------------------------
        % Update graphical objects
        % -------------------------------------------------------------

        updatePlots();


        % -------------------------------------------------------------
        % Calculate position error
        % -------------------------------------------------------------

        positionError = norm(estimatedPos - userPos);

        positionLabel.Text = sprintf( ...
            'Estimated Position: [%.1f, %.1f, %.1f] km', ...
            estimatedPos(1), ...
            estimatedPos(2), ...
            estimatedPos(3));

        errorLabel.Text = sprintf( ...
            'Position Error: %.3f km', ...
            positionError);

        timeLabel.Text = sprintf( ...
            'Simulation Time: %.2f s', ...
            simulationTime);

        drawnow limitrate;

    end


%% ========================================================================
% 6. GPS POSITION ESTIMATION FUNCTION
% ========================================================================

    function estimated = estimatePosition( ...
            satellites, ranges, initialGuess, initialClock)

        % Estimate:
        %
        %   X receiver position
        %   Y receiver position
        %   Z receiver position
        %   clock bias
        %
        % using nonlinear least squares.

        initialState = [ ...
            initialGuess(:); ...
            initialClock];

        % Objective function.
        objective = @(state) ...
            sum( ...
            ( ...
            ranges - ...
            sqrt(sum( ...
            (satellites - state(1:3)').^2,2)) ...
            - state(4) ...
            ).^2);

        % fminsearch performs unconstrained nonlinear optimization.
        solution = fminsearch(objective,initialState);

        estimated = solution(1:3)';

    end


%% ========================================================================
% 7. VISUALIZATION UPDATE
% ========================================================================

    function updatePlots()
        % Update satellite, user, estimated position, and pseudorange
        % visualization.

        satellitePlot.XData = satPos(:,1);
        satellitePlot.YData = satPos(:,2);
        satellitePlot.ZData = satPos(:,3);

        userPlot.XData = userPos(1);
        userPlot.YData = userPos(2);
        userPlot.ZData = userPos(3);

        estimatePlot.XData = estimatedPos(1);
        estimatePlot.YData = estimatedPos(2);
        estimatePlot.ZData = estimatedPos(3);

        % Update pseudorange lines.
        for k = 1:numSat

            rangeLines(k).XData = ...
                [satPos(k,1), userPos(1)];

            rangeLines(k).YData = ...
                [satPos(k,2), userPos(2)];

            rangeLines(k).ZData = ...
                [satPos(k,3), userPos(3)];

        end

        drawnow limitrate;

    end


%% ========================================================================
% 8. CLEANUP
% ========================================================================

% If the user closes the GUI, stop and delete the timer.
fig.CloseRequestFcn = @closeGUI;

    function closeGUI(~,~)

        if isvalid(simTimer)

            stop(simTimer);
            delete(simTimer);

        end

        delete(fig);

    end

end