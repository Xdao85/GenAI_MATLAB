function GPS_GUI()
% =========================================================================
% GPS_GUI  -  Interactive GUI for simulating GPS signal dynamics
% -------------------------------------------------------------------------
% Features:
%   1) LaTeX-rendered GPS equations inside the GUI (pseudorange, LSQ pos.)
%   2) Documentation panel explaining each MATLAB function used
%   3) 3D animation of satellites, user trajectory, pseudorange lines
%   4) Heavily commented: GUI design, LaTeX, simulation, visualization
% =========================================================================

%% ======================= SECTION 1: GUI DESIGN ==========================
% Create the main figure and lay out panels using uigridlayout so the GUI
% resizes gracefully. Left column = 3D view; right column = equations,
% function reference, controls and live status.

fig = uifigure('Name','GPS Dynamics Simulator', ...
               'Position',[80 60 1300 780], ...
               'Color',[0.10 0.11 0.14]);

mainGrid = uigridlayout(fig,[1 2]);
mainGrid.ColumnWidth = {'2x','1x'};
mainGrid.Padding     = [10 10 10 10];
mainGrid.ColumnSpacing = 10;

% ---- Left: 3D axes panel -------------------------------------------------
leftPanel = uipanel(mainGrid,'Title','3D GPS Scene','FontWeight','bold', ...
                    'ForegroundColor','w','BackgroundColor',[0.13 0.14 0.18]);
leftGrid  = uigridlayout(leftPanel,[2 1]);
leftGrid.RowHeight = {'1x', 40};

ax = uiaxes(leftGrid);
ax.Color = [0.05 0.05 0.08];
ax.XColor = [0.9 0.9 0.9]; ax.YColor = [0.9 0.9 0.9]; ax.ZColor = [0.9 0.9 0.9];
ax.GridColor = [0.4 0.4 0.4]; ax.GridAlpha = 0.4;
grid(ax,'on'); hold(ax,'on');
xlabel(ax,'X (km)'); ylabel(ax,'Y (km)'); zlabel(ax,'Z (km)');
title(ax,'Live GPS Constellation & User Track','Color','w');
view(ax,35,25);
axis(ax,[-22000 22000 -22000 22000 -22000 22000]);
axis(ax,'manual');   % prevent auto-rescale during animation

% ---- Control row beneath the axes ---------------------------------------
ctrlGrid = uigridlayout(leftGrid,[1 6]);
ctrlGrid.ColumnWidth = {90,90,90,110,'1x',110};

btnStart = uibutton(ctrlGrid,'Text','▶ Start','FontWeight','bold', ...
    'BackgroundColor',[0.20 0.65 0.35],'FontColor','w', ...
    'ButtonPushedFcn',@(~,~) startSim());
btnPause = uibutton(ctrlGrid,'Text','⏸ Pause', ...
    'BackgroundColor',[0.85 0.65 0.15],'FontColor','w', ...
    'ButtonPushedFcn',@(~,~) pauseSim());
btnReset = uibutton(ctrlGrid,'Text','⟲ Reset', ...
    'BackgroundColor',[0.55 0.25 0.25],'FontColor','w', ...
    'ButtonPushedFcn',@(~,~) resetSim());
btnClear = uibutton(ctrlGrid,'Text','Clear Track', ...
    'ButtonPushedFcn',@(~,~) clearTrack());

lblSpeed = uilabel(ctrlGrid,'Text','Speed:','FontColor','w', ...
                   'HorizontalAlignment','right');
sldSpeed = uislider(ctrlGrid,'Limits',[0.25 5],'Value',1);
sldSpeed.MajorTicks = [0.25 1 2 3 5];

% ---- Right column: tabbed info panel ------------------------------------
rightTab = uitabgroup(mainGrid);
rightTab.SelectionChangedFcn = @(~,~) []; % placeholder

% Tab 1 – Live status
tabStatus = uitab(rightTab,'Title','Status');
statusGrid = uigridlayout(tabStatus,[1 1]);
statusArea = uitextarea(statusGrid,'Editable','off', ...
    'FontName','Consolas','FontSize',12, ...
    'BackgroundColor',[0.08 0.08 0.10],'FontColor',[0.85 1 0.85]);
% Initialize with a valid N-by-1 cell array of char vectors:
statusArea.Value = {'Ready. Press ▶ Start.'};

