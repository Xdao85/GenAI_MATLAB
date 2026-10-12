function GPS_Simulation
% =========================================================================
% GPS_Simulation.m
% -------------------------------------------------------------------------
% A MATLAB GUI for simulating GPS technology dynamics.
%
% Features:
%   (1) Displays GPS-related equations using LaTeX rendering inside the GUI
%   (2) Shows and explains MATLAB functions used to implement the equations
%   (3) Animates satellite motion, user movement, pseudorange lines and
%       updates the user's position estimate in real time (3D view)
%   (4) Every section is thoroughly commented
%
% Author: (your name) - Educational Example
% =========================================================================

%% ------------------------------------------------------------------------
%  SECTION 1: GUI DESIGN (main figure, panels, axes, controls)
%  ------------------------------------------------------------------------
%  We build the GUI programmatically using uifigure/uipanel/uiaxes etc.
%  so that LaTeX (via 'interpreter','latex') and 3D plotting both work.
%  ------------------------------------------------------------------------

% Close any previous instance
close all;

% Main figure (uifigure is preferred for modern components & LaTeX)
fig = uifigure('Name','GPS Technology Dynamics Simulation', ...
               'Position',[80 60 1200 720]);

% Use a grid layout to organize the whole window
mainGrid = uigridlayout(fig,[1 2]);
mainGrid.ColumnWidth = {'2x','1x'};   % left = 3D plot, right = text
mainGrid.RowHeight   = {'1x'};

% ----- Left panel: 3D animation axes --------------------------------
leftPanel = uipanel(mainGrid,'Title','3D GPS Scene','FontWeight','bold');
leftGrid  = uigridlayout(leftPanel,[2 1]);
leftGrid.RowHeight = {'1x', 90};

ax = uiaxes(leftGrid);                        % 3D axes for animation
ax.Box = 'on'; grid(ax,'on');
xlabel(ax,'X (m)'); ylabel(ax,'Y (m)'); zlabel(ax,'Z (m)');
title(ax,'GPS Satellites, User, and Pseudorange Lines');
view(ax,35,25);                               % 3D view angle
axis(ax,'equal');
xlim(ax,[-3e7 3e7]); ylim(ax,[-3e7 3e7]); zlim(ax,[-3e7 3e7]);

% ----- Controls (Start / Stop / Reset) -------------------------------
ctrlGrid = uigridlayout(leftGrid,[1 4]);
ctrlGrid.ColumnWidth = {'1x','1x','1x','2x'};

btnStart = uibutton(ctrlGrid,'Text','Start', ...
    'ButtonPushedFcn',@(~,~) startSim());
btnStop  = uibutton(ctrlGrid,'Text','Stop', ...
    'ButtonPushedFcn',@(~,~) stopSim());
btnReset = uibutton(ctrlGrid,'Text','Reset', ...
    'ButtonPushedFcn',@(~,~) resetSim());
lblStatus = uilabel(ctrlGrid,'Text','Status: Idle', ...
    'FontWeight','bold','HorizontalAlignment','center');

% ----- Right panel: equations + function explanations ----------------
rightPanel = uipanel(mainGrid,'Title','GPS Equations & MATLAB Functions', ...
                     'FontWeight','bold');
rightGrid  = uigridlayout(rightPanel,[2 1]);
rightGrid.RowHeight = {'1x','1x'};

% LaTeX equation display (using a uihtml-free trick: text area with
% 'Interpreter','latex' works only in axes/labels, so we use a uiaxes
% dedicated to LaTeX rendering).
axEq = uiaxes(rightGrid);
axEq.XTick=[]; axEq.YTick=[]; axEq.Box='on';
axEq.Color = [1 1 1];
title(axEq,'GPS Equations (LaTeX)');
axis(axEq,[0 1 0 1]);

% LaTeX strings to render inside the equation axes
eqStr1 = '$\rho_i = \| \mathbf{r}_{sat,i} - \mathbf{r}_{u} \| + c\,\delta t_u + \varepsilon_i$';
eqStr2 = '$\mathbf{r}_u = (A^{T}A)^{-1}A^{T}\,(\rho - c\,\delta t_u\mathbf{1})$';
eqStr3 = '$\hat{\mathbf{x}} = \arg\min_{\mathbf{x}} \sum_{i=1}^{N} (\rho_i - \|\mathbf{r}_{sat,i}-\mathbf{r}_u\| - c\,\delta t_u)^2$';

% Draw LaTeX equations as text objects inside axEq
text(axEq,0.5,0.85,eqStr1,'Interpreter','latex','FontSize',16, ...
     'HorizontalAlignment','center');
