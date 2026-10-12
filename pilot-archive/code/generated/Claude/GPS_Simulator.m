function GPS_Simulator()
% GPS_SIMULATOR  Interactive GUI that simulates GPS signal reception and
% position fixing (pseudorange + iterative least squares).
%
% Run with:  >> GPS_Simulator
% Requires:  base MATLAB (R2016b or newer). No toolboxes needed.
%
% Code sections
%   1. CONSTANTS & SIMULATION STATE
%   2. GUI DESIGN            (figure, panels, controls)
%   3. LATEX INTEGRATION     (equation panel drawn with 'Interpreter','latex')
%   4. FUNCTION REFERENCE    (list of MATLAB functions used)
%   5. VISUALIZATION SETUP   (3-D scene, error plot)
%   6. SIMULATION LOGIC      (orbits, user motion, pseudoranges, solver)
%   7. VISUALIZATION UPDATE  (real-time graphics refresh)

%% ========================= 1. CONSTANTS & STATE =========================
% All distances in km, time in s, angles in rad unless stated.
c    = 299792.458;          % speed of light [km/s]
Re   = 6371;                % mean Earth radius [km]
aOrb = 26560;               % GPS orbit radius [km]
mu   = 398600.4418;         % Earth's gravitational parameter [km^3/s^2]
wE   = 7.2921159e-5;        % Earth rotation rate [rad/s]
inc  = deg2rad(55);         % orbital inclination
nMot = sqrt(mu/aOrb^3);     % mean motion n = sqrt(mu/a^3)  [rad/s]

% 24-satellite constellation: 6 planes x 4 satellites
nSat   = 24;
RAAN   = deg2rad(repelem(0:60:300, 4));                       % plane orientation
M0     = deg2rad(repmat(0:90:270, 1, 6) + repelem(0:15:75, 4)); % initial phase

% Simulation state (shared with the nested functions below)
t        = 0;                          % simulation time [s]
lat      = deg2rad(11.15);             % user latitude
lon      = deg2rad(106.60);            % user longitude
heading  = 0;                          % user heading [rad]
running  = false;                      % animation flag
trail    = zeros(3,0);                 % user path history (ECEF)
errT     = [];  errV = [];             % error history for plot

%% ============================ 2. GUI DESIGN =============================
fig = figure('Name','GPS Dynamics Simulator','NumberTitle','off', ...
    'Units','normalized','Position',[0.03 0.06 0.94 0.86], ...
    'Color',[0.94 0.94 0.94],'CloseRequestFcn',@onClose);

% Left-top: equations panel   | Left-bottom: MATLAB functions panel
pEq  = uipanel(fig,'Title','Core Mathematical Equations','FontWeight','bold', ...
    'Units','normalized','Position',[0.01 0.40 0.31 0.59],'BackgroundColor','w');
pFn  = uipanel(fig,'Title','Core MATLAB Functions Used','FontWeight','bold', ...
    'Units','normalized','Position',[0.01 0.01 0.31 0.38]);
% Right: controls & results
pCtl = uipanel(fig,'Title','Controls & Results','FontWeight','bold', ...
    'Units','normalized','Position',[0.77 0.01 0.22 0.98]);

% --- Control buttons
btnRun = uicontrol(pCtl,'Style','pushbutton','String','Start', ...
    'Units','normalized','Position',[0.05 0.93 0.42 0.05], ...
    'FontWeight','bold','Callback',@onStartStop);
uicontrol(pCtl,'Style','pushbutton','String','Reset', ...
    'Units','normalized','Position',[0.53 0.93 0.42 0.05], ...
    'FontWeight','bold','Callback',@onReset);

% --- Sliders (helper builds label + value readout + slider)
sldSpeed = makeSlider(pCtl,0.84,'Time scale (x20 s / frame)',1,20,5,'%.0f');
sldUser  = makeSlider(pCtl,0.77,'User speed [m/s]',0,300,150,'%.0f');
sldNoise = makeSlider(pCtl,0.70,'Range noise sigma [m]',0,50,5,'%.1f');
sldBias  = makeSlider(pCtl,0.63,'Receiver clock bias [us]',0,500,120,'%.0f');
sldMask  = makeSlider(pCtl,0.56,'Elevation mask [deg]',0,30,5,'%.0f');

% --- Live results text box
txtInfo = uicontrol(pCtl,'Style','text','Units','normalized', ...
    'Position',[0.03 0.01 0.94 0.52],'HorizontalAlignment','left', ...
    'FontName','Courier New','FontSize',9,'BackgroundColor',[1 1 1]);

