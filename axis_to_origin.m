%% Give a 3D plot axes that pass through the origin.
%
% ARGUMENTS:
%     FigureHandle -- Handle to figure window containing the plot.
%     AxisHandle   -- Handle to the 3D plot to be acted upon.
%     AxisLabels   -- Cell of strings specifying axis labels,
%                     defaults to existing labels.
%
% OUTPUT:
%     FigureHandle -- Handle to figure window containing the plot.
%     AxisHandle   -- Handle to the 3D plot that was acted upon.
%
% AUTHOR:
%     Michael Robbins (pre-2010) - original name Plot3AxisAtOrigin().
%     Stuart A. Knock (2010-03-26).
%
% USAGE:
%{
    figure, scatter3(randn(1,42),randn(1,42),randn(1,42),'.')
    [FigureHandle AxisHandle] = axis_to_origin;
    %OR
    FigureHandle = figure;
    subplot(2,2,[1 3])
    AxisHandle = subplot(2,2,2);
    scatter3(randn(1,42),randn(1,42),randn(1,42),'.')
    subplot(2,2,4)
    axis_to_origin(FigureHandle, AxisHandle, {'Larry','Mo','Curly'});
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
function [FigureHandle, AxisHandle] = axis_to_origin(FigureHandle, AxisHandle, AxisLabels)
    %% Set defaults for any argument that weren't specified
    if nargin<1 || isempty(FigureHandle)
        FigureHandle = gcf;
    end
    if nargin<2 || isempty(AxisHandle)
        AxisHandle = gca;
    end
    if nargin<3 || isempty(AxisHandle)
        % AxisLabels = {'{\bf X}','{\bf Y}','{\bf Z}'};
        AxisLabels = {['{\bf ' AxisHandle.XLabel.String '}'], ...
                      ['{\bf ' AxisHandle.YLabel.String '}'], ...
                      ['{\bf ' AxisHandle.ZLabel.String '}']};
    end

    %
    figure(FigureHandle);
    axes(AxisHandle);

    InitialHoldState = ishold;

    hold on
    axis off

    %% GET AXIS LIMITS
    Limits = [get(AxisHandle,'XLim') ; get(AxisHandle,'YLim') ; get(AxisHandle,'ZLim')];
    Limits(:,1) = min(Limits(:,1), 0);
    Limits(:,2) = max(Limits(:,2), 0);
    dL = diff(Limits.');

    %% DRAW AXIS LINEs
    plot3(Limits(1,:), [0 0],   [0 0],   'Color', AxisHandle.XColor);
    plot3([0 0],   Limits(2,:), [0 0],   'Color', AxisHandle.YColor);
    plot3([0 0],   [0 0],   Limits(3,:), 'Color', AxisHandle.ZColor);
    axis tight
%%%keyboard
    CurrentDAR = daspect;
    TickLength = mean(dL(CurrentDAR==1))./84;

    %% GET TICKS
    X = get(AxisHandle,'Xtick');
    Y = get(AxisHandle,'Ytick');
    Z = get(AxisHandle,'Ztick');
    zX = zeros(size(X));
    zY = zeros(size(Y));
    zZ = zeros(size(Z));
    oX = ones(size(X));
    oY = ones(size(Y));
    oZ = ones(size(Z));

    %% GET LABELS
    XL = get(AxisHandle,'XtickLabel');
    YL = get(AxisHandle,'YtickLabel');
    ZL = get(AxisHandle,'ZtickLabel');

    iX = find(X~=0,1);
    iY = find(Y~=0,1);
    iZ = find(Z~=0,1);
    XLscaling = log10(X(iX) ./ str2double(XL(iX,:)));
    YLscaling = log10(Y(iY) ./ str2double(YL(iY,:)));
    ZLscaling = log10(Z(iZ) ./ str2double(ZL(iZ,:)));

    %% SET OFFSETS
    Xoff = TickLength.*CurrentDAR(1); %(xLimits(2)-xLimits(1))./(42);
    Yoff = TickLength.*CurrentDAR(2); %(yLimits(2)-yLimits(1))./(42);
    Zoff = TickLength.*CurrentDAR(3); %(zLimits(2)-zLimits(1))./(42);

    %% DRAW TICKS
    plot3([X ; X],           [-Yoff ; Yoff]*oX, [zX ; zX],         'Color', AxisHandle.XColor);
    plot3([X ; X],           [zX ; zX],         [-Zoff ; Zoff]*oX, 'Color', AxisHandle.XColor);

    plot3([-Xoff ; Xoff]*oY, [Y ; Y],           [zY ; zY],         'Color', AxisHandle.YColor);
    plot3([zY ; zY],         [Y ; Y],           [-Zoff ; Zoff]*oY, 'Color', AxisHandle.YColor);

    plot3([-Xoff ; Xoff]*oZ, [zZ ; zZ],         [Z ; Z],           'Color', AxisHandle.ZColor);
    plot3([zZ ; zZ],         [-Yoff ; Yoff]*oZ, [Z ; Z],           'Color', AxisHandle.ZColor);

    %% DRAW LABELS
    text(X,            zX, -3.*Zoff.*oX, XL, 'HorizontalAlignment', 'Center');
    text(-3.*Xoff.*oY, Y,  zY,           YL, 'HorizontalAlignment', 'Center');
    text(-3.*Xoff.*oZ, zZ, Z,            ZL, 'HorizontalAlignment', 'Center');

    if XLscaling
        text(Limits(1,2)+3*Xoff, 0, 0, [AxisLabels{1} ' (\times10^{' num2str(XLscaling) '})'], 'HorizontalAlignment', 'Center')
    else
        text(Limits(1,2)+3*Xoff, 0, 0, AxisLabels{1}, 'HorizontalAlignment', 'Center')
    end

    if YLscaling
        text(0, Limits(2,2)+3*Yoff, 0, [AxisLabels{2} ' (\times10^{' num2str(YLscaling) '})'], 'HorizontalAlignment', 'Center')
    else
        text(0, Limits(2,2)+3*Yoff, 0, AxisLabels{2}, 'HorizontalAlignment', 'Center')
    end

    if ZLscaling
        text(0, 0, Limits(3,2)+3*Zoff, [AxisLabels{3} ' (\times10^{' num2str(ZLscaling) '})'], 'HorizontalAlignment', 'Center')
    else
        text(0, 0, Limits(3,2)+3*Zoff, AxisLabels{3}, 'HorizontalAlignment', 'Center')
    end

    %% RESET HOLD STATE
    if ~InitialHoldState
        hold off
    end

end %function axis_to_origin()
