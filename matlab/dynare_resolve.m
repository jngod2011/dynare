function [A,B,ys,info] = dynare_resolve(iv,ic,aux)

% function [A,B,ys,info] = dynare_resolve(iv,ic,aux)
% Computes the linear approximation and the matrices A and B of the
% transition equation
%
% INPUTS
%    iv:             selected variables (observed and state variables)
%    ic:             state variables position in the transition matrix columns
%    aux:            indices for auxiliary equations
%
% OUTPUTS
%    A:              matrix of predetermined variables effects in linear solution (ghx)
%    B:              matrix of shocks effects in linear solution (ghu)
%    ys:             steady state of original endogenous variables
%    info=1:         the model doesn't determine the current variables '...' uniquely
%    info=2:         MJDGGES returns the following error code'
%    info=3:         Blanchard Kahn conditions are not satisfied: no stable '...' equilibrium
%    info=4:         Blanchard Kahn conditions are not satisfied:'...' indeterminacy
%    info=5:         Blanchard Kahn conditions are not satisfied:'...' indeterminacy due to rank failure
%    info=20:        can't find steady state info(2) contains sum of sqare residuals
%    info=30:        variance can't be computed
%
% SPECIAL REQUIREMENTS
%    none

% Copyright (C) 2003-2007 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

  global oo_ M_
  
  [oo_.dr,info] = resol(oo_.steady_state,0);

  if info(1) > 0
    A = [];
    B = [];
    ys = [];
    return
  end
  
  if nargin == 0
    endo_nbr = M_.endo_nbr;
    nstatic = oo_.dr.nstatic;
    npred = oo_.dr.npred;
    iv = (1:endo_nbr)';
    ic = [ nstatic+(1:npred) endo_nbr+(1:size(oo_.dr.ghx,2)-npred) ]';
    aux = oo_.dr.transition_auxiliary_variables;
    k = find(aux(:,2) > npred);
    aux(:,2) = aux(:,2) + nstatic;
    aux(k,2) = aux(k,2) + oo_.dr.nfwrd;
  end
  
  [A,B] = kalman_transition_matrix(oo_.dr,iv,ic,aux,M_.exo_nbr);
  ys = oo_.dr.ys;