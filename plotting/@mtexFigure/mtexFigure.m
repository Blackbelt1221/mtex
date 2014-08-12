classdef mtexFigure < handle
% class to handles figures with equaly sized axes  
%   
% features:
% * nicely resize axes
% * individual colorbar
% * global colorbars

  properties
    parent            % the parent figure    
    children          % the axes
    cBarAxis          % the colorbar axes
    outerPlotSpacing  % 
    innerPlotSpacing  %  
    keepAspectRatio   % 
    nrows = 1         % number of rows
    ncols = 1         % number of columns
    axisWidth         % width of an individual axis
    axisHeight        % height of an individual axis 
    cbx = 0           % colorbar width
    cby = 0           % colorbar height
    tightInset = [0,0,0,0] % is added to axisSize
  end
  
  properties (Dependent = true)        
    currentAxes       % current axis
    currentId         % current axis id
    axesWidth
    axesHeight
    currentAxis
  end
   
  methods    
    
    function mtexFig = mtexFigure(varargin)
      
      % clear figure and set it up
      clf('reset');
      rmallappdata(gcf);

      % set figure name
      if ~isempty(get_option(varargin,'FigureTitle'))
        set(gcf,'Name',get_option(varargin,'FigureTitle'));
      end
      
      % set custom resize function
      set(gcf,'ResizeFcn',@(src,evt) figResize(src,evt,mtexFig));

      mtexFig.parent = gcf;
                
      mtexFig.outerPlotSpacing = get_option(varargin,'outerPlotSpacing',...
        getMTEXpref('outerPlotSpacing'));
      mtexFig.innerPlotSpacing = get_option(varargin,'innerPlotSpacing',...
        getMTEXpref('innerPlotSpacing'));
      mtexFig.keepAspectRatio = get_option(varargin,'keepAspectRatio',true);
        
      set(mtexFig.parent,'color',[1 1 1],'nextPlot','replace');
      setappdata(mtexFig.parent,'mtexFig',mtexFig);
      
      varargin = delete_option(varargin,'color',1);
      optiondraw(mtexFig.parent,varargin{:});              

      % set data cursor
      if check_option(varargin,'datacursormode')
        dcm_obj = datacursormode(mtexFig.parent);
        set(dcm_obj,'SnapToDataVertex','off')
        set(dcm_obj,'UpdateFcn',{get_option(varargin,'datacursormode')});
        datacursormode on;      
      end
      
      set(mtexFig.parent,'DefaultAxesCreateFcn',...
        @updateChildren);
      set(mtexFig.parent,'DefaultAxesDeleteFcn',...
        @deleteChildren);
      
      MTEXFigureMenu(mtexFig,varargin{:});
      
      function updateChildren(a,b)
        
        % prevent that this is called by colorbar
        x = dbstack; 
        if strcmpi(x(2).name,'colorbar'), return;end
        
        mtexFig.children = ...
        flipud(findobj(mtexFig.parent,'type','axes','-not','tag','Colorbar')); 
      end
      
      function deleteChildren(a,b)
        mtexFig.children(mtexFig.children==a) = [];
      end
      
    end
    
    
    
    function ax = gca(mtexFig)
      % return current axis if exist otherwise create a new one
      
      if mtexFig.currentId == 0, mtexFig.currentId = 1;end
      
      ax = mtexFig.currentAxes;
      
    end
    
    
    % ---------------------------------------------------------
            
    function ax = get.currentAxes(mtexFig)
      ax = get(mtexFig.parent,'CurrentAxes');
    end
    
    function set.currentAxes(mtexFig,ax)
      set(mtexFig.parent,'CurrentAxes',ax);
    end
    
    
    function id = get.currentId(mtexFig)
      if isempty(mtexFig.currentAxes)
        id = 0;
      else
        id = find(mtexFig.currentAxes == mtexFig.children);
      end
    end
    
    function set.currentId(mtexFig,id)
      
      if id > numel(mtexFig.children) % create a nex axes
        axes('visible','off','parent',mtexFig.parent);
        set(mtexFig.parent,'nextplot','add');
  
        if numel(mtexFig.children) > mtexFig.ncols * mtexFig.nrows
          mtexFig.ncols = ceil(numel(mtexFig.children) / mtexFig.nrows);
        end
        
      else
        set(mtexFig.parent,'CurrentAxes',mtexFig.children(id));
      end      
    end
    
    
    function aw = get.axesWidth(mtexFig)
      % the width of all axes is the number of columns times the width of
      % each single axis + inner and outer spacing
      
      aw = mtexFig.ncols * (mtexFig.axisWidth + sum(mtexFig.tightInset([1,3])))...
        + 2*mtexFig.outerPlotSpacing + ...
        (mtexFig.ncols-1) * mtexFig.innerPlotSpacing;
    end
    
    function ah = get.axesHeight(mtexFig)
      % the height of all axes is the number of rows times the height of
      % each single axis + inner and outer spacing
      
      ah = mtexFig.nrows * (mtexFig.axisHeight +  + sum(mtexFig.tightInset([2,4])))...
        + 2*mtexFig.outerPlotSpacing + ...
        (mtexFig.nrows-1) * mtexFig.innerPlotSpacing;
    end

    function setCamera(mtexFig,varargin)
      
      for a = 1:numel(mtexFig.children)
        setCamera(mtexFig.children(a),varargin{:});        
      end
      mtexFig.drawNow;
    end
    
  end
end