%% ======================== 3. LATEX INTEGRATION ==========================
% Equations are drawn with text(...,'Interpreter','latex') on an invisible
% axes that fills the panel. This renders properly in every MATLAB version.
axEq = axes('Parent',pEq,'Units','normalized','Position',[0 0 1 1], ...
    'Visible','off','XLim',[0 1],'YLim',[0 1]);
eqs = { ...
  '1) Pseudorange measurement', ...
  '$\rho_i=\left\|\mathbf{s}_i-\mathbf{u}\right\|+c\,\delta t+\varepsilon_i$'; ...
  '   Geometric range', ...
  '$\left\|\mathbf{s}_i-\mathbf{u}\right\|=\sqrt{(x_i-x)^2+(y_i-y)^2+(z_i-z)^2}$'; ...
  '2) Linearization about estimate', ...
  '$\Delta\rho=H\,\Delta\mathbf{x},\quad H_i=\left[-\hat{\mathbf{e}}_i^{T}\;\;1\right]$'; ...
  '3) Least-squares position update', ...
  '$\Delta\mathbf{x}=(H^{T}H)^{-1}H^{T}\Delta\rho,\quad \hat{\mathbf{x}}\leftarrow\hat{\mathbf{x}}+\Delta\mathbf{x}$'; ...
  '4) Satellite orbit (Kepler, circular)', ...
  '$M(t)=M_0+n\,t,\qquad n=\sqrt{\mu/a^{3}}$'; ...
  '5) ECI to ECEF (Earth rotation)', ...
  '$\mathbf{r}_{ECEF}=R_z(-\omega_e t)\,\mathbf{r}_{ECI}$'; ...
  '6) Geometric dilution of precision', ...
  '$\mathrm{GDOP}=\sqrt{\mathrm{tr}\left[(H^{T}H)^{-1}\right]}$'};
yPos = linspace(0.95,0.06,size(eqs,1));
for k = 1:size(eqs,1)
    % caption (plain text) and equation (LaTeX) stacked vertically
    text(axEq,0.03,yPos(k),eqs{k,1},'Units','normalized','FontWeight','bold', ...
        'FontSize',10,'Color',[0.1 0.25 0.6],'Interpreter','none');
    text(axEq,0.05,yPos(k)-0.045,eqs{k,2},'Units','normalized', ...
        'FontSize',12,'Interpreter','latex','VerticalAlignment','middle');
end

%% ====================== 4. MATLAB FUNCTION REFERENCE ====================
% Text list mapping each equation to the MATLAB code that implements it.
fnList = { ...
 'EQ 1  Pseudorange', ...
 '  vecnorm(S-u,2,1)   range ||s_i-u||', ...
 '  sigma*randn(m,1)   noise eps_i', ...
 '  rng + c*dt         adds clock bias', ...
 'EQ 2  Linearization', ...
 '  -(S-x)./r          unit vectors e_i', ...
 '  [E, ones(m,1)]     geometry matrix H', ...
 'EQ 3  Least squares', ...
 '  H \ dRho           QR/LS solve of dx', ...
 '  norm(dx) < tol     convergence test', ...
 'EQ 4  Orbits', ...
 '  sqrt(mu/a^3)       mean motion n', ...
 '  cos, sin, repelem  orbit -> ECI', ...
 'EQ 5  Earth rotation', ...
 '  x*cos(th)+y*sin(th) ECI -> ECEF', ...
 'EQ 6  DOP', ...
 '  sqrt(trace(inv(H''*H)))', ...
 'Visualization / animation', ...
 '  surf, plot3, text  3-D scene', ...
 '  set(h,''XData'',..) real-time update', ...
 '  timer, drawnow     animation loop'};
uicontrol(pFn,'Style','listbox','String',fnList,'Units','normalized', ...
    'Position',[0.02 0.02 0.96 0.96],'FontName','Courier New','FontSize',9);

%% ====================== 5. VISUALIZATION SETUP ==========================
ax3 = axes('Parent',fig,'Units','normalized','Position',[0.34 0.30 0.42 0.67]);
hold(ax3,'on'); grid(ax3,'on'); axis(ax3,'equal');
xlabel(ax3,'X_{ECEF} [km]'); ylabel(ax3,'Y_{ECEF} [km]'); zlabel(ax3,'Z_{ECEF} [km]');
title(ax3,'GPS Constellation, Pseudoranges and User (drag to rotate)');
lim = 30000; xlim(ax3,[-lim lim]); ylim(ax3,[-lim lim]); zlim(ax3,[-lim lim]);
view(ax3,[125 25]); rotate3d(ax3,'on');

% Earth sphere with lat/long grid
[X,Y,Z] = sphere(30);
surf(ax3,Re*X,Re*Y,Re*Z,'FaceColor',[0.3 0.55 0.9],'FaceAlpha',0.7, ...
    'EdgeColor',[0.7 0.85 1],'EdgeAlpha',0.4);

