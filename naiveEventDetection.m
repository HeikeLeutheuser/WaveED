function [PeakPositions] = naiveEventDetection (signal, searchWindow )
%NAIVEEVENTDETECTION identifies one wave event in a given search 
%window. The identified wave event corresponds to the maximum within the
%searchWindow
%
%     Inputs:
%          signal - 1-dimensional signal 
%          searchWindow - struct with searchWindow.start, searchWindow.end
%                       searchWindow.start and searchWindow.end in samples 
%                       definee the search region within the signal
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

%created 31.03.2016 HL
% irgendwas simmt mit der ecglib Implementierung nicht des naiven
% Algorithmus


% Initialize MaxPeakPosition
MaxPeakPosition = zeros(size(searchWindow.start));

for i = 1:max(size(searchWindow.start)),
    if searchWindow.start(i) < searchWindow.end(i)
    window = searchWindow.start(i):searchWindow.end(i);
    
    relSignal = signal(window);
    
    [~,I] = max(relSignal);
    
    MaxPeakPosition(i,1) = searchWindow.start(i)+I;
    
    clear window relSignal I
    end
end

PeakPositions.MaxPeak = MaxPeakPosition;

end