% Tab 2 – Equations (LaTeX)
tabEq = uitab(rightTab,'Title','Equations (LaTeX)');
eqGrid = uigridlayout(tabEq,[6 1]);
eqGrid.RowHeight = repmat({80},1,6);

makeEqLabel(eqGrid, ...
    '$\rho_i = \| \mathbf{r}_u - \mathbf{r}_i \| + c\,\delta t_u + \varepsilon_i$', ...
    'Pseudorange (code phase) to satellite i');

makeEqLabel(eqGrid, ...
    '$\rho_i = c\,(t_{rx} - t_{tx}^{(i)})$', ...
    'Pseudorange from travel time');

makeEqLabel(eqGrid, ...
    '$\hat{\mathbf{x}} = \arg\min_{\mathbf{x}} \sum_{i=1}^{N} \left( \rho_i - \| \mathbf{r}_u - \mathbf{r}_i \| - c\,\delta t_u \right)^2$', ...
    'Non-linear least-squares position estimate');

makeEqLabel(eqGrid, ...
    '$\Delta\mathbf{x} = (H^{T}W H)^{-1} H^{T} W \,\mathbf{r}, \quad H = \partial \rho / \partial \mathbf{x}$', ...
    'Gauss-Newton / Weighted LSQ update');

makeEqLabel(eqGrid, ...
    '$\mathbf{r}_i(t) = R_z(\Omega t)\, R_x(i)\, \mathbf{r}_i(0)$', ...
    'Approximate satellite orbital motion');

makeEqLabel(eqGrid, ...
    '$\sigma_{pos} = \sqrt{\mathrm{tr}\left[(H^T H)^{-1}\right]}\;\sigma_\rho$', ...
    'Position DOP / covariance');

% Tab 3 – MATLAB function reference
tabFcn = uitab(rightTab,'Title','MATLAB Functions');
fcnGrid = uigridlayout(tabFcn,[1 1]);
fcnArea = uitextarea(fcnGrid,'Editable','off', ...
    'FontName','Consolas','FontSize',11, ...
    'BackgroundColor',[0.08 0.08 0.10],'FontColor',[0.9 0.9 1.0]);

% *** FIX: assign a proper N-by-1 cell array of char vectors ***
txtLines = functionReferenceText();           % returns cell of char
txtLines = txtLines(:);                       % force N-by-1
fcnArea.Value = txtLines;

%% ==================== SECTION 2: LATEX INTEGRATION =======================
% MATLAB uilabel supports a LaTeX subset when Interpreter='latex'.

    function makeEqLabel(parent, latexStr, caption)
        g = uigridlayout(parent,[1 2]);
        g.ColumnWidth = {'1x', 260};
        lbl = uilabel(g,'Interpreter','latex','Text',latexStr, ...
                      'FontSize',15,'FontColor',[0.95 0.95 0.65], ...
                      'HorizontalAlignment','center','VerticalAlignment','center');
        cap = uilabel(g,'Text',caption,'FontColor',[0.75 0.8 0.9], ...
                      'FontSize',11,'WordWrap','on');
    end

%% ================= SECTION 3: SIMULATION STATE & LOGIC ===================
% The simulation models a simplified GPS constellation (8 satellites on
% circular orbits) and a user moving along a smooth 3D trajectory.

% --- Constellation (units: km, seconds) ----------------------------------
c_km_s   = 299792.458;                % speed of light (km/s)
Re       = 6371;                      % Earth radius (km)
orbitR   = 26560;                     % GPS orbital radius (km)
omega    = 2*pi/(12*3600);            % nominal orbital rate (rad/s)

nSat     = 8;
inc      = deg2rad(55);
raan0    = linspace(0, 2*pi*(nSat-1)/nSat, nSat);  % RAAN spacing
phase0   = zeros(1,nSat);

% --- User trajectory: smooth Lissajous around origin (km) ----------------
trajA = [8000 6000 4000];
trajF = [1/1200 1/900 1/1500];   % very slow, in 1/s
trajP = [0 pi/3 pi/5];
userPos = [trajA(1)*cos(trajP(1)); trajA(2)*cos(trajP(2)); trajA(3)*cos(trajP(3))];

% --- Estimation state ----------------------------------------------------
estPos   = userPos + randn(3,1)*50;   % initial guess with error
estBias  = 0;                        % clock bias (km)

