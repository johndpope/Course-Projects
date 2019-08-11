import cv2
import numpy as np
import os
from os.path import isfile, join
import toonification

# Playing video from file:
cap = cv2.VideoCapture('Sahara.mp4')

currentFrame = 0
while(True):
    # Capture frame-by-frame
    if currentFrame > 100:
        break
    ret, frame = cap.read()

    # Saves image of the current frame in jpg file
    name = 'output_video/frame' + str(currentFrame) + '.jpg'
    #print ('Creating...' + name)
    cv2.imwrite(name, frame)

    # To stop duplicate images
    currentFrame += 1

# When everything done, release the capture
cap.release()
cv2.destroyAllWindows()

frame_array = []
files = [f for f in os.listdir("output_video/")]
files.sort(key = lambda x: int(x[5:-4]))
#print(files)

for i in range(len(files)):
        filename="output_video/" + files[i]
        #reading each files
        img = cv2.imread(filename)
        height, width, layers = img.shape
        size = (width,height)
        print(filename)
        toonedImage = toonification.toonify(img)
        #inserting the frames into an image array
        frame_array.append(toonedImage)

out = cv2.VideoWriter('output_video/video.avi',cv2.VideoWriter_fourcc(*'DIVX'), 25, size)

for i in range(len(frame_array)):
        # writing to a image array
        out.write(frame_array[i])

out.release()

