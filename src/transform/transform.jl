export Transform, IdentityTransform, ScaleTransform, LowRankTransform, FunctionTransform, ChainTransform
export transform

"""
```julia
    transform(t::Transform, X::AbstractMatrix)
    transform(k::Kernel, X::AbstractMatrix)
```
Apply the transfomration `t` or `k.transform` on the input `X`
"""
transform

include("scaletransform.jl")
include("lowranktransform.jl")
include("functiontransform.jl")
include("selecttransform.jl")

"""
Chain a series of transform, here `t1` will be called first
```
    t1 = ScaleTransform()
    t2 = LowRankTransform(rand(3,4))
    ct = ChainTransform([t1,t2]) #t1 will be called first
    ct == t2∘t1
```
"""
struct ChainTransform <: Transform
    transforms::Vector{Transform}
end

Base.length(t::ChainTransform) = length(t.transforms) #TODO Add test

function ChainTransform(v::AbstractVector{<:Transform})
    ChainTransform(v)
end

function ChainTransform(v::AbstractVector{<:Type{<:Transform}},θ::AbstractVector)
    ChainTransform(v.(θ))
end

function transform(t::ChainTransform,X::T,obsdim::Int=defaultobs) where {T}
    Xtr = copy(X)
    for tr in t.transforms
        Xtr = transform(tr,Xtr,obsdim)
    end
    return Xtr
end

set_params!(t::ChainTransform,θ) = set_params!(t.transforms,θ)
params(t::ChainTransform) = (base_transform(t.transforms),params.(t.transforms))

Base.:∘(t₁::Transform,t₂::Transform) = ChainTransform([t₂,t₁])
Base.:∘(t::Transform,tc::ChainTransform) = ChainTransform(vcat(tc.transforms,t)) #TODO add test
Base.:∘(tc::ChainTransform,t::Transform) = ChainTransform(vcat(t,tc.transforms))

"""
IdentityTransform
Return exactly the input
"""
struct IdentityTransform <: Transform end

params(t::IdentityTransform) = nothing

transform(t::IdentityTransform,x::AbstractArray,obsdim::Int=defaultobs) = x #TODO add test

### TODO Maybe defining adjoints could help but so far it's not working


# @adjoint function ScaleTransform(s::T) where {T<:Real}
#     @check_args(ScaleTransform, s, s > zero(T), "s > 0")
#     ScaleTransform{T}(s),Δ->ScaleTransform{T}(Δ)
# end
#
# @adjoint function ScaleTransform(s::A) where {A<:AbstractVector{<:Real}}
#     @check_args(ScaleTransform, s, all(s.>zero(eltype(A))), "s > 0")
#     ScaleTransform{A}(s),Δ->begin; @show Δ,size(Δ); ScaleTransform{A}(Δ); end
# end

# @adjoint transform(t::ScaleTransform{<:AbstractVector{<:Real}},x::AbstractVector{<:Real}) = transform(t,x),Δ->(ScaleTransform(nothing),t.s.*Δ)
#
#     @adjoint transform(t::ScaleTransform{<:AbstractVector{<:Real}},X::AbstractMatrix{<:Real},obsdim::Int) = transform(t,X,obsdim),Δ->begin
#     @show Δ,size(Δ);
#     return (obsdim == 1 ? ScaleTransform()Δ'.*X : ScaleTransform()Δ.*X,transform(t,Δ,obsdim),nothing)
#     end
#
# @adjoint transform(t::ScaleTransform{T},x::AbstractVecOrMat,obsdim::Int) where {T<:Real} = transform(t,x), Δ->(ScaleTransform(one(T)),t.s.*Δ,nothing)
