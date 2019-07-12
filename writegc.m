function writegc(fileID, cuts, tabs, depth, offset_x, offset_y, scale_x, scale_y)
    %WRITEGC  Write the g-code to file
    %   writegc(fileID, cuts, tabs, depth, offset_x, offset_y, scale_x, scale_y)
    %
    %   For more info, see https://en.wikipedia.org/wiki/G-code
    
    feed_xy = 30;
    feed_z = 2;
    tabLength = 8;
    tabInterval = 50;
    
    for cut = 1:size(cuts,2)
        fprintf(fileID, "G1 Z0.10 F%f\n", feed_z); % Elevate .1 inches
        fprintf(fileID, "G1 X%f Y%f F%f\n", cuts{cut}(1,1)*scale_x+offset_x, cuts{cut}(2,1)*scale_y+offset_y, feed_xy);
        fprintf(fileID, "G1 Z%f F%f\n", depth, feed_z); % Drop to target depth
        tab = 0;
        
        for i = 1:size(cuts{cut}(1,:),2)
            fprintf(fileID, "G1 X%f Y%f F%f\n", cuts{cut}(1,i)*scale_x+offset_x, cuts{cut}(2,i)*scale_y+offset_y, feed_xy);
            if tabs == 1
                
                tab = tab + 1;
                if tab == tabInterval
                    fprintf(fileID, "G1 Z0 F%f\n", feed_z); % Raise to 0 inches
                end
                
                if tab == (tabInterval + tabLength)
                    fprintf(fileID, "G1 Z%f F%f\n", depth, feed_z); % Drop to {depth} inches
                    tab = 0;
                end
                
            end
        end
    end
end

