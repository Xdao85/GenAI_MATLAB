% reference_q2_finite_wire.m
% Reference solution for case-study task Q2: magnetic flux density of a finite
% straight conductor parallel to z, with the three-level verification (V1-V3).
% Parameters: I = 1 A, l = 2 m, A = (0.25, 0.5, 0) m, P = (1, 1, 0) m.
% The phrase "carries a current at A" is ambiguous, so both geometries are computed:
%   centered at A  (z from -l/2 to l/2): |B| = 1.6481e-7 T, B = (-9.1419e-8, 1.3713e-7, 0) T
%   starting at A  (z from 0 to l)     : |B| = 1.0114e-7 T, B = (-5.6104e-8, 8.4156e-8, 0) T

clear; clc;
mu0 = 4*pi*1e-7;  I = 1;  L = 2;
A = [0.25 0.5 0];  P = [1 1 0];
cases = {'centered at A', [A(3)-L/2, A(3)+L/2]; 'starting at A', [A(3), A(3)+L]};
tol = 1e-3;                                    % V2 tolerance (0.1 %)

for c = 1:size(cases, 1)
    z = cases{c, 2};
    Ba = finiteWireAnalytical(mu0, I, A, z, P);    % closed form
    Bn = finiteWireNumerical(mu0, I, A, z, P);     % Biot-Savart integration
    rel = norm(Ba - Bn) / norm(Ba);
    fprintf('\n--- Conductor %s ---\n', cases{c, 1});
    fprintf('Analytical B = [%.4e %.4e %.4e] T, |B| = %.4e T\n', Ba, norm(Ba));
    fprintf('Numerical  B = [%.4e %.4e %.4e] T, |B| = %.4e T\n', Bn, norm(Bn));
    fprintf('V2: relative difference = %.2e\n', rel);
    assert(rel < tol, 'V2 failed: analytical and numerical solutions disagree.');
    % V3: B must be along a_phi = a_z x a_rho (right-hand rule) and perpendicular to the wire
    rho = [P(1)-A(1), P(2)-A(2), 0];
    aphi = cross([0 0 1], rho / norm(rho));
    fprintf('V3: B . a_phi / |B| = %.4f (must be +1), B_z = %.1e\n', dot(Ba, aphi)/norm(Ba), Ba(3));
    assert(dot(Ba, aphi) > 0, 'V3 failed: field direction violates the right-hand rule.');
end

function B = finiteWireAnalytical(mu0, I, A, z, P)
% B_phi = mu0 I (cos a1 - cos a2) / (4 pi rho), direction a_phi
    rho = [P(1)-A(1), P(2)-A(2), 0];  r = norm(rho);
    c1 = (P(3)-z(1)) / hypot(r, P(3)-z(1));
    c2 = (P(3)-z(2)) / hypot(r, P(3)-z(2));
    Bphi = mu0*I/(4*pi*r) * (c1 - c2);
    B = Bphi * cross([0 0 1], rho / r);
end

function B = finiteWireNumerical(mu0, I, A, z, P)
% dB = mu0 I / (4 pi) * dl x R / |R|^3, integrated along the wire
    N = 20000;  zs = linspace(z(1), z(2), N+1);  zm = (zs(1:end-1) + zs(2:end)) / 2;
    dz = diff(zs);  B = [0 0 0];
    for n = 1:N
        R  = P - [A(1), A(2), zm(n)];
        dl = [0 0 dz(n)];
        B  = B + mu0*I/(4*pi) * cross(dl, R) / norm(R)^3;
    end
end
