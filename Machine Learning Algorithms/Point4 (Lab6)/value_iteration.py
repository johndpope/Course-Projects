import sys
import numpy as np
f = open(sys.argv[1], "r")
numStates = int(f.readline().rstrip()[10:])
numActions = int(f.readline().rstrip()[11:])
start = int(f.readline().rstrip()[6:])
end = int(f.readline().rstrip()[4:])
transition = {}

while(1):
	txt = f.readline().rstrip()
	if txt[0:10] == "transition":
		tup = txt[11:].split()
		state1 = int(tup[0])
		action = int(tup[1])
		state2 = int(tup[2])
		reward = float(tup[3])
		probability = float(tup[4])

		if (state1, action) in transition:
			transition[(state1, action)].append((state2, reward, probability))
		else:
			transition[(state1, action)] = [(state2, reward, probability)]
	else:
		gamma = float(txt[10:])
		break


V = np.zeros(numStates)
policy = [-1]*numStates
iterations = 0;
while(1):
	oldV = np.copy(V)
	for state1 in range(numStates):
		if state1 == end:
			continue
		list_of_vals = []
		for action in range(numActions):
			srp_list = transition[(state1, action)]
			value = sum( srp[2]*(srp[1] + gamma*oldV[srp[0]]) for srp in srp_list )
			list_of_vals.append(value)
		
		V[state1] = max(list_of_vals)
		policy[state1] = list_of_vals.index(V[state1])

	iterations = iterations+1

	diff = oldV - V
	if max(diff) <= 1e-16 and min(diff) >= -1e-16:
		break

for i in range(numStates):
	print(V[i], policy[i])
print("iterations", iterations)