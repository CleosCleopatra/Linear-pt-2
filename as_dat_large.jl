# Sets
Components = 1:10 # 10 components, set of components in the system

# Parameters
T = 125    #number of timesteps in planning period
d = ones(1,T)*20      #cost of a maintenance occasion
c = [34 25 14 21 16  3 10  5  7 10]'*ones(1,T)     #costs of new components
U = [42 18 90 94 49 49 34 90 37 11]     #life of a new component of type i measured in num time steps.