% --- Animation handles ---------------------------------------------------
hUser      = plot3(ax,userPos(1),userPos(2),userPos(3),'o', ...
                   'MarkerSize',10,'MarkerFaceColor',[1 0.8 0.1], ...
                   'MarkerEdgeColor','k');
hTrack     = plot3(ax,userPos(1),userPos(2),userPos(3),'-', ...
                   'Color',[1 0.8 0.1],'LineWidth',1.5);
hEst       = plot3(ax,estPos(1),estPos(2),estPos(3),'x', ...
                   'MarkerSize',12,'LineWidth',2,'Color',[0.2 1 0.4]);
hSat       = gobjects(1,nSat);
hSatLabel  = gobjects(1,nSat);
hPseudo    = gobjects(1,nSat);
hEarth     = drawEarth(ax,Re);

trackX = userPos(1); trackY = userPos(2); trackZ = userPos(3);

% --- Timer-driven animation ---------------------------------------------
t = 0;
dt = 1;                       % simulated seconds per tick
running = false;
timerObj = timer('ExecutionMode','fixedSpacing','Period',0.05, ...
                 'BusyMode','drop','TimerFcn',@(~,~) simTick());

% ---- Callbacks ----------------------------------------------------------
    function startSim()
        if strcmp(timerObj.Running,'off')
            running = true;
            start(timerObj);
            appendStatus('▶ Simulation started.');
        end
    end
    function pauseSim()
        running = false;
        if strcmp(timerObj.Running,'on'); stop(timerObj); end
        appendStatus(sprintf('⏸ Paused at t = %.1f s', t));
    end
    function resetSim()
        pauseSim();
        t = 0;
        userPos = [trajA(1)*cos(trajP(1)); trajA(2)*cos(trajP(2)); trajA(3)*cos(trajP(3))];
        estPos  = userPos + randn(3,1)*50;
        trackX = userPos(1); trackY = userPos(2); trackZ = userPos(3);
        set(hUser,'XData',userPos(1),'YData',userPos(2),'ZData',userPos(3));
        set(hTrack,'XData',trackX,'YData',trackY,'ZData',trackZ);
        set(hEst,'XData',estPos(1),'YData',estPos(2),'ZData',estPos(3));
        statusArea.Value = {'Reset. Ready. Press ▶ Start.'};
    end
    function clearTrack()
        trackX = userPos(1); trackY = userPos(2); trackZ = userPos(3);
        set(hTrack,'XData',trackX,'YData',trackY,'ZData',trackZ);
    end
    function appendStatus(msg)
        % Keep a rolling buffer of the last ~12 lines, always N-by-1 cell
        cur = statusArea.Value;
        if ischar(cur); cur = {cur}; end
        cur = cur(:);
        cur{end+1,1} = msg;                 %#ok<AGROW>
        if numel(cur) > 12
            cur = cur(end-11:end);
        end
        statusArea.Value = cur;
    end

