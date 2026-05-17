using JuMP
#using Cbc
using Gurobi
using SparseArrays

include("as_dat_small.jl")
include("as_mod.jl")
m, x, z = build_model()
set_optimizer(m, Gurobi.Optimizer)
# set_optimizer_attributes(m, "MIPGap" => 2e-2, "TimeLimit" => 3600)
"""
Some useful parameters for the Gurobi solver:
    SolutionLimit = k : the search is terminated after k feasible solutions has been found
    MIPGap = r : the search is terminated when  | best node - best integer | < r * | best node |
    MIPGapAbs = r : the search is terminated when  | best node - best integer | < r
    TimeLimit = t : limits the total time expended to t seconds
    DisplayInterval = t : log lines are printed every t seconds
See http://www.gurobi.com/documentation/8.1/refman/parameters.html for a
complete list of valid parameters
"""

optimize!(m)
unset_binary.(x)
unset_binary.(z)
optimize!(m)
"""
Some useful output & functions
"""
# obj_ip = objective_value(m)
# unset_binary.(x)
# unset_binary.(z)
# optimize!(m)
# obj_lp = objective_value(m)
# println("obj_ip = $obj_ip, obj_lp = $obj_lp, gap = $(obj_ip-obj_lp) ")

# println(solve_time(m))

# x_val = sparse(value.(x.data))
# z_val = sparse(value.(z))

#println("x  = ")
#println(x_val)
#println("z = ")
#println(z_val)

#add_cut_to_small(m)



using JuMP      #load the package JuMP
   #load the package Clp (an open linear-programming solver)
using Gurobi   #The commercial optimizer Gurobi requires installation

"""
  Construct and returns the model of this assignment.
"""
include(parameter_value)

function build_model(parameter_value::String)
  # The diet problem
  crop2idx = Dict{String,Int64}()
  fuel2idx = Dict{String,Int64}()
  for i in I
    crop2idx[crops[i]] = i
  end
  for j in J
    fuel2idx[fuels[j]] = j
  end
  #I: set of  crops
  #J: set of fuels
  #crops: name of the foods, i in I
  #fuels: name of the fuels, j in J

  _y(i) = y[crop2idx[i]]
  _w(i) = w[crop2idx[i]]
  _o(i) = o[crop2idx[i]]

  _f(j) = f[fuel2idx[j]]
  _c(j) = c[fuel2idx[j]]
  _t(j) = t[fuel2idx[j]]

  _A_max = A_max
  _M_c = M_c
  _P_c = P_c
  _D_max = D_max
  _W_max = W_max
  _F_min = F_min

  m = Model()

  @variable(m, a[crops] >= 0) #Area for each crop
  A_tot = sum(a[i] for i in crops)
  A_constraint = @constraint(m, A_tot <= _A_max)
  W_tot = sum(a[i] * _w(i) for i in crops)
  W_constraint = @constraint(m, W_tot <= _W_max)
  V = sum(_y(i) * a[i] * _o(i) for i in crops)
  B_tot = 0.9 * V
  M = 0.2 * V
  @variable(m, B[fuels] >= 0) #Amount of the differnt fuel types
  @constraint(m, sum(B[j] * _f(j) for j in fuels)<= B_tot)
  D = sum(B[j] * (1 - _f(j)) for j in fuels)
  D_constraint =@constraint(m, D <= _D_max)

  @objective(m, Max, sum(_c(j) * B[j] * (1-_t(j)) for j in fuels) - D*_P_c - M * _M_c)

  @constraint(m, sum(B[j] for j in fuels) >= _F_min)

  return m, a, B, D, M, A_tot, W_tot, W_constraint, A_constraint, D_constraint
end

include("parameter_values.jl")

m, a, B, D, M, A_tot, W_tot, W_constraint, A_constraint, D_constraint = build_model("parameter_values.jl")
print(m) # prints the model instance

set_optimizer(m, Gurobi.Optimizer)
set_optimizer_attribute(m, "OutputFlag", 1)
optimize!(m)
dual_water = dual(W_constraint)
dual_area = dual(A_constraint)
dual_petrol = dual(D_constraint)

println("Dual water = ", dual_water)
println("Dual area = ", dual_area)
println("Dual petrol = ", dual_petrol)

println("Objective value =  ", objective_value(m))   		# display the optimal solution
println("area for each crop =  ", value.(a.data))               
println("fuel amounts =  ", value.(B.data)) 
println("petrol diesel amount =  ", value(D))
println("water demand =  ", value(W_tot))
println("Area used =  ", value(A_tot))
println("Methanol amount =  ", value(M)) 