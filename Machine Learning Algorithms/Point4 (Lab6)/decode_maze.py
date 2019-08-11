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
		if row[i][j] == 1:
			count_of_1 = count_of_1+1

rev_mapper = {count_0:count for count, count_0 in mapper.items()}

f = open(sys.argv[2], "r")
action = {}
for i in range(numStates-count_of_1):
		action[rev_mapper[i]] = int(f.readline().rstrip().split()[1])

now_i = int(start/size)
now_j = start%size

path = []
while(1):
	if row[now_i][now_j] == 3:
		break
	direction = action[now_i*size+now_j]
	if direction == 0:
		path.append('W')
		now_j = now_j-1
	if direction == 1:
		path.append('E')
		now_j = now_j+1
	if direction == 2:
		path.append('N')
		now_i = now_i-1
	if direction == 3:
		path.append('S')
		now_i = now_i+1

print(*path)