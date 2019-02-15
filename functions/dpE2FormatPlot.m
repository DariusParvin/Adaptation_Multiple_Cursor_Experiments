% Apply some common formatting to figures:
% Set axes
% Shade no feedback trials
% Draw reference lines
function dpE2FormatPlot(figType)

hold on;
if strcmp(figType,'trials')
    
    axis([0.5 382 -30 90])
    
    % plot no feedback trials as shaded
    no_fb_base =patch([0.5 39.5 39.5 0.5],[min(ylim) min(ylim) max(ylim) max(ylim)],zeros(1,4));
    set(no_fb_base,'facecolor',.1*[1 1 1]); set(no_fb_base,'edgecolor',.7*[1 1 1]);
    no_fb_post =patch([304.5 343.5 343.5 304.5],[min(ylim) min(ylim) max(ylim) max(ylim)],zeros(1,4));
    set(no_fb_post,'facecolor',.1*[1 1 1]); set(no_fb_post,'edgecolor',.7*[1 1 1]);
    alpha(.05)
    
    % draw reference lines
    l = [39.5 104.5 304.5 343.5];
    drawline(l, 'dir', 'vert','linewidth',0.1);
    drawline([0], 'dir', 'horz','linewidth',0.1);
    
    
    
elseif strcmp(figType,'blocks')    
    
    axis([0.5 54 -5 50])
    
    % Shade the no feedback trials
    no_fb_base =patch([0.5 3.5 3.5 0.5],[min(ylim) min(ylim) max(ylim) max(ylim)],zeros(1,4));
    set(no_fb_base,'facecolor',.1*[1 1 1]); set(no_fb_base,'edgecolor',.7*[1 1 1]);
    no_fb_post =patch([48.5 51.5 51.5 48.5],[min(ylim) min(ylim) max(ylim) max(ylim)],zeros(1,4));
    set(no_fb_post,'facecolor',.1*[1 1 1]); set(no_fb_post,'edgecolor',.7*[1 1 1]);
    alpha(.05)
    
    % draw reference lines
%     l = [1.5 11.5 91.5 92.5];
    l = [3.5 8.5 48.5 51.5];
    drawline(l, 'dir', 'vert','linewidth',0.1);
    drawline([0], 'dir', 'horz','linewidth',0.1); 
end