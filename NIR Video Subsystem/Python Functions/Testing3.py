import os
import sys
import cv2
from openni import openni2
import argparse
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import matlab
from array import array
import CameraFunctions as cam
import time
print(sys.path)
print(time.time())
cam.initialize_ST01() # start
dev = openni2.Device.open_any()
dev2=dev.get_device_info()
dev3=dev.get_sensor_info(3)
print(dev3)
print(dev2)
[IR_Stream,Depth_Stream]=cam.start_IR_and_color() # initalize streams
#time.sleep(2)
Data_Streams=[IR_Stream,Depth_Stream]
#print(IR_Stream.get_number_of_frames(30))
cam.num_frames=200 # how many frames do we want
cam.delay=0.1

[raw,raw2]=cam.take_IR_imagevtwo(Data_Streams)
print(np.mean(np.diff(raw2)))
print(np.std(np.diff(raw2)))
print(raw2[-1])

cam.kill_both_streams(Data_Streams)

# plotting
fig1, (ax2) = plt.subplots(nrows=1, ncols=1)
ax2.plot(np.diff(raw2))
plt.show()



