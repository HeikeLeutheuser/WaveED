function [PeakPositions] = lineFittingEventDetection (signal, fs, ...
    searchWindow )
%LINEFITTINGEVENTDETECTION identifies one wave event in a given search 
%window. This is a revised version of the algorithm described in the
%following publication:
%Hu, X., Liu, J., Wang, J., Xiao, Z., Yao, J. (2014) Automatic detection of
%onset and offset of QRS complexes independent of isoelectric segments.
%Measurement,51:53-62.
%
%     Inputs:
%          signal - 2-dimensional signal; 
%                       1st column: time indices in seconds
%                       2nd column: data / signal values
%          fs - sampling rate of signal
%          searchWindow - struct with searchWindow.start and searchWindow.end
%                      in samples that identify the search region within
%                      the signal
%
%     Output:
%          PeakPositions - struct PeakPositions.MaxPeak with identified
%        peak in the range of the searchWindow
% 
% BY Heike Leutheuser, 31.03.2016, heike.leutheuser@fau.de
% 
% Please cite this publication when using this code: 
% H. Leutheuser, S. Gradl, L. Anneken, M. Arnold, N. Lang, S. Achenbach, B.
% M. Eskofier, "Instantaneous P- and T-wave detection: assessment of three
% ECG fiducial points detection algorithms", submitted, 2016.
%
% MIT License
% 
% Copyright (c) 2016 Heike Leutheuser
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.


%calculation of k in dependence of fs (sampling rate)
%k = # samples included in line fitting
%k = 5 for fs = 500 Hz; see k is set to 5 in most cases
time_int = 5*1/500;
k = round(fs*time_int);

% Initialize MaxPeakPosition
MaxPeakPosition = zeros(size(searchWindow.start));

for i = 1:max(size(searchWindow.start)),
    window = searchWindow.start(i):searchWindow.end(i);
    ecg = signal(window,2);
    x = ecg/max(ecg);
    t = signal(window,1);
    
    theta1(1:k,1) = NaN;
    theta2(1:k,1) = NaN;
    
    % Calculate angles over window signal
    for j = 1:length(x)-(2*k);
        t_AB = t(j:k+j,1);
        y_AB = x(j:k+j,1);
        %polynomial of degree 1
        A_reg = [t_AB ones(k+1,1)];
        b_reg = y_AB;
        xp = pinv(A_reg)*b_reg;
        a = xp(1);
        b = xp(2);
        clear xp A_reg b_reg
        
        t_AC = t(k+j:2*k+j,1);
        y_AC = x(k+j:2*k+j,1);
        %polynomial of degree 1 -> straight line
        A_reg = [t_AC ones(k+1,1)];
        b_reg = y_AC;
        xp = pinv(A_reg)*b_reg;
        c = xp(1);
        d = xp(2);
        clear A_reg b_reg xp
        
        %Calculation of the included angle
        %atand = inverse tangent in degrees
        theta1(j+k,1) = atand(a); %defined in interval -90 < theta1 < 90
        theta2(j+k,1) = atand(c); %defined in interval -90 < theta2 < 90
        clear a b c d t_AB t_AC y_AB y_AC
    end
    clear j
    
    %calculate theta_max
    %assumption -> theta_max is the positive peak --> then 0 < theta1 < 90
    %&& -90 < theta2 < 0
    %theta_max is the angle for the maximum peak -> should be minimized
    %later that have a sharper curve
    for j = 1:size(theta1,1),
        if (theta1(j) > 0 && theta1(j) < 90)
            if (theta2(j) < 0 && theta2(j) > -90)
                theta2_pos = 360 - abs(theta2(j));
                diff1 = theta1(j) - theta2_pos; %negativ, da theta1 < theta2
                pos_diff1 = 360 - abs(diff1);
                theta_max(j,1) = 180 - pos_diff1;
                clear theta2_pos diff1 pos_diff1
            else
                theta_max(j,1) = NaN;
            end
        else
            theta_max(j,1) = NaN;
        end
    end
    clear j
    
    %assumption -> theta_max is the negative peak --> then -90 < theta1 < 0
    %&& 0 < theta2 < 90
    for j = 1:size(theta1,1),
        if (theta1(j) > -90 && theta1(j) < 0),
            if (theta2(j) > 0 && theta2(j) < 90),
                if (isnan(theta_max(j,1)) == true),
                    theta_max(j,1) = 180 - theta2(j,1) - abs(theta1(j,1));
                end
            end
        end
    end
    clear j
    
    % Find the maximum peak in this interval --> look for the minimum ANGLE
    K = size(window,2) - k;
    %Initialization
    k_run = 1+k; theta0 = 180; M = 0; kind = '';%**MODIFICATION**
    while (k_run <= K)
        if (theta1(k_run) > 0 && theta2(k_run) < 0)
            if (theta_max(k_run) < theta0)
                theta0 = theta_max(k_run);
                M = k_run;
                kind = 'max';
                k_run = k_run + 1;
            else
                k_run = k_run + 1;
            end
        elseif (theta1(k_run) < 0  && theta2(k_run) > 0),
            if (theta_max(k_run) < theta0),
                theta0 = theta_max(k_run);
                M = k_run;
                kind = 'min';
                k_run = k_run + 1;
            else
                k_run = k_run + 1;
            end
        else
            k_run = k_run+1;
        end
    end
    if ~isempty(kind)
        MaxPeakPosition(i,1) = M; %within window
    else
        MaxPeakPosition(i,1) = NaN;
    end
    clear k_run theta0 M theta1 theta2 theta_max window ecg
end

PeakPositions.MaxPeak = MaxPeakPosition + searchWindow.start;

end