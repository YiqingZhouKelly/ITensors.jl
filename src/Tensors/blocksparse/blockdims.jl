export BlockDims,
       blockdim,
       blockdims,
       nblocks

"""
BlockDim

An index for a BlockSparseTensor.
"""
const BlockDim = Vector{Int}

"""
BlockDims{N}

Dimensions used for BlockSparse Tensors.
Each entry lists the block sizes in each dimension.
"""
const BlockDims{N} = NTuple{N,BlockDim}

Base.ndims(ds::Type{<:BlockDims{N}}) where {N} = N

StaticArrays.similar_type(::Type{<:BlockDims},
                          ::Type{Val{N}}) where {N} = BlockDims{N}

"""
dense(::BlockDims) -> Dims

Make the "dense" version of the block indices.
"""
dense(ds::BlockDims) = dims(ds)
dense(::Type{<:BlockDims{N}}) where {N} = Dims{N}

Base.copy(ds::BlockDims) = ds

"""
dim(::BlockDims,::Integer)

Return the total extent of the specified dimensions.
"""
function dim(ds::BlockDims{N},i::Integer) where {N}
  return sum(ds[i])
end

"""
dims(::BlockDims)

Return the total extents of the dense space
the block dimensions live in.
"""
function dims(ds::BlockDims{N}) where {N}
  return ntuple(i->dim(ds,i),Val(N))
end

"""
dim(::BlockDims)

Return the total extent of the dense space
the block dimensions live in.
"""
function dim(ds::BlockDims{N}) where {N}
  return prod(dims(ds))
end

"""
nblocks(::BlockDim)

The number of blocks of the BlockDim.
"""
function nblocks(ind::BlockDim)
  return length(ind)
end

"""
nblocks(::BlockDims,i::Integer)

The number of blocks in the specified dimension.
"""
function nblocks(inds::Tuple,i::Integer)
  return nblocks(inds[i])
end

"""
nblocks(::BlockDims,is)

The number of blocks in the specified dimensions.
"""
function nblocks(inds::Tuple,is::NTuple{N,Int}) where {N}
  return ntuple(i->nblocks(inds,is[i]),Val(N))
end

"""
nblocks(::BlockDims)

A tuple of the number of blocks in each
dimension.
"""
function nblocks(inds::NTuple{N,<:Any}) where {N}
  return ntuple(i->nblocks(inds,i),Val(N))
end

"""
blockdim(::BlockDim,::Integer)

The size of the specified block in the specified
dimension.
"""
function blockdim(ind::BlockDim,
                  i::Integer)
  return ind[i]
end

"""
blockdim(::BlockDims,block,::Integer)

The size of the specified block in the specified
dimension.
"""
function blockdim(inds,
                  block,
                  i::Integer)
  return blockdim(inds[i],block[i])
end

"""
blockdims(::BlockDims,block)

The size of the specified block.
"""
function blockdims(inds,
                   block)
  return ntuple(i->blockdim(inds,block,i),ValLength(inds))
end

"""
blockdim(::BlockDims,block)

The total size of the specified block.
"""
function blockdim(inds,
                  block)
  return prod(blockdims(inds,block))
end

outer(dim1,dim2,dim3,dims...) = outer(outer(dim1,dim2),dim3,dims...)

function outer(dim1::BlockDim,dim2::BlockDim)
  dimR = BlockDim(undef,nblocks(dim1)*nblocks(dim2))
  for (i,t) in enumerate(Iterators.product(dim1,dim2))
    dimR[i] = prod(t)
  end
  return dimR
end

function permuteblocks(dim::BlockDim,perm)
  return dim[perm]
end

#
# This is to help with ITensor compatibility
#

setblockdim!(dim1::BlockDim,newdim::Int,n::Int) = setindex!(dim1,newdim,n)

sim(dim::BlockDim) = copy(dim)

dir(::BlockDim) = 0

dag(dim::BlockDim) = copy(dim)
