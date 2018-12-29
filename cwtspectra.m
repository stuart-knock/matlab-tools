%% Calculates cwt power spectrum based on cwt prior to R2016b
%
%
% ARGUMENTS:
%     data          -- time series 1 x timepoints
%     fs            -- sampling frequency in Hz. 
%     freq_vec      -- frequency support for the cwt
%     wvl_fc        -- central frequency of the wavelet
%     wvl_fb        -- frequency bandwidth of the wavelet
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
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [cwt_coeffs, time, f, av_pwr, norm_pwr, tw, fw] = cwtspectra(data, fs, freq_vec, wvl_fc, wvl_fb, display_flag, scaling)

    if nargin < 2 || isempty(data) || isempty(fs)
        error(['PSL:', mfilename, ':BadArgs'], ...
            'you MUST at least provide a time series and a sampling frequency.');
    end

    if (nargin < 3)
        display_flag = true; 
        scaling  = 1; 
        freq_vec = linspace(0, fs/4, length(data)/2);
        wvl_fc = fs/10;
        wvl_fb = fs/8; 
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
    
    %preassign c and s
    cwt_coeffs = zeros(length(f), length(data));
    s = zeros(length(f), length(data));
    
    %This syntax calls the 'old' version of CWT --> wavelet.internal.cwt
    cwt_coeffs = cwt(data, scales, mother_wavelet);

    %reverse the order of the coefficients
    cwt_coeffs = cwt_coeffs(end:-1:1,:);
    
    
    % Calculate average power
    av_pwr = sum(abs(cwt_coeffs).^2)/trapz(sum(abs(cwt_coeffs)).^2);
    scmtx  = repmat(scales(end:-1:1).',1,length(cwt_coeffs));
        
    % Normalized Spectral power --> from derivation of wavelet transform
    norm_pwr = abs(cwt_coeffs).^2./scmtx;
    
    %draw the images and the plots
    if display_flag
        figure_handle = figure;
        ax(1) = subplot(311);
        ax(2) = subplot(312);
        ax(3) = subplot(313);

        for this_ax = 1:length(ax)
            ax(this_ax).Box = 'on';
        end

        plot(ax(1), time, data); 
        ax(1).XLabel.String = 'Time [s]'; 
        ax(1).YLabel.String = 'Amplitude [a.u.]';

        plot(ax(3), time, av_pwr); 
        ax(3).XLabel.String = 'Time [s]'; 
        ax(3).YLabel.String = 'Normalised Power [a.u.]';

        image(ax(2), time, f, norm_pwr/scaling); 
        ax(2).XLabel.String = 'Time [s]'); 
        ax(2).YLabel.String = 'Frequency [Hz] ';
      
    end
    
    %each resolution is dependant on the frequency of
    %interest,and it''ss a continuous change
    tw = wvl_fc*sqrt(wvl_fb)./(f);
    fw = (f)*(1/wvl_fc)*(sqrt(2/(pi^2*wvl_fb)));
end % function cwtspectra()