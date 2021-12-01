# Respiratory-Rate_Heart-Rate
 Measuring RR and HR using camera based methods

Technology Dependencies:

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

Python 3.xx is needed along with the following dependencies:

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