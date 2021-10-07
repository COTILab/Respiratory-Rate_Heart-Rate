import os
import sys
import cv2
from openni import openni2
import argparse
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
#import matlab.engine
import matlab
from array import array
from PIL import Image 
import time
import dlib
#declaring globals
global delay,num_frames

def initialize_ST01(): # initializes camera
	
	print(sys.platform)
	openni2.initialize("C:\Program Files\OpenNI2\Redist")     # can also accept the path of the OpenNI redistribution
	return "Initialized"
# hard coded path because we are sloppy..

def start_IR_and_color():

	dev = openni2.Device.open_any()
	dev2=dev.get_device_info()
	dev3=dev.get_sensor_info(1)
	print(dev2)
	print(dev3)
	IR_Stream=dev.create_ir_stream()
	Depth_Stream=dev.create_depth_stream()
	IR_Stream.start()
	Depth_Stream.start()
	#Depth_Stream.stop()
	return IR_Stream,Depth_Stream

def kill_both_streams(Data_Streams):
	#IR_Stream=Data_Streams
	IR_Stream=Data_Streams[0] # first entry
	Depth_Stream=Data_Streams[1] # second entry 
	IR_Stream.stop()
	Depth_Stream.stop()
	openni2.unload()


def take_IR_image(Data_Streams):
	#eng = matlab.engine.start_matlab()
	#IR_Stream=Data_Streams
	IR_Stream=Data_Streams[0] # first entry
	Depth_Stream=Data_Streams[1] # second entry 

	frame = IR_Stream.read_frame()
	frame_data = frame.get_buffer_as_uint16()
	#print(type(frame_data))
	IR_array = np.asarray(frame_data)#np.asarray(frame_data).reshape((240, 320))
	IR_array_list=array('d',IR_array)
	#depth_array_matlab=matlab.double(depth_array_list)
	#eng.quit()
	#print(type(depth_array_matlab))
	return IR_array_list

def get_globals():
	return delay,num_frames,type(delay),type(num_frames)

def set_int(var):
	return int(var)

def take_IR_imagevtwo(Data_Streams):
	#print("FUCK YOU")
	#delay=0.06
	num_frames_casted=set_int(num_frames)
	print(type(num_frames_casted))
	IR_Stream=Data_Streams[0] # first entry
	Depth_Stream=Data_Streams[1] # second entry 
	test_img_rs=np.zeros((240,320,num_frames_casted)) # fixed on pixel size of ST01
	toc=np.zeros((num_frames_casted))
	#num_frames=int(num_frames)
	#print(type(num_frames))
	tic=time.time()
	#num_frames=int(num_frames)
	for i in range(num_frames_casted):
		
		frame = IR_Stream.read_frame()
		frame_data = frame.get_buffer_as_uint16()
		time.sleep(delay)
	#cat=np.concatenate((cat,test_img))
		temp=np.asarray(frame_data).reshape((240,320))#np.asarray(test_img).reshape((240,320,1))
		test_img_rs[:,:,i]=temp#np.concatenate((test_img_rs,temp),axis=2)
		toc[i]=time.time()-tic

	return test_img_rs,toc  


## use open CV to get ROI fOR FACE
def get_ROI_FACE(img,sf,mn):
	print('DO WE EVEN GET HERE??????')
	mn=int(mn)
	img_arr=np.asarray(img)
	predictor=dlib.shape_predictor("C:/Users/rahul/OneDrive - Northeastern University/Respiratory Rate_Heart Rate/Matlab+Python Acquisition/Python Functions/dlibdat/shape_predictor_68_face_landmarks/shape_predictor_68_face_landmarks.dat")
	#im = Image.fromarray(img_arr)
	print (type(img))
	#print (type(img_arr))
	#print(img_arr.shape)
	img_raw=cv2.cvtColor(img_arr, cv2.COLOR_BGR2GRAY)
	haar_cascade_face = cv2.CascadeClassifier('C:/Users/rahul/OneDrive - Northeastern University/Respiratory Rate_Heart Rate/Matlab+Python Acquisition/Python Functions/haarcascades/haarcascade_frontalface_default.xml')
	faces_rects = haar_cascade_face.detectMultiScale(img_raw, scaleFactor =sf, minNeighbors =mn);

# Let us print the no. of faces found
	# can comment this out later...
	print('Faces found: ', len(faces_rects))
	#for (x,y,w,h) in faces_rects:
    #	rectangle=cv2.rectangle(img_raw, (x, y), (x+w, y+h), (0, 255, 0), 2)


    #rect_array = np.asarray(rectangle)#np.asarray(frame_data).reshape((240, 320))
	#rect_list=array('d',rect_array)

#print(type(haar_cascade_face))
	#print (type(img_raw))
	#print(type(faces_rects))
	#print(faces_rects.shape)
	#print(faces_rects)
	#face_rect_sz=faces_rects.size
	#print(face_rect_sz)
	#face_rect_rs=reshape(faces_rects,(1 face_rect_sz)) # resize to 1
	#print(face_rect_rs)
	#faces_rect_list=faces_rects
	#ctr=0
	faces_rect_list=[]
	if (len(faces_rects)>0) :
		for x in faces_rects:
			faces_rect_list.append(x)
		#ctr=ctr+1
		#print(ctr)
# for landmarks
	landmark_list=[]
	print("DO YOU WORKK>>>>>>")

	for (x,y,w,h) in faces_rects:
		#rectangle=cv2.rectangle(test_image_gray, (x, y), (x+w, y+h), (0, 255, 0), 2)
		drect=dlib.rectangle(int(x),int(y),int(x+w),int(y+h))
		landmarks=predictor(img_raw,drect)
		points=shape_to_np(landmarks)
		for i in points:
			landmark_list.append(i)

		#print(landmark_list)

      #  points=shape_to_np(landmarks)
      #		for i in points: # Assuming only 1 phase in image
     #			landmark_list.append(i)


	return faces_rect_list,landmark_list



def shape_to_np(shape, dtype="int"): # Converting dlib shape to numpy array
	coords = np.zeros((68, 2), dtype=dtype)
	for i in range(0, 68):
		coords[i] = (shape.part(i).x, shape.part(i).y)
	return coords

#def get_landmark_pts(img)	
#	predictor=dlib.shape_predictor("./dlibdat/shape_predictor_68_face_landmarks/shape_predictor_68_face_landmarks.dat")

