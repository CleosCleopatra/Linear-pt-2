"""
  Construct and returns the model of this assignment.
"""
function build_model(relax_x::Bool = false, relax_z::Bool = false)
  #Components - the set of components
  #T - the number of time steps in the model
  #d[1,..,T] - cost of a maintenance occasion
  #c[Components, 1,..,T] - costs of new components
  #U[Components] - lives of new components
  m = Model()
  if relax_x
    @variable(m, x[Components, 1:T] >= 0)
  else
    @variable(m, x[Components, 1:T] >= 0, Bin)
  end
  if relax_z
      @variable(m, z[1:T] <= 1)
  else
      @variable(m, z[1:T] <= 1, Bin)
  end
  cost = @objective(m, Min,
    sum(c[i, t]*x[i, t] for i in Components, t in 1:T) + sum(d[t]*z[t] for t in 1:T))

  ReplaceWithinLife = @constraint(m,
    [i in Components, ell in 0:(T-U[i]); T >= U[i]],
    sum(x[i,t] for t in (ell .+ (1:U[i]))) >= 1)

  ReplaceOnlyAtMaintenance = @constraint(m, [i in Components, t in 1:T],
  x[i,t] <= z[t])

  return m, x, z
end
"""
  Adds the constraint:  z[1] + x[1,2] + x[2,2] + x[1,3] + x[2,3] + z[4] >= 2
  which is a VI for the small instance
"""
function add_cut_to_small(m::Model)
  @constraint(m, z[1] + x[1,2] + x[2,2] + x[1,3] + x[2,3] + z[4] >= 2)
end
