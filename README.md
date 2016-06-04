# WaveED
Algorithms for wave event detection - The algorithms are designed for instantaneous P- and T-Wave detection in the ECG signal. 

WaveletTransformEventDetection identifies one wave event in a given search window. This is an adapted version of the algorithm described in the following publication: Martinez, J. P. et al. (2004). A Wavelet-Based ECG Delineator: Evaluation on Standard Databases. IEEE Transactions on Biomedical Engineering, 51(4):570-581.

lineFittingEventDetection identifies one wave event in a given search window. This is a revised version of the algorithm described in the
following publication: Hu, X., Liu, J., Wang, J., Xiao, Z., Yao, J. (2014) Automatic detection of onset and offset of QRS complexes independent of isoelectric segments. Measurement,51:53-62.

naiveEventDetection identifies one wave event in a given search window. The identified wave event corresponds to the maximum within the
searchWindow.

# Citation
Please cite this publication when using the Matlab functions: 

Heike Leutheuser, Stefan Gradl, Lars Anneken, Martin Arnold, Nadine Lang, Stephan Achenbach, and Bjoern M. Eskofier, "Instantaneous P- and T-wave detection: Assessment of three ECG fiducial points detection algorithms," In Proc: 2016 Body Sensor Networks, accepted for publication, 2016.
