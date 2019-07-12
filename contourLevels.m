function [x,y,z] = contourLevels(C)
    %contourLevels  Return cell arrays of the levels in a contour matrix
    %   [x,y,z] = contourLevels(C)
    %   x and y are cell arrays of the coordinates for each contour curve
    %   z is a vector of the height of each curve
    %
    %   Example
    %
    %   L = membrane(12,50);
    %   surf(L)
    %   shading flat
    %   light
    %   c = contourc(L,15);
    %   [x,y,z] = contourLevels(c);
    %   for i = 1:numel(x)
    %       line(x{i},y{i},z(i)*ones(size(x{i})), ...
    %           'Color','black')
    %   end
    
    index = 1;
    
    x = {};
    y = {};
    z = [];
    
    while index < size(C,2)
        
        % index points to the initial column number of the current contour segment
        % For more information, read about the ContourMatrix on this page
        %   https://www.mathworks.com/help/matlab/ref/matlab.graphics.chart.primitive.contour-properties.html
        
        % Row 1 gives the contour segment level
        z(end+1) = C(1,index);
        % Row 2 gives the number of vertices in this contour segment
        nVerticesInSegment = C(2,index);
        
        % Scoop up the x and y data for this contour segment
        x{end+1} = C(1,index+(1:nVerticesInSegment));
        y{end+1} = C(2,index+(1:nVerticesInSegment));
        
        % Move the index forward to the beginning of the next contour segment
        index = index + nVerticesInSegment + 1;
        
    end
    
end
