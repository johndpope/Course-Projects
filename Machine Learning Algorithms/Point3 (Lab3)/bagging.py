import util
import numpy as np
import sys
import random

PRINT = True

###### DON'T CHANGE THE SEEDS ##########
random.seed(42)
np.random.seed(42)

class BaggingClassifier:
    """
    Bagging classifier.

    Note that the variable 'datum' in this code refers to a counter of features
    (not to a raw samples.Datum).
    
    """

    def __init__( self, legalLabels, max_iterations, weak_classifier, ratio, num_classifiers):

        self.ratio = ratio
        self.num_classifiers = num_classifiers
        self.classifiers = [weak_classifier(legalLabels, max_iterations) for _ in range(self.num_classifiers)]

    def train( self, trainingData, trainingLabels):
        """
        The training loop samples from the data "num_classifiers" time. Size of each sample is
        specified by "ratio". So len(sample)/len(trainingData) should equal ratio. 
        """

        self.features = trainingData[0].keys()
        size = int(len(trainingData)*self.ratio)
        
        for i in range(self.num_classifiers):
        	indices = util.nSample( np.ones(len(trainingData)), range(len(trainingData)), size)
        	new_trainingData= [trainingData[j] for j in indices]
        	new_trainingLabels= [trainingLabels[j] for j in indices]
        	self.classifiers[i].train(new_trainingData, new_trainingLabels)

    def classify( self, data):
        """
        Classifies each datum as the label that most closely matches the prototype vector
        for that label. This is done by taking a polling over the weak classifiers already trained.
        See the assignment description for details.

        Recall that a datum is a util.counter.

        The function should return a list of labels where each label should be one of legaLabels.
        """
        size = len(data)
    	total_score = np.zeros(size)

    	for i in range(self.num_classifiers):
    		score = self.classifiers[i].classify(data)
    		total_score = total_score + score

        final_score = [util.sign(x) for x in total_score]
        return final_score
