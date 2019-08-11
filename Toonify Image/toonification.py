import cv2
import numpy as np
from matplotlib import pyplot as plt
from parameters import *

def toonify(inputImage):
	#inputImage = cv2.imread('1.jpeg')
	#inputImage = cv2.resize(inputImage, (800,800))
	################################### Median Filter #############################################
	#kernelSize_medianFilter = 7;
	medianFiltered = cv2.medianBlur(inputImage,kernelSize_medianFilter)

	#cv2.imwrite('output/1.jpeg',medianFiltered)
	# cv2.waitKey(0)
	# cv2.destroyAllWindows()

	#####################################Edges Detection#############################################
	#lowerThreshold = 50
	#upperThreshold = 100
	edgesDetected = cv2.Canny(medianFiltered, lowerThreshold, upperThreshold)

	#cv2.imwrite('output/2.jpeg',edgesDetected)
	# cv2.waitKey(0)
	# cv2.destroyAllWindows()

	##################################### Dilation ###################################################
	#dilationKernelSize = 2
	dilationKernel = np.ones((dilationKernelSize, dilationKernelSize), np.uint8)

	dilatedImage = cv2.dilate(edgesDetected, dilationKernel, iterations = 1)
	#cv2.imwrite('output/3.jpeg',dilatedImage)
	# cv2.waitKey(0)
	# cv2.destroyAllWindows()

	################################### Edge Filtering (Segmentation) #################################
	#hsvForm = cv2.cvtColor(dilatedImage, cv2.COLOR_BGR2GRAY)
	#thresholdValue = 127
	#maxVal = 255
	invertedEdges = cv2.bitwise_not(dilatedImage)

	threshold, thresholdedImage = cv2.threshold(invertedEdges, thresholdValue, maxVal, 0)

	############### Adaptive Thresholding ##########################
	#thresholdedImage = cv2.adaptiveThreshold(invertedEdges, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2)
	################################################################

	image, contours, hierarchy = cv2.findContours(thresholdedImage, 1, 2)
	#thicknessContours = 2
	cv2.drawContours(thresholdedImage, contours, -1, (0,0,0), thicknessContours)
	#cv2.imwrite('output/4.jpeg',thresholdedImage)
	# cv2.waitKey(0)
	# cv2.destroyAllWindows()
	#cv2.imwrite('output/10.jpeg',hierarchy)
	#cv2.imwrite('output/5.jpeg',image)
	#cv2.imwrite('output/6.jpeg',invertedEdges)
	#################################### Part 1 Completed ##################################################
	########################################################################################################
	#################################### Color Quantization ################################################

	##################################### Downsampling ##################################################
	downsampleX = inputImage.shape[0] / 4
	downsampleY = inputImage.shape[1] / 4
	#downSamplingFactor = 4
	downsampledImage = cv2.resize(inputImage, (0,0), fx = 1/downSamplingFactor, fy = 1/downSamplingFactor)
	#cv2.imwrite('output/7.jpeg',downsampledImage)
	# cv2.waitKey(0)
	# cv2.destroyAllWindows()

	#################################### Bilateral Filtering ###############################################
	#iterations = 14

	#kernelSize = 9
	#sigmaSpace = 50
	#sigmaColor = 50

	bilateralFilteredImage = cv2.bilateralFilter(downsampledImage, kernelSize_bilateralFilter, sigmaColor, sigmaSpace)
	for i in range(iterations - 1) :
		bilateralFilteredImage = cv2.bilateralFilter(downsampledImage, kernelSize_bilateralFilter, sigmaSpace, sigmaColor)

	# cv2.imshow('Dilated Image',bilateralFilteredImage)
	# cv2.waitKey(0)
	# cv2.destroyAllWindows()
	#cv2.imwrite('output/8.jpeg',bilateralFilteredImage)

	################################# Linear interpolation ##################################################

	linearInterpolatedImage_temp = cv2.resize(bilateralFilteredImage, None, fx = downSamplingFactor, fy = downSamplingFactor, interpolation = cv2.INTER_LINEAR)
	linearInterpolatedImage = cv2.resize(linearInterpolatedImage_temp, (inputImage.shape[1], inputImage.shape[0]))
	#cv2.imwrite('output/9.jpeg',linearInterpolatedImage)
	# cv2.waitKey(0)
	# cv2.destroyAllWindows()

	################################# Median Filtering #################################################

	medianFilteredImage = cv2.medianBlur(linearInterpolatedImage, kernelSize_medianFilter)
	#cv2.imwrite('output/10.jpeg',medianFilteredImage)
	# cv2.waitKey(0)
	# cv2.destroyAllWindows()

	################################ Color Quantization ###############################################
	#quantizationFactor = 12

	shape = medianFilteredImage.shape
	length = shape[0]
	width = shape[1]

	for i in range(length) :
		for j in range(width):
			medianFilteredImage[i][j][0] = round(medianFilteredImage[i][j][0] / quantizationFactor) * quantizationFactor
			medianFilteredImage[i][j][1] = round(medianFilteredImage[i][j][1] / quantizationFactor) * quantizationFactor
			medianFilteredImage[i][j][2] = round(medianFilteredImage[i][j][2] / quantizationFactor) * quantizationFactor

	#cv2.imwrite('output/11.jpeg',medianFilteredImage)
	# cv2.waitKey(0)
	# cv2.destroyAllWindows()

	# print(medianFilteredImage.shape)
	# print(thresholdedImage.shape)
	# print(image.shape)
	######################################## Combining both parts ######################################
	toonifiedImage = medianFilteredImage
	for i in range(length) :
		for j in range(width) :
			if invertedEdges[i][j] == 0:
				toonifiedImage[i][j][0] = 0
				toonifiedImage[i][j][1] = 0
				toonifiedImage[i][j][2] = 0

	#cv2.imwrite('output/12.jpeg', toonifiedImage)
	#cv2.imshow('Toonified Image',toonifiedImage)
	cv2.waitKey(0)
	cv2.destroyAllWindows()

	return toonifiedImage