text(axEq,0.5,0.55,eqStr2,'Interpreter','latex','FontSize',16, ...
     'HorizontalAlignment','center');
text(axEq,0.5,0.25,eqStr3,'Interpreter','latex','FontSize',14, ...
     'HorizontalAlignment','center');

% Function-explanation text area
txtExplain = uitextarea(rightGrid,'Editable','off','FontName','Consolas', ...
    'Value', {
    'MATLAB functions used to implement the equations:'
    ''
    '1) Pseudorange:  rho = sqrt(sum((sat - user).^2,2)) + c*dt + noise'
    '   -> MATLAB:  vecnorm(), sum(), sqrt()'
    ''
    '2) Least-squares position solution:  r = (A''*A)\(A''*b)'
    '   -> MATLAB:  mldivide (\), transpose ('')'
    ''
    '3) Least-squares refinement (nonlinear):  lsqnonlin()'
    '   -> MATLAB:  lsqnonlin(@residual, x0)'
    ''
    '4) Satellite orbit propagation:'
    '   -> MATLAB:  cos(), sin(), deg2rad()'
    ''
    '5) 3D animation:'
    '   -> MATLAB:  plot3(), drawnow limitrate, scatter3()'
    ''
    '6) LaTeX rendering:'
    '   -> MATLAB:  text(...,''Interpreter'',''latex'')'
    });

%% ------------------------------------------------------------------------
%  SECTION 2: SIMULATION PARAMETERS & STATE
%  ------------------------------------------------------------------------
%  The GPS constellation is modelled as 6 satellites on circular orbits.
%  The user is modelled as a moving receiver on a 2D path in the XY plane.
%  ------------------------------------------------------------------------

% Physical constants
c = 299792458;                 % speed of light (m/s)

% Satellite orbit parameters (simplified, non-physical but illustrative)
nSat  = 6;
Rorb  = 2.66e7;                % orbital radius (m)
inc   = deg2rad(55);           % inclination (rad)
omega = 2*pi/ (12*3600);       % angular rate (rad/s), 12-h orbit

% Satellite initial phase offsets (evenly distributed)
phase0 = linspace(0,2*pi,nSat+1); phase0(end)=[];

% User initial position & velocity (m, m/s)
userPos = [ 5e6, -3e6,  1e6 ];
userVel = [ 2e2,  1.5e2, 0 ];

% Clock bias of the receiver (m) - a constant offset for this demo
clockBias = 1.5e3;             % ~5 microseconds -> 1.5 km

% Simulation timing
dt        = 0.05;              % animation step (s of real time)
simTime   = 0;                 % simulation time accumulator
running   = false;             % flag to control the loop

% Handles to graphics objects (so we can update them efficiently)
hSat   = gobjects(nSat,1);     % satellite markers
hSatTxt= gobjects(nSat,1);     % satellite labels
hLine  = gobjects(nSat,1);     % pseudorange lines
hUser  = [];                   % user marker
hEst   = [];                   % estimated-position marker
hTrail = [];                   % trail of user path

% Pre-allocate arrays to store history (for trail)
trailX = nan(1,500); trailY = trailX; trailZ = trailX; trailIdx = 1;

%% ------------------------------------------------------------------------
%  SECTION 3: INITIALIZE GRAPHICS OBJECTS
%  ------------------------------------------------------------------------
initializeGraphics();

    function initializeGraphics()
        % Create satellite markers and pseudorange lines
        for k = 1:nSat
            hSat(k)   = plot3(ax,0,0,0,'o','MarkerSize',10, ...
                              'MarkerFaceColor',[0.2 0.6 1], ...
                              'MarkerEdgeColor','k');
            hSatTxt(k)= text(ax,0,0,0,sprintf('SV%d',k), ...
                             'Color','b','FontWeight','bold');
            hLine(k)  = plot3(ax,[0 0],[0 0],[0 0],'--', ...
                              'Color',[0.6 0.6 0.6],'LineWidth',0.8);
        end
        % User marker
        hUser = plot3(ax,userPos(1),userPos(2),userPos(3),'^', ...
                      'MarkerSize',12,'MarkerFaceColor',[1 0.4 0], ...
                      'MarkerEdgeColor','k');
        % Estimated position marker (blue diamond)
        hEst  = plot3(ax,userPos(1),userPos(2),userPos(3),'d', ...
                      'MarkerSize',10,'MarkerFaceColor',[0 0.8 0], ...
                      'MarkerEdgeColor','k');
        % Trail
        hTrail= plot3(ax,nan,nan,nan,'-','Color',[1 0.5 0],'LineWidth',1.2);
        % Legend
        legend(ax,{'Satellites','','Pseudorange','User (true)', ...
                   'User (estimated)','Trail'},'Location','northeastoutside');
    end

