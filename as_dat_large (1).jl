# Sets
Components = 1:10 # 10 components

# Parameters
T = 150    #number of timesteps
d = ones(1,T)*20      #cost of a maintenance occasion
c = [34 25 14 21 16  3 10  5  7 10]'*ones(1,T)     #costs of new components
U = [42 18 90 94 49 49 34 90 37 11]     #lives of new components
