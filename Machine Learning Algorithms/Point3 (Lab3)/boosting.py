import util
import numpy as np
import sys
import random

PRINT = True

###### DON'T CHANGE THE SEEDS ##########
random.seed(42)
np.random.seed(42)

def small_classify(y):
    classifier, data = y
    return classifier.classify(data)

class AdaBoostClassifier:
    """
    AdaBoost classifier.

    Note that the variable 'datum' in this code refers to a counter of features
    (not to a raw samples.Datum).
    
    """

    def __init__( self, legalLabels, max_iterations, weak_classifier, boosting_iterations):
        self.legalLabels = legalLabels
        self.boosting_iterations = boosting_iterations
        self.classifiers = [weak_classifier(legalLabels, max_iterations) for _ in range(self.boosting_iterations)]
        self.alphas = [0]*self.boosting_iterations

    def train( self, trainingData, trainingLabels):
        """
        The training loop trains weak learners with weights sequentially. 
        The self.classifiers are updated in each iteration and also the self.alphas 
        """
        self.features = trainingData[0].keys()
        weights = np.empty(len(trainingData))
        weights.fill(1.0/len(trainingData))

        for i in range(self.boosting_iterations):
            self.classifiers[i].train(trainingData, trainingLabels, weights)
            error = 0
            for j in range(len(trainingData)):
                single_class = self.classifiers[i].classify([trainingData[j]])
                if single_class[0] != trainingLabels[j]:
                    error = error + weights[j]
            for j in range(len(trainingData)):
                single_class = self.classifiers[i].classify([trainingData[j]])
                if single_class[0] == trainingLabels[j]:
                    weights[j] = weights[j]*error/(1-error)
            
            weights = util.normalize(weights)
            self.alphas[i] = np.log( (1-error)/error )

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

        for i in range(self.boosting_iterations):
            score = self.classifiers[i].classify(data)
            new_score = [self.alphas[i]*x for x in score]
            total_score = total_score + new_score

        final_score = [util.sign(x) for x in total_score]
        return final_score