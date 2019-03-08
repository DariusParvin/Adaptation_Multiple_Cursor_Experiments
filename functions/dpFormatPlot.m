% Apply some common formatting to figures:
% Set axes
% Shade no feedback trials
% Draw reference lines
function dpFormatPlot(figType)
hold on;

if strcmp(figType,'trials')
    
    axis([0 600 -30 70])
    
    % plot no feedback trials as shaded
    no_fb_base =patch([0.5 24.5 24.5 0.5],[min(ylim) min(ylim) max(ylim) max(ylim)],zeros(1,4));
    set(no_fb_base,'facecolor',.2*[1 1 1]); set(no_fb_base,'edgecolor','none');
    no_fb_post =patch([504.5 528.5 528.5 504.5],[min(ylim) min(ylim) max(ylim) max(ylim)],zeros(1,4));
    set(no_fb_post,'facecolor',.2*[1 1 1]); set(no_fb_post,'edgecolor','none');
    alpha(.05)
    
    % draw reference lines
    l = [24.5 264.5 504.5 528.5 600.5];
    drawline1(l, 'dir', 'vert','linewidth',0.1);
    drawline1([0], 'dir', 'horz','linewidth',0.1);
    
    xlabel('Trial number') % x-axis label
    ylabel('Hand angle (deg)') % y-axis label
    
elseif strcmp(figType,'blocks')
    
    axis([0.5 96 -5 50])
    
    % Shade the no feedback trials
    no_fb_base =patch([0.5 1.5 1.5 0.5],[min(ylim) min(ylim) max(ylim) max(ylim)],zeros(1,4));
    set(no_fb_base,'facecolor',.2*[1 1 1]); set(no_fb_base,'edgecolor','none');
    no_fb_post =patch([91.5 92.5 92.5 91.5],[min(ylim) min(ylim) max(ylim) max(ylim)],zeros(1,4));
    set(no_fb_post,'facecolor',.2*[1 1 1]); set(no_fb_post,'edgecolor','none');
    alpha(.1)
    
    % draw reference lines
    %     l = [1.5 11.5 91.5 92.5];
    l = [11.5];
    drawline1(l, 'dir', 'vert','linewidth',0.5);
    drawline1([0], 'dir', 'horz','linewidth',0.5);
    
    % ideal performance
%     plot([l 91.5],[45 45],'k','linewidth',1,'linestyle',':');
    plot([l 91.5],[45 45],'k','linewidth',0.5);
    
    % label blocks
%     text(2.5,35,'Baseline','FontSize',7,'Rotation',90);
%     text(13.5,35,'Training','FontSize',7,'Rotation',90);
%     text(93.5,35,'Aftereffect','FontSize',7,'Rotation',90);
    
    xlabel('Cycle number') % x-axis label
    ylabel('Hand angle (deg)') % y-axis label
end