%% ------------------------------------------------------------------------
%  SECTION 4: SIMULATION LOOP (dynamic animation)
%  ------------------------------------------------------------------------
%  At every step we:
%    1. Propagate satellite positions on their circular orbits.
%    2. Move the user by a simple linear velocity.
%    3. Compute true ranges (geometric) + clock bias + noise = pseudoranges.
%    4. Estimate the user position via linearized least-squares (one step).
%    5. Update graphics: satellites, pseudorange lines, user markers, trail.
%  ------------------------------------------------------------------------

    function startSim()
        if running, return; end
        running = true;
        lblStatus.Text = 'Status: Running';
        tic;
        while running && isvalid(fig)
            % --- 4.1 Propagate satellites --------------------------------
            satPos = zeros(nSat,3);
            for k = 1:nSat
                th = omega*simTime + phase0(k);
                satPos(k,:) = Rorb*[ cos(th), ...
                                     sin(th)*cos(inc), ...
                                     sin(th)*sin(inc) ];
            end

            % --- 4.2 Move user -------------------------------------------
            userPos = userPos + userVel*dt;

            % --- 4.3 Compute pseudoranges --------------------------------
            % Geometric range: rho_geo = || sat - user ||
            rangeGeo = vecnorm(satPos - userPos, 2, 2);   % Nx1
            % Pseudorange (add clock bias + small noise)
            noise   = 3*randn(nSat,1);                    % measurement noise
            rho     = rangeGeo + clockBias + noise;

            % --- 4.4 Estimate user position (linear LS, one iteration) ---
            estPos = estimatePosition(satPos, rho, userPos);

            % --- 4.5 Update graphics -------------------------------------
            for k = 1:nSat
                % Satellite marker
                set(hSat(k),'XData',satPos(k,1),'YData',satPos(k,2), ...
                            'ZData',satPos(k,3));
                set(hSatTxt(k),'Position',satPos(k,:)+1e6);
                % Pseudorange line
                set(hLine(k),'XData',[satPos(k,1) userPos(1)], ...
                             'YData',[satPos(k,2) userPos(2)], ...
                             'ZData',[satPos(k,3) userPos(3)]);
            end
            set(hUser,'XData',userPos(1),'YData',userPos(2),'ZData',userPos(3));
            set(hEst ,'XData',estPos(1),'YData',estPos(2),'ZData',estPos(3));

            % Trail
            trailIdx = mod(trailIdx, numel(trailX)) + 1;
            trailX(trailIdx)=userPos(1);
            trailY(trailIdx)=userPos(2);
            trailZ(trailIdx)=userPos(3);
            set(hTrail,'XData',trailX,'YData',trailY,'ZData',trailZ);

            drawnow limitrate;      % faster rendering

            % Advance time and pause so the loop runs in real time
            simTime = simTime + dt;
            pause(dt);
        end
    end

    function stopSim()
        running = false;
        if isvalid(lblStatus), lblStatus.Text = 'Status: Stopped'; end
    end

    function resetSim()
        running = false;
        simTime = 0;
        userPos = [ 5e6, -3e6,  1e6 ];
        trailX(:) = nan; trailY(:) = nan; trailZ(:) = nan; trailIdx = 1;
        initializeGraphics();
        if isvalid(lblStatus), lblStatus.Text = 'Status: Reset'; end
    end

%% ------------------------------------------------------------------------
%  SECTION 5: POSITION ESTIMATION (implements the GPS equations)
%  ------------------------------------------------------------------------
%  Linearized least-squares solution:
%      delta_x = (A'*A) \ (A' * b)
%  where  A is the geometry (unit LOS) matrix  and
%         b is the residual (pseudorange minus predicted range).
%  ------------------------------------------------------------------------
    function estPos = estimatePosition(satPos, rho, x0)
        % x0 = current best guess (3x1)
        estPos = x0(:)';
        % Predicted geometric ranges at x0
        pred = vecnorm(satPos - estPos, 2, 2);
        % Residual vector:  b = rho - pred
        b = rho - pred;
        % Geometry matrix A (N x 3): unit vectors from user to satellites
        A = (satPos - estPos) ./ pred;      % Nx3
        % Weighted least-squares (equal weights here)
        dx = (A'*A) \ (A'*b);
        % Update the estimate
        estPos = estPos + dx';
    end

%% ------------------------------------------------------------------------
%  SECTION 6: CLEAN-UP ON CLOSE
%  ------------------------------------------------------------------------
    fig.CloseRequestFcn = @(~,~) closeApp();
    function closeApp()
        running = false;
        delete(fig);
    end
end