using JuMP
#using Cbc
using Gurobi
using SparseArrays

include("as_dat_large.jl")
include("as_mod.jl")
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

#optimize!(m)
#unset_binary.(x)
#unset_binary.(z)
#optimize!(m)
"""
Some useful output & functions
"""
m, x, z = build_model()
set_optimizer(m, Gurobi.Optimizer)
set_silent(m)
optimize!(m)
obj_ip = objective_value(m)
solve_time_org = solve_time(m)

m, x, z = build_model(true, false)
set_optimizer(m, Gurobi.Optimizer)
set_silent(m)
optimize!(m)
solve_time_sans_x = solve_time(m)
obj_lp = objective_value(m)

m, x, z = build_model(true, true)
set_optimizer(m, Gurobi.Optimizer)
set_silent(m)
optimize!(m)
solve_time_sans_z = solve_time(m)
obj_fin = objective_value(m)
println("obj_ip = $obj_ip, obj_lp = $obj_lp, obj_fin = $obj_fin")
println("Time with binary x: $solve_time seconds, time without binary x: $solve_time_sans_x seconds, time without binary z or x: $solve_time_sans_z seconds")

x_val = sparse(value.(x.data))
z_val = sparse(value.(z))

println("x  = ")
println(x_val)
println("z = ")
println(z_val)

#add_cut_to_small(m)