% ---- Core simulation step ----------------------------------------------
    function simTick()
        if ~running || ~isvalid(fig); return; end
        speed = sldSpeed.Value;
        t = t + dt*speed;

        % (a) Advance satellite positions along circular orbits
        satPos = zeros(3,nSat);
        for k = 1:nSat
            ang = phase0(k) + omega*t;
            xk = orbitR * cos(ang);
            yk = orbitR * sin(ang);
            Rz = [cos(raan0(k)) -sin(raan0(k)) 0;
                  sin(raan0(k))  cos(raan0(k)) 0;
                  0              0             1];
            Rx = [1 0 0; 0 cos(inc) -sin(inc); 0 sin(inc) cos(inc)];
            satPos(:,k) = Rz*Rx*[xk; yk; 0];
        end

        % (b) Advance true user position (Lissajous trajectory)
        userPos = [trajA(1)*cos(trajF(1)*2*pi*t + trajP(1));
                   trajA(2)*cos(trajF(2)*2*pi*t + trajP(2));
                   trajA(3)*cos(trajF(3)*2*pi*t + trajP(3))];

        % (c) Pseudoranges: rho_i = ||r_u - r_i|| + c*dt_u + noise
        cdt   = 0.02;                                   % 20 m clock bias (km)
        noise = randn(1,nSat)*0.005;                    % ~5 m noise (km)
        rho   = vecnorm(satPos - userPos,2,1) + cdt + noise;
        rho   = rho(:);

        % (d) Gauss-Newton least-squares position + clock estimate
        [estPos, estBias, iters, residNorm] = lsqPosition(satPos, rho, estPos, estBias);

        % (e) Graphics updates
        set(hUser,'XData',userPos(1),'YData',userPos(2),'ZData',userPos(3));
        trackX(end+1) = userPos(1); %#ok<AGROW>
        trackY(end+1) = userPos(2); %#ok<AGROW>
        trackZ(end+1) = userPos(3); %#ok<AGROW>
        set(hTrack,'XData',trackX,'YData',trackY,'ZData',trackZ);
        set(hEst,'XData',estPos(1),'YData',estPos(2),'ZData',estPos(3));

        for k = 1:nSat
            if ~isvalid(hSat(k))
                hSat(k) = plot3(ax,satPos(1,k),satPos(2,k),satPos(3,k), ...
                    '^','MarkerSize',8,'MarkerFaceColor',[0.3 0.7 1], ...
                    'MarkerEdgeColor','w');
                hSatLabel(k) = text(ax,satPos(1,k),satPos(2,k),satPos(3,k)+900, ...
                    sprintf('SV%d',k),'Color',[0.7 0.85 1],'FontSize',8, ...
                    'HorizontalAlignment','center');
                hPseudo(k) = plot3(ax,[userPos(1) satPos(1,k)], ...
                                      [userPos(2) satPos(2,k)], ...
                                      [userPos(3) satPos(3,k)], ...
                                      '-','Color',[0.4 0.9 0.9 0.35],'LineWidth',0.8);
            else
                set(hSat(k),'XData',satPos(1,k),'YData',satPos(2,k),'ZData',satPos(3,k));
                set(hSatLabel(k),'Position',[satPos(1,k) satPos(2,k) satPos(3,k)+900]);
                set(hPseudo(k),'XData',[userPos(1) satPos(1,k)], ...
                               'YData',[userPos(2) satPos(2,k)], ...
                               'ZData',[userPos(3) satPos(3,k)]);
            end
        end

        err = norm(estPos - userPos);
        % Refresh the status textarea (N-by-1 cell of char vectors)
        statusArea.Value = {
            sprintf('t = %8.1f s', t)
            sprintf('True user  (km): [%8.2f %8.2f %8.2f]', userPos)
            sprintf('Estimated   (km): [%8.2f %8.2f %8.2f]', estPos)
            sprintf('Position error  : %8.3f km  (%.1f m)', err, err*1000)
            sprintf('Clock bias est. : %8.5f km (%.2f m)', estBias, estBias*1000)
            sprintf('LSQ iterations  : %d', iters)
            sprintf('Residual norm   : %.5f', residNorm)
            sprintf('Active SVs      : %d', nSat)
        };
    end

% Clean up timer on close
fig.CloseRequestFcn = @(~,~) closeApp();
    function closeApp()
        try
            if strcmp(timerObj.Running,'on'); stop(timerObj); end
            delete(timerObj);
        catch
        end
        delete(fig);
    end
end  % ===================== END GPS_GUI ================================


