"""
    xlogx(x)

Return `x * log(x)` for `x ≥ 0`, handling `x == 0` by taking the limit from above, to get zero.
"""
function xlogx(x)
  result = x * log(x)
  ifelse(iszero(x), zero(result), result)
end

"""
    xlogy(x, y)

Return `x * log(y)` for `y > 0`, and zero when `x == 0`.
"""
function xlogy(x, y)
  result = x * log(y)
  ifelse(iszero(x), zero(result), result)
end

@adjoint function broadcasted(::typeof(xlogy), x::Zygote.Numeric, y::Zygote.Numeric)
  res = xlogy.(x, y)
  res, Δ -> (nothing, Zygote.unbroadcast(x, xlogy.(Δ, y)), Zygote.unbroadcast(y, Δ .* x ./ y))
end

# This can be made an error in Flux v0.13, for now just a warning
function match_sizes(ŷ::AbstractArray, y::AbstractArray)
  for d in 1:max(ndims(ŷ), ndims(y)) 
    if size(ŷ,d) != size(y,d)
      @error "size mismatch in loss function! In future this will be an error; in Flux 0.12 broadcasting acceps some mismatches" summary(ŷ) summary(y) maxlog=3 _id=hash(size(y))
    end
  end
end
match_sizes(ŷ, y) = nothing  # pass-through, for constant label e.g. y = 1

Zygote.@nograd match_sizes
