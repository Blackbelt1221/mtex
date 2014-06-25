classdef sphericalRegion
  %sphericalRegion implements a region region on the sphere
  %   The region is bounded by small circles given by there normal vectors
  %   and the maximum inner product, i.e., all points v inside a region
  %   satisfy the conditions dot(v, N) <= alpha
  
  properties
    N = vector3d     % the nornal vectors of the bounding circles
    alpha = [] % the cosine of the bounding circle
    antipodal = false
  end
  
  
  
  methods
        
    function sR = sphericalRegion(varargin)
      %

      if check_option(varargin,'vertices')
        
        v = get_option(varargin,'vertices');
        
        sR.N = normalize(cross(v,v([2:end,1])));
        sR.alpha = zeros(size(sR.N));
        
      elseif nargin > 0 && nargin < 3 && isa(varargin{1},'vector3d')
        sR.N = varargin{1}.normalize;
        if nargin == 2
          sR.alpha = varargin{2};
        else
          sR.alpha = zeros(size(sR.N));
        end
        
      else
           
        maxTheta = get_option(varargin,'maxTheta',pi);
        if maxTheta < pi-1e-5
          sR.N = [sR.N,zvector];
          sR.alpha = [sR.alpha,cos(maxTheta)];
        end
        
        minTheta = get_option(varargin,'minTheta',0);
        if minTheta > 1e-5
          sR.N = [sR.N,-zvector];
          sR.alpha = [sR.alpha,cos(pi-minTheta)];
        end
        
        minRho = get_option(varargin,'minRho',0);
        maxRho = get_option(varargin,'maxRho',2*pi);
                
        if maxRho - minRho < 2*pi - 1e-5
          sR.N = [sR.N,sph2vec(90*degree,[90*degree+minRho,maxRho-90*degree])];
          sR.alpha = [sR.alpha,0,0];
        end        
      end      
    end
            
    function th = thetaMin(sR)
      
      th = thetaRange(sR);
      
    end
    
    function th = thetaMax(sR)
      
      [~,th] = thetaRange(sR);
      
    end
      
    function rh = rhoMax(sR)

      [~,rh] = rhoRange(sR);
      
    end
    
    function rh = rhoMin(sR)

      rh = rhoRange(sR);
      
    end
    
    function bounds = polarRange(sR)
      
      [thetaMin, thetaMax] = thetaRange(sR);
      [rhoMin, rhoMax] = rhoRange(sR);
      
      bounds = [thetaMin, rhoMin, thetaMax, rhoMax];
      
    end
    
    function [thetaMin, thetaMax] = thetaRange(sR,rho)
      
      if nargin == 2
        
        theta = linspace(0,pi,10000);
        
        [rho,theta] = meshgrid(rho,theta);
        
        v = sph2vec(theta,rho);
        
        ind = sR.checkInside(v);
        
        theta(~ind) = NaN;
        
        thetaMin = nanmin(theta);
        thetaMax = nanmax(theta);
   
      else
        
        % polar angle of the vertices
        th = sR.vertices.theta;
        
        if sR.checkInside(zvector)
          thetaMin = 0;
        elseif ~isempty(th)
          thetaMin = min(th);
        elseif ~isempty(sR.N)
          thetaMin = pi-max(acos(sR.alpha) + angle(sR.N,-zvector));
        else
          thetaMin = 0;
        end
        
        if sR.checkInside(-zvector)
          thetaMax = pi;
        elseif ~isempty(th)
          thetaMax = max(th);
        elseif ~isempty(sR.N)
          thetaMax = max(acos(sR.alpha) + angle(sR.N,zvector));
        else
          thetaMax = pi;
        end
        
      end
      
      
    end

    
    function rh = maxRho(sR)
    end
        
    
    function v = vertices(sR)
      % get the vertices of the fundamental region
      
      v = boundary(sR);
      
    end
    
    function e = edges(sR)
      
            
    end
    
    function [v,e] = boundary(sR)
      % compute vertices and eges of a spherical region
    
      [l,r] = find(triu(ones(length(sR.N)),1));
      
      v = planeIntersect(sR.N(l),sR.N(r),sR.alpha(l),sR.alpha(r));
      
      ind = sR.checkInside(v);
      l = [l(:),l(:)]; r = [r(:),r(:)];
      e = [reshape(l(ind),[],1),reshape(r(ind),[],1)];
      v(~ind) = [];
      
    end
    
    function alpha = innerAngle(sR)
      
      [~,e] = boundary(sR);
      alpha = pi-angle(sR.N(e(:,1)),sR.N(e(:,2)));
      
      
    end
    
    function c = center(sR)
      
      v = unique(sR.vertices);
      
      if length(sR.N) < 2
        
        c = sR.N;
        
      elseif length(v) < 3
        
        % find the pair of maximum angle
        w = angle_outer(sR.N,sR.N);
        [i,j] = find(w == max(w(:)),1);
        
        c = mean(sR.N([i,j]));
      
      elseif length(v) < 4
        
        c = mean(v);

      else
      
        v = equispacedS2Grid('resolution',1*degree);
        v = v(sR.checkInside(v));
      
        c = mean(v);
      
        if norm(c) < 1e-4
          c = zvector;
        else
          c = c.normalize;
        end
      end
    end
  end
end
