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
# Loading Dlib
import dlib ## finding OTHER LANDMARKS 

#rahul=np.array([1, 2,3,4])
#rahul.tolist()
#miguel=rahul.tolist()
#edward=matlab.double(miguel)
#print(type(rahul))
#print(type(list(rahul)))
#print(rahul.tolist())
#print(type(miguel))
#print(type(edward))
#rr=array('d',rahul)
#print(rr)

# Finding ROI with openCV
# https://www.datacamp.com/community/tutorials/face-detection-python-opencv

img_raw=cv2.imread('./testimg.jpg',0)
print(img_raw.shape)
#sf=1.2
#mn=5

#img_raw=cv2.imread('./testimg.jpg')
#print(type(img_raw))
#print(img_raw.shape)
#im2=np.asarray(img_raw)
#print(type(im2))
#test_image_gray = cv2.cvtColor(img_raw, cv2.COLOR_BGR2GRAY)
#print(type(test_image_gray))
#print(test_image_gray.shape)
haar_cascade_face = cv2.CascadeClassifier('C:/Users/rahul/OneDrive - Northeastern University/Respiratory Rate_Heart Rate/Matlab+Python Acquisition/Python Functions/haarcascades/haarcascade_frontalface_default.xml')
## LOADING DLIB DATA

predictor=dlib.shape_predictor("./dlibdat/shape_predictor_68_face_landmarks/shape_predictor_68_face_landmarks.dat")


#print(type(haar_cascade_face))
#plt.imshow(img_raw)


#faces_rects = haar_cascade_face.detectMultiScale(test_image_gray, scaleFactor = sf, minNeighbors = mn);

# Let us print the no. of faces found
#print('Faces found: ', len(faces_rects))
#print(faces_rects)
#landmark_list=[]

#for (x,y,w,h) in faces_rects:
#	rectangle=cv2.rectangle(test_image_gray, (x, y), (x+w, y+h), (0, 255, 0), 2)
#	drect=dlib.rectangle(int(x),int(y),int(x+w),int(y+h))
#	print(drect)
#	landmarks=predictor(test_image_gray, drect)
#	points=cam.shape_to_np(landmarks)
#	print(points[67])
#	for i in points:
#		xx=i[0]
#		yy=i[1]
#		#landmark_list.append(xx)
#		landmark_list.append(i)
#		circles=cv2.circle(rectangle,(xx,yy),2,(0,255,0),-1)


sf=1.2
mn=3
[predictor,haar_cascade_face]=cam.set_predictor_cascade()
[faces_rect_list,landmark_list]=cam.get_ROI_FACE(img_raw,sf,mn,predictor,haar_cascade_face)
#plt.imshow(rectangle)     
#circles=cv2.circle(rectangle,(points[33][0],points[33][1]),2,(0,255,0),-1)
#print(landmark_list)
#plt.imshow(circles)
#plt.show()


#dst = cv2.detailEnhance(img_raw, sigma_s=10, sigma_r=0.15)

#faces_rectsv2 = haar_cascade_face.detectMultiScale(dst, scaleFactor = sf, minNeighbors = mn);
#print('Faces found: ', len(faces_rectsv2))
#plt.imshow(dst)
#plt.show()