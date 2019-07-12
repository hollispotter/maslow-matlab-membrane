% Generate g-code to produce a 3D L-shaped membrane!
% Designed, coded, cut, sanded, and stained by Hollis Potter https://github.com/hollispotter

% Inspired from:
% https://blogs.mathworks.com/community/2013/06/20/paul-prints-the-l-shaped-membrane/

% G-code references:
% https://github.com/MaslowCNC/GroundControl/wiki/G-Code-and-MaslowCNC
% https://www.instructables.com/id/Typography-for-CNC-Machines-Text-to-Gcode-Function/
% https://nraynaud.github.io/webgcode/
% https://en.wikipedia.org/wiki/G-code
% https://ncviewer.com/

% Further improvements might include:
% - Make single file output an option. Still want to break it into smaller
% chunks though
% - Optimize material use through shape rotation / offsets
%   - It'd be great to automate the positioning of each shape

n = 100; % number of partitions in each dimension.
X = linspace(0,1,2*n+1);
Y = X;
Z = membrane(1,n);

final_w = 18; % Membrane size in inches
final_h = 18;
use_offsets = 1; % 0: Place all layers at 0x0, 1: arrange on 4x8'
frame = 0;

% Get a contour map at 15 levels. It turns out this is easier and more
% accurate than generating a dense matrix, taking a slice, and running a
% boundary algorithm against it. Or so I have heard *ahem*
M = contour(X,Y,Z,15);

% Convert contour map to XYZ vectors
[Xa, Ya, Za] = contourLevels(M);

% Map offsets to a sheet of plywood, beginning at -42" (6" from the edge)
offsets = [];
for x = -42:18:30
    if use_offsets
        offsets = [offsets, [x x; 0 -18]]; % Arrange on a 4x8 sheet
    else
        offsets = [offsets, [0 0; 0 0]]; % Plot from 0x0
    end
end

if use_offsets
    offsets = [offsets, [3 18 24; -9 -9 -9]]; % Smaller pieces are manually placed between the larger
else
    offsets = [offsets, [0 0 0; 0 0 0]]; % Plot from 0x0
end

k = 5;
while k <= length(Za)
    h = figure(k);
    xlim([0 1]);
    ylim([0 1]);
    % axis off;
    hold on;
    plot(Xa{k}, Ya{k});
    
    cuts = {};
    drills = {};
    cleanupLines = {};
    cleanupLinesTabs = {};
    
    % Central drill point
    drills = [drills, {[.66;.34]}];
    scatter(.66,.34);
    
    cuts = [cuts, {[Xa{k};Ya{k}]}];
    oldZ = Za(k);
    k = k + 1;
    
    if k <= length(Za)
        while Za(k) == oldZ
            % NOTE: These are separate cuts
            plot(Xa{k}, Ya{k});
            cuts = [cuts, {[Xa{k};Ya{k}]}];
            k = k + 1;
        end
    end
    
    % Square outline cut for the partial contours
    if size(cuts,2) >= 3
        % Cut a full square
        cleanupLines = [cleanupLines, {[0 1 1 0 0; 0 0 1 1 0]}];
        
        % Generate box lines with evenly spaced extra large supporting tabs
        tabCount = 1/4;
        tabWidth = .03;
        
        for x = 0:tabCount:1-tabCount
            cleanupLinesTabs = [cleanupLinesTabs, {[x x+tabCount-tabWidth; 0 0]}];
        end
        for y = 0:tabCount:1-tabCount
            cleanupLinesTabs = [cleanupLinesTabs, {[1 1; y y+tabCount-tabWidth]}];
        end
        for x = 1-tabCount:-tabCount:0
            cleanupLinesTabs = [cleanupLinesTabs, {[x x+tabCount-tabWidth; 1 1]}];
        end
        for y = 1-tabCount:-tabCount:0
            cleanupLinesTabs = [cleanupLinesTabs, {[0 0; y y+tabCount-tabWidth]}];
        end
    end
    
    hold off;
    
    frame = frame + 1;
    
    fileID = fopen(sprintf('level-%d.nc',frame),'w');
    
    fprintf(fileID, "G20\n"); % Set to inches
    fprintf(fileID, "G1 Z0.10 F30\n"); % Elevate router to .1 inches
    
    % Drill the bolt hole we'll use to tension levels together
    if frame < 13
        writegc(fileID, drills, 1, -0.60, offsets(1,frame), offsets(2,frame), final_h, final_w);
    else
        % On the top, leave a solid surface to conceal the threaded rod
        writegc(fileID, drills, 1, -0.40, offsets(1,frame), offsets(2,frame), final_h, final_w);
    end
    
    % Make 4 passes through 1/2" material
    % writegc will automatically add tabs
    writegc(fileID, cuts, 0, -0.15, offsets(1,frame), offsets(2,frame), final_h, final_w);
    writegc(fileID, cuts, 0, -0.30, offsets(1,frame), offsets(2,frame), final_h, final_w);
    writegc(fileID, cuts, 0, -0.45, offsets(1,frame), offsets(2,frame), final_h, final_w);
    writegc(fileID, cuts, 1, -0.60, offsets(1,frame), offsets(2,frame), final_h, final_w);
    
    % Cut edges for truncated contours
    if size(cleanupLines, 2) > 0
        writegc(fileID, cleanupLines, 0, -0.15, offsets(1,frame), offsets(2,frame), final_h, final_w);
        writegc(fileID, cleanupLines, 0, -0.30, offsets(1,frame), offsets(2,frame), final_h, final_w);
        writegc(fileID, cleanupLines, 0, -0.45, offsets(1,frame), offsets(2,frame), final_h, final_w);
        % Since the vectors are simpler, provide one with manual tabs
        writegc(fileID, cleanupLinesTabs, 0, -0.60, offsets(1,frame), offsets(2,frame), final_h, final_w);
    end
    
    fprintf(fileID, "G1 Z0.10 F30\n"); % Raise to .1 inches
    
    fclose(fileID); 
    
end
