import numpy as np
from utils import *

def preprocess(X, Y):
	''' TASK 0
	X = input feature matrix [N X D] 
	Y = output values [N X 1]
	Convert data X, Y obtained from read_data() to a usable format by gradient descent function
	Return the processed X, Y that can be directly passed to grad_descent function
	NOTE: X has first column denote index of data point. Ignore that column 
	and add constant 1 instead (for bias part of feature set)
	'''
	rows, cols = np.shape(X);
	finalX = np.ones((rows, 1)); #first column 1 for all
	for j in range(1, cols):
		if type(X[0][j]) == str:
			str_set = set(X[:,j])
			encoded = one_hot_encode(X[:,j], list(str_set))
			finalX = np.transpose(np.concatenate([np.transpose(finalX), np.transpose(encoded)]))
		else: 
			this_col = X[:,j]
			avg = np.mean(this_col)
			std_dev = np.std(this_col)
			newX = [(x-avg)/std_dev for x in this_col]
			newX = np.reshape(newX, ((np.shape(newX))[0], 1))
			finalX = np.transpose(np.concatenate([np.transpose(finalX), np.transpose(newX)]))

	return finalX.astype(float), Y.astype(float)

def grad_ridge(W, X, Y, _lambda):
	'''  TASK 2
	W = weight vector [D X 1]
	X = input feature matrix [N X D]
	Y = output values [N X 1]
	_lambda = scalar parameter lambda
	Return the gradient of ridge objective function (||Y - X W||^2  + lambda*||w||^2 )
	'''
	grad = (-2)*np.matmul(np.transpose(X), Y - np.matmul(X, W)) + 2*_lambda*W
	return grad

def ridge_grad_descent(X, Y, _lambda, max_iter=30000, lr=0.00001, epsilon = 1e-4):
	''' TASK 2
	X 			= input feature matrix [N X D]
	Y 			= output values [N X 1]
	_lambda 	= scalar parameter lambda
	max_iter 	= maximum number of iterations of gradient descent to run in case of no convergence
	lr 			= learning rate
	epsilon 	= gradient norm below which we can say that the algorithm has converged 
	Return the trained weight vector [D X 1] after performing gradient descent using Ridge Loss Function 
	NOTE: You may precompure some values to make computation faster
	'''
	W = np.ones([ (np.shape(X))[1], 1])
	for i in range(max_iter):
		grad = grad_ridge(W, X, Y, _lambda)
		if np.linalg.norm(grad) < epsilon:
			break
		W = W - lr*grad
	return W


def k_fold_cross_validation(X, Y, k, lambdas, algo):
	''' TASK 3
	X 			= input feature matrix [N X D]
	Y 			= output values [N X 1]
	k 			= number of splits to perform while doing kfold cross validation
	lambdas 	= list of scalar parameter lambda
	algo 		= one of {coord_grad_descent, ridge_grad_descent}
	Return a list of average SSE values (on validation set) across various datasets obtained from k equal splits in X, Y 
	on each of the lambdas given 
	'''
	n = int((np.shape(X))[0]/k)

	all_SSE = []
	for _lambda in lambdas:
		SSE_list = []
		for i in range(k):
			validX = X[i*n:(i+1)*n, :]
			validY = Y[i*n:(i+1)*n]
			if i==0:
				trainX = X[n:,:]
				trainY = Y[n:]
			elif i==k-1:
				trainX = X[:(k-1)*n,:]
				trainY = Y[:(k-1)*n]
			else:
				trainX = np.concatenate([ X[:i*n,:], X[(i+1)*n:,:] ])
				trainY = np.concatenate([ Y[:i*n], Y[(i+1)*n:] ])
			W = algo(trainX, trainY, _lambda)
			error = validY - np.matmul(validX, W)
			SSE_list.append( (np.linalg.norm(error))**2 )

		all_SSE.append(np.mean(np.array(SSE_list)))

	return all_SSE

def coord_grad_descent(X, Y, _lambda, max_iter=1000):
	''' TASK 4
	X 			= input feature matrix [N X D]
	Y 			= output values [N X 1]
	_lambda 	= scalar parameter lambda
	max_iter 	= maximum number of iterations of gradient descent to run in case of no convergence
	Return the trained weight vector [D X 1] after performing gradient descent using Ridge Loss Function 
	'''
	N = (np.shape(X))[0]
	D = (np.shape(X))[1]
	X_square = sum(X*X+0.01);
	W = np.ones( (D, 1) )
	for i in range(max_iter):
		for k in range(D):
			X_column = np.reshape(X[:,k], (N, 1))
			Wk = np.matmul(np.transpose(X_column), Y-np.matmul(X, W))[0,0] + W[k,0]*X_square[k]
			if Wk < -_lambda/2:
				Wk = (Wk + _lambda/2)/X_square[k]
			elif Wk > _lambda/2:
				Wk = (Wk - _lambda/2)/X_square[k]
			else:
				Wk = 0
			W[k,0] = Wk

	return W

if __name__ == "__main__":
	# Do your testing for Kfold Cross Validation in by experimenting with the code below 
	X, Y = read_data("./dataset/train.csv")
	X, Y = preprocess(X, Y)
	trainX, trainY, testX, testY = separate_data(X, Y)
	
	# lambdas =  [100000,150000,200000,250000,300000,350000,400000,450000,500000,550000] # Assign a suitable list Task 5 need best SSE on test data so tune lambda accordingly
	# scores = k_fold_cross_validation(trainX, trainY, 6, lambdas, coord_grad_descent)
	# plot_kfold(lambdas, scores)
	W1 = ridge_grad_descent(trainX,trainY,12)
	W2 = coord_grad_descent(trainX,trainY,350000)
	print("Ridge", sse(testX,testY,W1))
	print("Coord", sse(testX,testY,W2))