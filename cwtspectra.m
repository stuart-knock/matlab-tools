%% Calculates cwt power spectrum based on cwt prior to R2016b
%
%
% ARGUMENTS:
%     data          -- time series 1 x timepoints
%     fs            -- sampling frequency in Hz. 
%     freq_vec      -- frequency support for the cwt
%     wvl_fc        -- central frequency of the mother wavelet
%     wvl_fb        -- frequency bandwidth of the mother wavelet
%     
% REQUIRES:
%
%
% OUTPUT:
%     
%
% AUTHOR:
%     Kevin Aquino - 2005-2006
%     Paula Sanz-Leon - 2018
% USAGE:
%{

load kobe
[cwt_coeffs, time, f, av_pwr, norm_pwr, tw, fw] = cwtspectra(kobe, 1000);
    
%}
% NOTES: Tested with Matlab R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [cwt_coeffs, time, f, av_pwr, norm_pwr, tw, fw] = cwtspectra(data, fs, freq_vec, wvl_fc, wvl_fb, display_flag, scaling)

    if nargin < 2 || isempty(data) || isempty(fs)
        error(['PSL:', mfilename, ':BadArgs'], ...
            'you MUST at least provide a time series and a sampling frequency.');
    end

    if (nargin < 3)
        display_flag = true; 
        scaling  = 1; 
        freq_vec = linspace(fs/100, fs/10, 128);
        wvl_fc = 1;
        wvl_fb = 10; 
    end

    
    % Dummy time vector    
    time = (1:length(data))/fs;        
    
    % Frequency vector 
    if length(freq_vec) == 3
        f = linspace(freq_vec(1), freq_vec(2), freq_vec(3));
    else
        f = freq_vec;
    end
        
    %Establish the scales from the frequency using the frequency-scale relation
    %Using the Mallat method (Method in Najimi)      
    %scale - frequency relationship               
    scales = (fs./freq_vec)*wvl_fc;
    
    %reorder the scales so that it is in ascending order
    scales = scales(end:-1:1);              
    
    % Compose name of Morlet mother wavelet as per wavelet properties
    mother_wavelet = ['cmor',num2str(wvl_fb),'-',num2str(wvl_fc)];
    
    % This syntax calls the 'old' version of CWT --> wavelet.internal.cwt
    cwt_coeffs = cwt(data, scales, mother_wavelet);

    % Reverse the order of the coefficients
    cwt_coeffs = cwt_coeffs(end:-1:1,:);
    
    
    % Calculate average power
    av_pwr = sum(abs(cwt_coeffs).^2)/trapz(sum(abs(cwt_coeffs)).^2);
    scmtx  = repmat(scales(end:-1:1).',1,length(cwt_coeffs));
        
    % Normalized Spectral power --> from derivation of wavelet transform
    norm_pwr = abs(cwt_coeffs).^2./scmtx;
    
    %draw the images and the plots
    if display_flag
        figure_handle = figure;
        ax(1) = subplot(411);
        ax(2) = subplot(412);
        ax(3) = subplot(413);
        ax(4) = subplot(414);

        for this_ax = 1:length(ax)
            ax(this_ax).Box = 'on';
        end

        plot(ax(1), time, data, 'color', [0.7 0.7 0.7]); 
        ax(1).XLabel.String = ''; 
        ax(1).YLabel.String = 'Amplitude [a.u.]';
        ax(1).XLim = [time(1) time(end)];

        plot(ax(4), time, av_pwr, 'color', 'k'); 
        ax(4).XLabel.String = 'Time [s]'; 
        ax(4).YLabel.String = 'Normalised Power [a.u.]';
        ax(4).XLim = [time(1) time(end)];

        imagesc(ax(2), time, f, norm_pwr/scaling); 
        ax(2).YDir = 'normal';
        ax(2).XLabel.String = ''; 
        ax(2).YLabel.String = 'Frequency [Hz] ';
        ax(2).Colormap = yellowgreenblue(256, 'rev');
        
        hold(ax(2), 'on')
        contour(ax(2), time, f,norm_pwr/scaling, 'LineStyle','none',...
                                                 'LineColor',[0 0 0],...
                                                 'Fill','on')
        
        imagesc(ax(3), time, f, log10(norm_pwr/scaling)); 
        ax(3).YDir = 'normal';
        ax(3).XLabel.String = ''; 
        ax(3).YLabel.String = 'Frequency [Hz] ';
        ax(3).Colormap = yellowgreenblue(256, 'rev');
        
        hold(ax(3), 'on')
        contour(ax(3), time, f, log10(norm_pwr/scaling), 'LineStyle','none',...
                                                 'LineColor',[0 0 0],...
                                                 'Fill','on')
      
    end
    
    %each resolution is dependant on the frequency of
    %interest,and it''ss a continuous change
    tw = wvl_fc*sqrt(wvl_fb)./(f);
    fw = (f)*(1/wvl_fc)*(sqrt(2/(pi^2*wvl_fb)));
end % function cwtspectra()