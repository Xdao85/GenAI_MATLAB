% ---- Field on a grid in the y-z plane (x = Px) ----
[Yg, Zg] = meshgrid(linspace(-0.8,0.8,25), linspace(z1-0.5, z2+0.5, 25));
U = zeros(size(Yg)); V = zeros(size(Zg)); M = zeros(size(Yg));

for i = 1:numel(Yg)
    px = P(1); py = Yg(i); pz = Zg(i);
    rho_g = sqrt((px-A(1))^2 + (py-A(2))^2);
    if rho_g < 1e-6, continue; end
    r1g = sqrt(rho_g^2 + (z1-pz)^2);
    r2g = sqrt(rho_g^2 + (z2-pz)^2);
    Bxg = -k*(py-A(2))/rho_g^2 * ((z2-pz)/r2g - (z1-pz)/r1g);
    Byg =  k*(px-A(1))/rho_g^2 * ((z2-pz)/r2g - (z1-pz)/r1g);
    U(i) = Byg;  V(i) = Bxg;  M(i) = hypot(Bxg,Byg);
end

figure('Color','w'); hold on; axis equal;
pcolor(Yg, Zg, log10(M+eps)); shading interp;
colormap(jet); colorbar;
quiver(Yg, Zg, U, V, 'k');
plot(A(2)*[1 1], [z1 z2], 'w-', 'LineWidth',4);
plot(P(2), P(3), 'ro', 'MarkerFaceColor','r');
xlabel('y (m)'); ylabel('z (m)');
title('log_{10}|B| and field direction in y-z plane');