%% ================== HELPER: Least-squares position solver ================
function [pos, bias, iters, resNorm] = lsqPosition(satPos, rho, pos0, bias0)
% LSQPOSITION  Gauss-Newton solution of the GPS pseudorange equations.
%   Model: rho_i = || r_u - r_i || + b   (b = c*dt_u)
%   Unknowns: r_u (3) and b (1).  Linearised as:
%       H * [dr ; db] = residual
%   with H row i = [ -(r_i - r_u)/||r_i - r_u|| , 1 ].
% -------------------------------------------------------------------------
    pos = pos0(:);
    bias = bias0;
    maxIter = 8; tol = 1e-4;

    for iters = 1:maxIter
        dvec = satPos - pos;                       % 3 x N
        range = vecnorm(dvec,2,1).';               % N x 1
        pred = range + bias;                       % predicted pseudorange
        residual = rho - pred;                     % N x 1
        H = [ -dvec.' ./ range , ones(numel(rho),1) ];  % N x 4 Jacobian

        % Weighted normal equations (weights = 1 here)
        dx = (H.'*H) \ (H.'*residual);
        pos  = pos  + dx(1:3);
        bias = bias + dx(4);

        if norm(dx) < tol; break; end
    end
    resNorm = norm(rho - (vecnorm(satPos-pos,2,1).' + bias));
end


%% ================== HELPER: Draw a simple Earth sphere ==================
function h = drawEarth(ax,R)
    [xs,ys,zs] = sphere(40);
    h = surf(ax,R*xs,R*ys,R*zs, ...
        'FaceColor',[0.15 0.35 0.65],'EdgeColor','none', ...
        'FaceAlpha',0.55);
    % Wireframe lat/long lines for visual reference
    theta = linspace(0,2*pi,60);
    for lat = -60:30:60
        r = R*cosd(lat); z = R*sind(lat);
        plot3(ax,r*cos(theta),r*sin(theta),z*ones(size(theta)), ...
              '-','Color',[0.25 0.5 0.75 0.35]);
    end
end


%% ================== HELPER: MATLAB function reference ===================
function txt = functionReferenceText()
% Returns an N-by-1 CELL ARRAY OF CHAR VECTORS (not strings) so that the
% assignment `fcnArea.Value = functionReferenceText();` is valid in
% MATLAB R2024b (uitextarea.Value requires cellstr, string array, or
% categorical — mixed types and empty "" entries previously caused errors).
    S = {
"=== GUI DESIGN ================================================"
"uifigure        : creates a web-based figure window (App Designer style)."
"uigridlayout    : arranges components on a flexible grid (responsive)."
"uipanel         : titled container that groups related widgets."
"uibutton        : clickable push button with callback (ButtonPushedFcn)."
"uislider        : continuous numeric input (used for animation speed)."
"uilabel         : static text; Interpreter='latex' renders math."
"uitextarea      : multi-line read-only text (status / references)."
"uitabgroup/uitab: tabbed container to switch between panels."
""
"=== LATEX RENDERING ==========================================="
"uilabel(...,'Interpreter','latex')  : renders TeX math in the label."
"\rho, \delta, \| \|, \sum, \arg\min, \hat, \varepsilon, \Omega"
"                : Greek letters, operators, accents in LaTeX."
"$...$           : inline math mode delimiter recognised by MATLAB."
""
"=== NUMERICAL / SIMULATION ===================================="
"linspace        : generate evenly spaced vectors (RAAN, theta)."
"cos, sin, deg2rad, pi : orbit parametrisation."
"zeros, ones     : preallocate arrays (performance)."
"vecnorm         : vectorised Euclidean norm  ->  ||r_u - r_i||."
"  (alternative: sqrt(sum(d.^2,1)))"
"randn           : Gaussian noise added to pseudoranges / init guess."
"norm            : scalar vector norm (convergence test & error metric)."
"\\ (mldivide)    : solves the weighted normal equations (H'H) \ (H'r)."
"  -> uses Cholesky / LU internally; robust for small systems."
"while / for     : Gauss-Newton iteration and orbit loop."
""
"=== VISUALISATION ============================================="
"uiaxes          : axes embedded in a uifigure (supports plot3)."
"plot3           : 3-D line/marker plots for satellites & tracks."
"surf            : renders the Earth sphere (from sphere(40))."
"sphere          : generates unit-sphere coordinates."
"text            : places 3-D labels next to satellites."
"set(gobj,...)   : updates XData/YData/ZData every frame (fast redraw)."
"hold on, grid on: 3-D scene setup."
"axis manual     : freezes limits so animation stays centred."
""
"=== TIMING & CALLBACKS ========================================"
"timer           : fixed-spacing background timer drives animation."
"start/stop/delete : lifecycle of the timer object."
"strcmp          : checks timer.running == 'on'."
"isvalid         : guards against using deleted graphics handles."
""
"=== PROGRAM STRUCTURE ========================================="
"Nested functions (startSim, pauseSim, resetSim, clearTrack, simTick)"
"share the GUI workspace so handles (ax, hUser, ...) are visible to"
"callbacks without globals. Helper functions lsqPosition, drawEarth,"
"functionReferenceText live outside GPS_GUI for clarity."
    };
    % Convert any string scalars to char vectors, then force column shape:
    txt = cell(numel(S),1);
    for i = 1:numel(S)
        if isstring(S{i})
            txt{i} = char(S{i});
        else
            txt{i} = S{i};
        end
    end
end