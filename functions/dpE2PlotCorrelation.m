% Apply some common formatting to figures:
% Set axes
% Shade no feedback trials
% Draw reference lines
function dpE2PlotCorrelation(x, y, col)

scatter(x, y , 500, '.', col);
    

% Plot line of best fit for Relevant
coeffs = polyfit(x, y, 1);
% Get fitted values
fittedX = linspace(min(x), max(x), 200);
fittedY = polyval(coeffs, fittedX);
% Plot the fitted line
hold on;
plot(fittedX, fittedY, '-', 'color', col, 'LineWidth', 3);



end