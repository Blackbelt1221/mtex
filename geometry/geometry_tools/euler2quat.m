function q = euler2quat(alpha,beta,gamma,varargin)
% converts euler angle to quaternion
%
%% Description
% The method *euler2quat* defines a [[quaternion_index.html,rotation]]
% by Euler angles. You can choose whether to use the Bunge (phi,psi,phi2) 
% convention or the Matthies (alpha,beta,gamma) convention.
%
%% Syntax
%
%  q = euler2quat(alpha,beta,gamma) -
%  q = euler2quat(phi1,Phi,phi2,'Bunge') -
%
%% Input
%  alpha, beta, gamma - double
%  phi1, Phi, phi2    - double
%
%% Output
%  q - @quaternion
%
%% Options
%  ABG, ZYZ   - Matthies (alpha, beta, gamma) convention (default)
%  BUNGE, ZXZ - Bunge (phi1,Phi,phi2) convention 
%
%% See also
% quaternion_index quaternion/quaternion axis2quat Miller2quat 
% vec42quat hr2quat idquaternion 


%% transform to right convention

conventions = {'nfft','ZYZ','ABG','Matthies','Roe','Kocks','Bunge','ZXZ','Canova'};
convention = get_flag(varargin,conventions,get_mtex_option('EulerAngleConvention'));

switch lower(convention)
  
  case {'matthies','nfft','zyz','abg'}

  case 'roe'
    
  case {'bunge','zxz'}  % Bunge -> Matthies

    alpha = alpha - pi/2;
    gamma = gamma - 3*pi/2;
      
  case {'kocks'}        % Kocks -> Matthies

    gamma = pi - gamma;
        
  case {'canova'}       % Canova -> Matthies
    
    alpha = pi/2 - alpha;
    gamma = 3*pi/2 - gamma;
        
end


%% construct quaternion

qalpha = quaternion(cos(alpha/2),0,0,sin(alpha/2));
qbeta  = quaternion(cos(beta/2),0,sin(beta/2),0);
qgamma = quaternion(cos(gamma/2),0,0,sin(gamma/2));

q = qalpha .* qbeta .* qgamma;

