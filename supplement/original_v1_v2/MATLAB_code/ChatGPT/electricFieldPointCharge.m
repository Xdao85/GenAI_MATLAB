function E = electricFieldPointCharge(P, q, r_charge, k)
% electricFieldPointCharge
%
% Calculates the electric field vector at point P due to
% a single point charge using Coulomb's law.
%
% INPUTS:
%   P         - Observation point [x, y, z] in meters
%   q         - Point charge in Coulombs
%   r_charge  - Position of point charge [x, y, z] in meters
%   k         - Coulomb's constant [N*m^2/C^2]
%
% OUTPUT:
%   E         - Electric field vector [Ex, Ey, Ez] in N/C
%
% Mathematical formulation:
%
%   R = P - r_charge
%
%   r = |R|
%
%   E = k*q/r^3 * R
%
% This formulation automatically determines the direction of
% the electric field:
%   q > 0 --> field points away from the charge
%   q < 0 --> field points toward the charge

    %% Vector from charge to observation point
    R = P - r_charge;

    %% Distance from charge to observation point
    r = norm(R);

    %% Check for singularity
    % The electric field is undefined at the position of the charge.
    if r == 0
        error('Observation point P cannot be located at the charge position.');
    end

    %% Coulomb's law
    E = k * q / r^3 * R;

end