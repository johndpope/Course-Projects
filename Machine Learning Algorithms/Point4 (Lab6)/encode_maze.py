import sys
import numpy as np
f = open(sys.argv[1], "r")
size = len(f.readline().rstrip().split()) - 2
numStates = size*size
row = []
for i in range(size):
	row.append(f.readline().rstrip().split()[1:-1])
	row[i] = [int(x) for x in row[i]]
	if 2 in row[i]:
		start = i*size + row[i].index(2)
	if 3 in row[i]:
		end = i*size + row[i].index(3)

mapper = {}
count_of_1 = 0
count_of_0 = 0
for i in range(size):
	for j in range(size):
		if row[i][j] == 0 or row[i][j] == 2 or row[i][j] == 3:
			mapper[i*size+j] = count_of_0
			count_of_0 = count_of_0+1
		if row[i][j] == 2:
			start = start - count_of_1
		if row[i][j] == 3:
			end = end - count_of_1
		if row[i][j] == 1:
			count_of_1 = count_of_1+1

print("numStates", numStates-count_of_1)
print("numActions", 4) #0:N, 1:E, 2:S, 3:W
print("start", start)
print("end", end)

gamma = 1.0
reward_0 = -1.0
reward_1 = -1000.0

count_of_1 = 0
for i in range(size):
	for j in range(size):
		if row[i][j] == 1 or row[i][j] == 3:
			continue

		if i==0: #all North
			print("transition", mapper[i*size+j], 2, mapper[i*size+j], reward_1, 1)
		elif row[i-1][j] == 1:
			print("transition", mapper[i*size+j], 2, mapper[i*size+j], reward_1, 1)
		elif row[i-1][j] == 0 or row[i-1][j] == 2 or row[i-1][j] == 3:
			print("transition", mapper[i*size+j], 2, mapper[(i-1)*size+j], reward_0, 1)

		if j==size-1: #all East
			print("transition", mapper[i*size+j], 1, mapper[i*size+j], reward_1, 1)
		elif row[i][j+1] == 1:
			print("transition", mapper[i*size+j], 1, mapper[i*size+j], reward_1, 1)
		elif row[i][j+1] == 0 or row[i][j+1] == 2 or row[i][j+1] == 3:
			print("transition", mapper[i*size+j], 1, mapper[i*size+j+1], reward_0, 1)

		if i==size-1: #all South
			print("transition", mapper[i*size+j], 3, mapper[i*size+j], reward_1, 1)
		elif row[i+1][j] == 1:
			print("transition", mapper[i*size+j], 3, mapper[i*size+j], reward_1, 1)
		elif row[i+1][j] == 0 or row[i+1][j] == 2 or row[i+1][j] == 3:
			print("transition", mapper[i*size+j], 3, mapper[(i+1)*size+j], reward_0, 1)

		if j==0: #all West
			print("transition", mapper[i*size+j], 0, mapper[i*size+j], reward_1, 1)
		elif row[i][j-1] == 1:
			print("transition", mapper[i*size+j], 0, mapper[i*size+j], reward_1, 1)
		elif row[i][j-1] == 0 or row[i][j-1] == 2 or row[i][j-1] == 3:
			print("transition", mapper[i*size+j], 0, mapper[i*size+j-1], reward_0, 1)

print("discount ", gamma)