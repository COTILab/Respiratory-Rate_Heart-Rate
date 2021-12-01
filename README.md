# Respiratory-Rate_Heart-Rate
 Measuring RR and HR using camera based methods

3 Submodules:
	1. NIR Video Subsystem:
	Hardware Used: Occipital ST01 Structure sensor (for illumination) and Blackfly camera(BFS-U3-28S5)
	
	Inputs : 1. NIR image: Frontal view of illuminated face --> Heart Rate
		 2. OPTIONAL: Frontal view of lluminated chest and/or abdominal region --> Respiratory Rate

	Procedure: Video (~ 7.5 Hz) of subject motionless with minimal ambient lighting. EMD decomposition and filtering of
2 separate regions of interest. Face analysis returns Heart rate and Chest analysis returns respiratory rate

	Outputs: Heart Rate and Respiratory Rate (Optional)

	Current Status/ Recommended Use case: Preliminary data obtained internally. Pipeline assessed on "acoustic phantoms" 
driven at fixed frequency and on subjects compared to controlled breathing/ pulse oximeter standards. System recommended for use 
in SLEEPING CASE

	Known issues: Sensitive to distance to camera+ movement. Possible SNR concerns. Obstruction of face + layers of clothing
covering chest region will interefere with HR and RR measurements significantly .

----------------------------------------------------------------------------------------
2. Color Video Subsystem:
	Hardware Used: currently using internal webcam but modular functions allow for any RGB camera to suffice. Easily substitutable.
	

	Inputs : 1. Color (RGB) image: Frontal view of unobstructed face --> Heart Rate
		

	Procedure: Video (~ 7.5 Hz) of subject motionless with ambient lighting. ICA decomposition and filtering of
 region of interest derived using K-means clustering.

	Outputs: Heart Rate

	Current Status/ Recommended Use case: Preliminary data obtained internally. Literature indicates that RGB systems have 
higher SNR compared to NIR based systems are less sensitive to minor motion artifacts. ICA based approach should theoretically correct for more prevalent forms of motions
(exercise, daily acitivities) as long as ROI is tracked. This has not been assessed yet.  System recommended for use 
in upright position with sufficient ambient lighting

	Known issues: Obstruction of face will harm signal output. Matlab intermittently crashes while testing and it is not due to code itself ( just a internal bug for myself for now...)

---------------------------------------------------------------------------------------------
3. Thermal Video Subsystem:
	Hardware used: FLIR Lepton 3.5+Breakoutboard-- Thermal camera Longwave infrared, 8 μm to 14 μm
Spec sheet: https://www.flir.com/support/products/lepton/#Documents
	

	Inputs : 1. Frontal view of unobstructed face --> Respiratory Rate
		

	Procedure: Work in progress. Proposed -- ROI of Face --> Subregion of pixels around nose/mouth with greatest correlation with
respiratory rate as indicated by literature. We will use either openCV or matlab to pick this specific region. As the expected frequency of RR is far lower,
the video frame rate (~ 7 HZ) should be sufficient to obtain the signal. Additional Filtering will be used as needed on data stream.

	Outputs: Respiratory Rate

	Current Status/ Recommended Use case: Very much a work in progress. FLIR Lepton camera has been tested preliminarily integrated with image acquistion toolbox with no major issues thus far.

	Known issues: Excessively Hot regions/cold regions (temperature) within image will ruin the ability to derive respiratory rate due to 
quantization issues when reading temperatures--> RGB values. For more information, read the FLIR lepton documentation sections on histogram normalization. Subject must be present in scenario where no "hot/cold" spots 
dominate the entirety of the image. This is the last module we are working on and thus the full range of issues is not currently known.

 



	









___________________________________________________________________________________________________________________________________________________________________________________________________
Technology Dependencies:

----------------------------------------------------------------------------------------------------------------------------
Hardware:
1. NIR Illumination: Occipital ST01 Structure Sensor-- CAN REPLACE WITH ANY CW NIR SOURCE
2. NIR Camera: Blackfly (BFS-U3-28S5)
3. Color Camera: Currently using laptop internal camera for testing but any fixed color camera ( even external webcam should suffice). Replace function "Take_Internal_Webcam_Images.m" under 
".\Respiratory Rate_Heart Rate\Color Video Subsystem\rPPG-master\rPPG-master\VZ_Color_Functions when desired.
4. Thermal Camera: FLIR Lepton 3.5 --https://groupgets.com/manufacturers/getlab/products/purethermal-2-flir-lepton-smart-i-o-module


----------------------------------------------------------------------------------------------------------------------------
Software:
Code has been tested using Matlab R2021a on Windows 10 with the following packages: Most dependencies can be installed directly via the package installer on matlab. The rest are included in the github path already.

"Image Acquisition Toolbox Support Package for OS Generic Video Interface"    "21.1.0"     true      "OSVIDEO"                             
    "Image Processing Toolbox"                                                    "11.3"       true      "IP"                                  
    "Statistics and Machine Learning Toolbox"                                     "12.1"       true      "ST"                                  
    "Deep Learning Toolbox"                                                       "14.2"       true      "NN"                                  
    "Computer Vision Toolbox Interface for OpenCV in MATLAB"                      "21.1.0"     true      "CVST_OPENCV_INTERFACE"               
    "MATLAB Support Package for USB Webcams"                                      "21.1.1"     true      "USBWEBCAM"                           
    "Symbolic Math Toolbox"                                                       "8.7"        true      "SM"                                  
    "Instrument Control Toolbox"                                                  "4.4"        true      "IC"                                  
    "MTCNN Face Detection"                                                        "1.2.4"      true      "d2cc38da-9b3d-4307-8cfd-4a34d5a442bf"
    "Signal Processing Toolbox"                                                   "8.6"        true      "SG"                                  
    "Computer Vision Toolbox"                                                     "10.0"       true      "VP"                                  
    "FLIR Spinnaker support by Image Acquisition Toolbox"                         "6.1"        true      "df118cab-f375-4a80-ac65-10a984a79ebb"
NOTE: To use Blackfly camera with Image acquistion toolbox, run 'REGISTER_BLACKFLY_IMQ.m' and change path disp("CHECK THE FILE PATH BELOW")
imaqregister("C:\Users\rahul\OneDrive - Northeastern University\blackfly images\07JAN20--Preliminary SFDI Images\MAIN_BlackFlyMatlab Image Acquisition Scripts\FLIR Spinnaker support by Image Acquisition Toolbox\R2021a\mwspinnakerimaq.dll", "unregister")
to necessary path
    "Control System Toolbox"                                                      "10.10"      true      "CT"                                  
    "Optimization Toolbox"                                                        "9.1"        true      "OP"                                  
    "Image Acquisition Toolbox"      

Additionally for structure sensor (Occipital ST01) source:

Python 3.xx is needed along with the following dependencies/libraries:

os
sys
cv2
openni2
NOTE: for reference as this package is not common or well documented at all...
 https://s3.amazonaws.com/com.occipital.openni/OpenNI_Programmers_Guide.pdf -- api
https://structure.io/openni
http://com.occipital.openni.s3.amazonaws.com/Structure%20Sensor%20OpenNI2%20Quick%20Start%20Guide.pdf
WE MUST CHANGE THE FOLLOWING SO THIS CAN WORK...
REMOVE SEMICOLON and change usbinterface to 0...
 REMOVE SEMICOLON and change usbinterface to 0...  under PS1080.ini under ./../././ Drivers

argparse
numpy
matplotlib