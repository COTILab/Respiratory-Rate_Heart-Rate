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

cam.initialize_ST01() # start
[IR_Stream,Depth_Stream]=cam.start_IR_and_color() # initalize streams
#time.sleep(2)
Data_Streams=[IR_Stream,Depth_Stream]
#print(IR_Stream.get_number_of_frames(30))
num_frames=300 # how many frames do we want
delay=0.07
#test_img_rs_2=[]
#test_img=cam.take_IR_image(Data_Streams)
## Reshaping-- ENSURE EVERY NP.ARRAY IS 3D Before we start
test_img_rs=np.zeros((240,320,num_frames))
print(test_img_rs.shape)
# memory prallocation
toc=np.zeros((num_frames))
tic=time.time()

for i in range(num_frames):
	
	test_img=cam.take_IR_image(Data_Streams)
	time.sleep(delay)
	#cat=np.concatenate((cat,test_img))
	temp=np.asarray(test_img).reshape((240,320))#np.asarray(test_img).reshape((240,320,1))
	test_img_rs[:,:,i]=temp#np.concatenate((test_img_rs,temp),axis=2)
	toc[i]=time.time()-tic

#print(test_img_rs.shape)
toc_toc=np.diff(toc[1:-1])
print(np.mean(toc[1:-1]))

test_img_rs=test_img_rs[:,:,1:num_frames+1] # deleting first frame										

##print(type(test_img_rs))
##print(test_img_rs.shape)
fig1, (ax2, ax3,ax4) = plt.subplots(nrows=3, ncols=1)
ax2.imshow(test_img_rs[:,:,-1]) # just an example
ax3.plot(toc[1:-1])

ax3.set_title(np.mean(toc[1:-1]))
ax4.plot(toc_toc-np.mean(toc_toc))
ax4.set_title(["{:.4f}".format(np.mean(toc_toc)),"{:.4f}".format(np.std(toc_toc))])
plt.show()

cam.kill_both_streams(Data_Streams)
