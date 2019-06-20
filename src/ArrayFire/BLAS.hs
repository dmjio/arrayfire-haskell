{-# LANGUAGE ViewPatterns        #-}
--------------------------------------------------------------------------------
-- |
-- Module      : ArrayFire.BLAS
-- Copyright   : David Johnson (c) 2019-2020
-- License     : BSD 3
-- Maintainer  : David Johnson <djohnson.m@gmail.com>
-- Stability   : Experimental
-- Portability : GHC
--
-- Basic Linear Algebra Subprograms (BLAS) API
--
--------------------------------------------------------------------------------
module ArrayFire.BLAS where

import Data.Complex

import ArrayFire.FFI
import ArrayFire.Internal.BLAS
import ArrayFire.Types

-- | The following applies for Sparse-Dense matrix multiplication.
--
-- This function can be used with one sparse input. The sparse input must always be the lhs and the dense matrix must be rhs.
--
-- The sparse array can only be of AF_STORAGE_CSR format.
--
-- The returned array is always dense.
--
-- optLhs an only be one of AF_MAT_NONE, AF_MAT_TRANS, AF_MAT_CTRANS.
--
-- optRhs can only be AF_MAT_NONE.
--
matmul
  :: Array a
  -- ^ 2D matrix of Array a, left-hand side
  -> Array a
  -- ^ 2D matrix of Array a, right-hand side
  -> MatProp
  -- ^ Left hand side matrix options
  -> MatProp
  -- ^ Right hand side matrix options
  -> Array a
  -- ^ Output of 'matmul'
matmul arr1 arr2 prop1 prop2 = do
  op2 arr1 arr2 (\p a b -> af_matmul p a b (toMatProp prop1) (toMatProp prop2))


-- | Scalar dot product between two vectors. Also referred to as the inner product.
dot
  :: Array a
  -- ^ Left-hand side input
  -> Array a
  -- ^ Right-hand side input
  -> MatProp
  -- ^ Options for left-hand side. Currently only AF_MAT_NONE and AF_MAT_CONJ are supported.
  -> MatProp
  -- ^ Options for right-hand side. Currently only AF_MAT_NONE and AF_MAT_CONJ are supported.
  -> Array a
  -- ^ Output of 'dot'
dot arr1 arr2 prop1 prop2 =
  op2 arr1 arr2 (\p a b -> af_dot p a b (toMatProp prop1) (toMatProp prop2))

-- | Scalar dot product between two vectors. Also referred to as the inner product. Returns the result as a host scalar.
dotAll
  :: Array a
  -- ^ Left-hand side array
  -> Array a
  -- ^ Right-hand side array
  -> MatProp
  -- ^ Options for left-hand side. Currently only AF_MAT_NONE and AF_MAT_CONJ are supported.
  -> MatProp
  -- ^ Options for right-hand side. Currently only AF_MAT_NONE and AF_MAT_CONJ are supported.
  -> Complex Double
  -- ^ Real and imaginary component result
dotAll arr1 arr2 prop1 prop2 = do
  let (real,imag) =
        infoFromArray22 arr1 arr2 $ \a b c d ->
          af_dot_all a b c d (toMatProp prop1) (toMatProp prop2)
  real :+ imag

-- | Transposes a matrix.
transpose
  :: Array a
  -- ^ Input matrix to be transposed
  -> Bool
  -- ^ Should perform conjugate transposition
  -> Array a
  -- ^ The transposed matrix
transpose arr1 (fromIntegral . fromEnum -> b) =
  arr1 `op1` (\x y -> af_transpose x y b)

-- | Transposes a matrix.
--
-- * Warning: This function mutates an array in-place, all subsequent references will be changed. Use carefully.
--
transposeInPlace
  :: Array a
  -- ^ Input matrix to be transposed
  -> Bool
  -- ^ Should perform conjugate transposition
  -> IO ()
transposeInPlace arr (fromIntegral . fromEnum -> b) =
  arr `inPlace` (`af_transpose_inplace` b)
