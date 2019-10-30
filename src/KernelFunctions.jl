module KernelFunctions

export kernel, kernelmatrix, kernelmatrix!, kerneldiagmatrix, kerneldiagmatrix!, kappa
export Kernel
export ConstantKernel, WhiteKernel, ZeroKernel
export SqExponentialKernel, ExponentialKernel, GammaExponentialKernel
export ExponentiatedKernel
export MaternKernel, Matern32Kernel, Matern52Kernel
export LinearKernel, PolynomialKernel
export RationalQuadraticKernel, GammaRationalQuadraticKernel
export KernelSum, KernelProduct



using Distances, LinearAlgebra
using SpecialFunctions: lgamma, besselk
using StatsFuns: logtwo
using PDMats: PDMat

const defaultobs = 2

include("utils.jl")
include("distances/dotproduct.jl")
include("distances/delta.jl")
include("transform/transform.jl")


abstract type Kernel{T,Tr<:Transform} end

kernels = ["exponential","matern","polynomial","constant","rationalquad","exponentiated"]
for k in kernels
    include(joinpath("kernels",k*".jl"))
end
include("matrix/kernelmatrix.jl")
include("kernels/kernelsum.jl")
include("kernels/kernelproduct.jl")

include("generic.jl")


end