% Graphics handles updated every frame (created once, then only 'set')
hSatVis = plot3(ax3,NaN,NaN,NaN,'o','MarkerFaceColor',[0.1 0.7 0.2], ...
    'MarkerEdgeColor','k','MarkerSize',8);              % visible satellites
hSatHid = plot3(ax3,NaN,NaN,NaN,'o','MarkerFaceColor',[0.7 0.7 0.7], ...
    'MarkerEdgeColor',[0.4 0.4 0.4],'MarkerSize',6);    % hidden satellites
hLines  = plot3(ax3,NaN,NaN,NaN,'-','Color',[1 0.55 0],'LineWidth',1); % pseudorange lines
hTrail  = plot3(ax3,NaN,NaN,NaN,'-','Color','r','LineWidth',1.5);       % user path
hUser   = plot3(ax3,NaN,NaN,NaN,'p','MarkerFaceColor','r', ...
    'MarkerEdgeColor','k','MarkerSize',14);             % true user position
hEst    = plot3(ax3,NaN,NaN,NaN,'bx','MarkerSize',12,'LineWidth',2); % estimated position
hLbl    = gobjects(1,nSat);
for k = 1:nSat
    hLbl(k) = text(ax3,0,0,0,sprintf('G%02d',k),'FontSize',7,'Clipping','on');
end
legend(ax3,[hSatVis hSatHid hLines hUser hEst], ...
    {'Visible sat','Hidden sat','Pseudorange','True user','Estimated'}, ...
    'Location','northeast','FontSize',8);

% Position-error history plot
axErr = axes('Parent',fig,'Units','normalized','Position',[0.37 0.06 0.36 0.17]);
hErr = plot(axErr,NaN,NaN,'b-','LineWidth',1.2); grid(axErr,'on');
xlabel(axErr,'Time [min]'); ylabel(axErr,'3-D error [m]');
title(axErr,'Position error of the least-squares fix');

% Animation timer (calls stepSim ~20 times per second)
tmr = timer('ExecutionMode','fixedSpacing','Period',0.05,'BusyMode','drop', ...
    'TimerFcn',@(~,~) stepSim());

computeAndDraw();   % draw the initial frame

