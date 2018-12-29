%% Calculates cwt power spectrum.
%
%
% ARGUMENTS:
%     data        -- time series in column vectors ['time', 'number of time-series'].
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
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%=========Variables============%
%
%data = 1-D data
%wave = mother wavelet
%frequency = [start frequency, end frequency, number of points]
%            OR place in a vector greater than 3 points
%periodspec = vector for period analysis with a complex morlet wavelet
%           [sampling rate (Hz) fs, center band frequency (Hz) fc,
%                                     frequency bandwith fb (Hz)]
%%==============================%
%
% Example of use: 
% data = O2;
% frequency = [1,20,10]
% periodspec = [200, 1, 10];
% [c time f pwr] = cwtspectra(data, frequency, periodspec);
% c = wavelet coefficients, apwr = averaged alpha power, time=time vector
%
% type [c time f pwr] = cwtspectra(data, frequency, periodspec,lot)
% lot = 'n' if the plot is not needed
% lot = 'p' plots in a new figure
% lot = 's' plots the spectrum in the active figure
%
%
% type [c time f pwr pw] = cwtspectra(data, frequency, periodspec)
% pw is the spectral power as defined in rudraf et al.
%
%
% type [c time f pwr] = cwtspectra(data, frequency, periodspec,lot,scaling)
% lot = 'p' for plot and no plot as above -- 'n'
% scaling allows the diagram to be scaled:
% scaling = 0 is normalized scaling, any other number is what the images are 
% divided by
%
% eg. [c time f pwr] = cwtspectra(data,frequency, periodspec,'p',0,10)
%
% type [c time f pwr pw tw fw] = cwtspectra(data, frequency, periodspec,lot,scaling)
% with resolution one obtains values on the resolution widths in frequency
% and time in the specified time frequency points over the input range
% tw = time widths
% fw = frequency widths



function [c time f pwr pw tw fw] = cwtspectra(data, freq_vec, periodspec, display_flag,scaling)

    if nargin < 3 || isempty(x)
        error(['PSL:', mfilename, ':BadArgs'], ...
            'you MUST at least provide a time series');
    elseif (size(x, 1) == 1)
        % handle being provided a single row vector
        x = x(:);
    end

    if (nargin < 4)
        display_flag = true; 
    end
    
    if (nargin < 5)
        scaling = 1; 
    end
        
        %extract spectrogram parameters
        fs = periodspec(1);
        fc = periodspec(2);
        fb = periodspec(3);

        %time=0:(1/fs):((length(data)/fs)-1);
        time = (1:length(data))/fs;        
        
        %frequency vector 
        if length(freq_vec) == 3
            f = linspace(freq_v(1),freq_vec(2),freq_vec(3));
        else
            f = freq_vec;
        end
        
        %Establish the scales from the frequency using the frequency-scale relation
        %Using the Mallat method (Method in Najimi)      
        
        %scale - frequency relationship               
        scales = (fs./f)*fc;
        
        %reorder the scales so that it is in ascending order
        scales = scales(end:-1:1);              
        
        %chosen mother wavelet as per wavelet entering format
        mother_wavelet = ['cmor',num2str(fb),'-',num2str(fc)];
        
        %preassign c and s
        c = zeros(length(f), length(data));
        s = zeros(length(f), length(data));
        
        %perform the CWT
        c = cwt(data,scales,wave);
        %reverse the order of the coefficients
        c = c(end:-1:1,:);
        
        if (nargout >= 4)
            %determine the averaged power
            pwr = sum(abs(c).^2)/trapz(sum(abs(c)).^2);
        end
        scmtx = repmat(scales(end:-1:1).',1,length(c));
        
        % Normalized Spectral power --> from derivation of wavelet transform
        pw = abs(c).^2./scmtx;
        
        %draw the images and the plots
        if display_flag
            
            %% images with power %%%
            if (nargout >= 4)
                figure;hold on;
                subplot 311
                plot(time,data); xlabel('time (s)'); ylabel('Amplitude [a.u.]');
                subplot 313
                plot(time,pwr); xlabel('time (s)'); ylabel('Power [a.u.]');
                if (scaling == 0)
                    %scaling is normalized
                    subplot 312
                    imagesc(time,f,pw); xlabel('time (s)'); ylabel('Frequency (Hz) ');
                    hold off;

                    figure;imagesc(time,f,pw); xlabel('time (s)'); ylabel('Frequency (Hz) ');
                else
                    %scaling is adjusted to your specified values
                    subplot 312
                    image(time,f,pw/scaling); xlabel('time (s)'); ylabel('Frequency (Hz) ');
                    hold off;

                    figure;image(time,f,pw/scaling); xlabel('time (s)'); ylabel('Frequency (Hz) ');
                end;


            %% spectrogram images - no power %%
            else
                if (scaling == 0)
                    %scaling is normalized
                    figure;imagesc(time,f,pw); xlabel('time (s)'); ylabel('Frequency (Hz) ');
                else
                    %scaling is adjusted to your specified values
                    figure;image(time,f,pw/scaling); xlabel('time (s)'); ylabel('Frequency (Hz) ');
                end;
            end
            
        %% same figure plots
        elseif ~display_flag
            
            if (scaling == 0)
                %scaling is normalized
                imagesc(time,f,pw); xlabel('time (s)'); ylabel('Frequency (Hz) ');
            else
                %scaling is adjusted to your specified values
                image(time,f,pw/scaling); xlabel('time (s)'); ylabel('Frequency (Hz) ');
            end;
            
        end;
        
        %resoultion of time and frequency values calculated here
        if (nargout >6 )
            %each of the resolutions are dependant on the frequency of
            %interest,and its a continuous change
            tw = fc*sqrt(fb)./(f);
            fw = (f)*(1/fc)*(sqrt(2/(pi^2*fb)));
        end;