%% ==================== 6. SIMULATION LOGIC (nested) ======================
    function stepSim()
        % Advance simulation time, move the user, then recompute/redraw.
        if ~isvalid(fig), return; end
        dt = 20*get(sldSpeed,'Value');               % simulated seconds per frame
        t  = t + dt;
        % --- user motion: constant speed, slowly turning heading
        heading = heading + 0.03;
        v  = get(sldUser,'Value')/1000;              % [km/s]
        lat = lat + v*dt*cos(heading)/Re;
        lon = lon + v*dt*sin(heading)/(Re*cos(lat));
        computeAndDraw();
    end

    function S = satECEF(tt)
        % Satellite positions (3xN, ECEF) from circular Kepler orbits.
        M  = M0 + nMot*tt;                           % Eq. 4: mean anomaly
        xo = aOrb*cos(M);  yo = aOrb*sin(M);         % in-plane coordinates
        xi = xo.*cos(RAAN) - yo.*cos(inc).*sin(RAAN);% rotate to ECI
        yi = xo.*sin(RAAN) + yo.*cos(inc).*cos(RAAN);
        zi = yo.*sin(inc);
        th = wE*tt;                                  % Eq. 5: Earth rotation
        S  = [ xi.*cos(th) + yi.*sin(th); ...
              -xi.*sin(th) + yi.*cos(th); zi ];
    end

    function [xhat,H] = solveFix(Sv,rho)
        % Iterative Gauss-Newton least squares (Eqs. 2-3).
        % Unknowns: x = [x y z c*dt]; start from Earth's centre.
        xhat = zeros(4,1);  m = size(Sv,2);
        for it = 1:10
            d    = Sv - xhat(1:3);                   % vectors receiver->sat
            r    = vecnorm(d,2,1)';                  % predicted geometric range
            H    = [-(d./r')' , ones(m,1)];          % rows [-e_i^T  1]
            dRho = rho - (r + xhat(4));              % measurement residual
            dx   = H\dRho;                           % LS solution
            xhat = xhat + dx;
            if norm(dx) < 1e-9, break; end
        end
    end

%% =================== 7. VISUALIZATION UPDATE (nested) ===================
    function computeAndDraw()
        S = satECEF(t);                              % satellites
        u = Re*[cos(lat)*cos(lon); cos(lat)*sin(lon); sin(lat)]; % true user

        % Visibility test via elevation angle
        los   = S - u;  rng = vecnorm(los,2,1);
        sinEl = (u/norm(u))'*los ./ rng;
        vis   = sinEl > sind(get(sldMask,'Value'));
        m     = nnz(vis);

        % Pseudorange generation (Eq. 1)
        sigma = get(sldNoise,'Value')/1000;          % m -> km
        bias  = get(sldBias,'Value')*1e-6*c;         % us -> km
        rho   = rng(vis)' + bias + sigma*randn(m,1);
        Sv    = S(:,vis);

        % Position fix
        if m >= 4
            [xhat,H] = solveFix(Sv,rho);
            gdop = sqrt(trace(inv(H'*H)));
            err  = norm(xhat(1:3)-u)*1000;           % [m]
            eLat = asind(xhat(3)/norm(xhat(1:3)));
            eLon = atan2d(xhat(2),xhat(1));
            set(hEst,'XData',xhat(1),'YData',xhat(2),'ZData',xhat(3));
            errT(end+1) = t/60;  errV(end+1) = err; %#ok<AGROW>
            errT = errT(max(1,end-499):end);  errV = errV(max(1,end-499):end);
            set(hErr,'XData',errT,'YData',errV);
            info = sprintf(['Time      : %8.1f min\n' ...
                'Visible   : %d / %d sats\n\n' ...
                'TRUE  lat : %9.4f deg\n      lon : %9.4f deg\n\n' ...
                'EST   lat : %9.4f deg\n      lon : %9.4f deg\n\n' ...
                '3-D error : %9.2f m\n' ...
                'Clock bias: %9.1f us (est)\n' ...
                'GDOP      : %9.2f\n'], t/60, m, nSat, rad2deg(lat), ...
                rad2deg(lon), eLat, eLon, err, xhat(4)/c*1e6, gdop);
        else
            set(hEst,'XData',NaN,'YData',NaN,'ZData',NaN);
            info = sprintf('Time: %.1f min\nVisible: %d sats\n\nNO FIX (need >= 4)', t/60, m);
        end
        set(txtInfo,'String',info);

        % Satellites, labels
        set(hSatVis,'XData',S(1,vis),'YData',S(2,vis),'ZData',S(3,vis));
        set(hSatHid,'XData',S(1,~vis),'YData',S(2,~vis),'ZData',S(3,~vis));
        for k = 1:nSat
            set(hLbl(k),'Position',S(:,k)'+[500 500 500],'Visible',onoff(vis(k)));
        end

        % Pseudorange lines: one NaN-separated polyline user->sat_1, user->sat_2 ...
        P = nan(3,3*m);
        P(:,1:3:end) = repmat(u,1,m);
        P(:,2:3:end) = Sv;
        set(hLines,'XData',P(1,:),'YData',P(2,:),'ZData',P(3,:));

        % User marker and path
        trail = [trail u];  trail = trail(:,max(1,end-399):end);
        set(hUser,'XData',u(1),'YData',u(2),'ZData',u(3));
        set(hTrail,'XData',trail(1,:),'YData',trail(2,:),'ZData',trail(3,:));
        drawnow limitrate;
    end

    function s = onoff(tf)
        if tf, s = 'on'; else, s = 'off'; end
    end

%% ============================ GUI CALLBACKS =============================
    function h = makeSlider(parent,y,name,mn,mx,val,fmt)
        % Creates: caption + live value readout + slider.
        uicontrol(parent,'Style','text','String',name,'Units','normalized', ...
            'Position',[0.05 y+0.032 0.62 0.03],'HorizontalAlignment','left');
        lbl = uicontrol(parent,'Style','text','String',sprintf(fmt,val), ...
            'Units','normalized','Position',[0.68 y+0.032 0.27 0.03], ...
            'HorizontalAlignment','right','FontWeight','bold');
        h = uicontrol(parent,'Style','slider','Min',mn,'Max',mx,'Value',val, ...
            'Units','normalized','Position',[0.05 y 0.90 0.03], ...
            'Callback',@(s,~) set(lbl,'String',sprintf(fmt,s.Value)));
    end

    function onStartStop(~,~)
        running = ~running;
        if running
            set(btnRun,'String','Pause');  start(tmr);
        else
            set(btnRun,'String','Start');  stop(tmr);
        end
    end

    function onReset(~,~)
        t = 0; lat = deg2rad(11.15); lon = deg2rad(106.60); heading = 0;
        trail = zeros(3,0); errT = []; errV = [];
        set(hErr,'XData',NaN,'YData',NaN);
        computeAndDraw();
    end

    function onClose(~,~)
        % Stop and delete the timer before closing to avoid orphan callbacks.
        try, stop(tmr); delete(tmr); catch, end
        delete(fig);
    end
end