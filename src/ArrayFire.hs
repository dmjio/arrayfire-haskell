--------------------------------------------------------------------------------
-- |
-- Module      : ArrayFire
-- Copyright   : David Johnson (c) 2019-2020
-- License     : BSD3
-- Maintainer  : David Johnson <code@dmj.io>
-- Stability   : Experimental
-- Portability : GHC
--
-- <<https://user-images.githubusercontent.com/875324/59819703-0fbaf980-92f7-11e9-8f53-adebea590bfb.png>>
--
--------------------------------------------------------------------------------
module ArrayFire
  ( -- * Tutorial
    -- $tutorial

    -- ** Modules
    -- $modules

    -- ** Exceptions
    -- $exceptions

    -- ** Construction
    -- $construction

    -- ** Laws
    -- $laws

    -- ** Conversion
    -- $conversion

    -- ** Serialization
    -- $serialization

    -- ** Device
    -- $device
    module ArrayFire.Algorithm
  , module ArrayFire.Arith
  , module ArrayFire.Array
  , module ArrayFire.Backend
  , module ArrayFire.BLAS
  , module ArrayFire.Data
  , module ArrayFire.Device
  , module ArrayFire.Features
  , module ArrayFire.Graphics
  , module ArrayFire.Image
  , module ArrayFire.Index
  , module ArrayFire.LAPACK
  , module ArrayFire.Random
  , module ArrayFire.Signal
  , module ArrayFire.Sparse
  , module ArrayFire.Statistics
  , module ArrayFire.Types
  , module ArrayFire.Util
  , module ArrayFire.Vision
  , module Foreign.C.Types
  , module Data.Int
  , module Data.Word
  , module Data.Complex
  , module Foreign.Storable
  ) where

import ArrayFire.Algorithm
import ArrayFire.Arith
import ArrayFire.Array
import ArrayFire.Backend
import ArrayFire.BLAS
import ArrayFire.Data
import ArrayFire.Device
import ArrayFire.Features
import ArrayFire.Graphics
import ArrayFire.Image
import ArrayFire.Index
import ArrayFire.LAPACK
import ArrayFire.Random
import ArrayFire.Signal
import ArrayFire.Sparse
import ArrayFire.Statistics
import ArrayFire.Types
import ArrayFire.Util
import ArrayFire.Vision
import ArrayFire.Orphans ()
import Foreign.Storable
import Foreign.C.Types
import Data.Int
import Data.Complex
import Data.Word

-- $tutorial
--
-- [ArrayFire](http://arrayfire.org/docs/gettingstarted.htm) is a high performance parallel computing library that features modules for statistical and numerical methods.
-- Example usage is depicted below.
--
-- @
-- module Main where
--
-- import qualified ArrayFire as A
--
-- main :: IO ()
-- main = print $ A.matrix @Double (3,2) [[1,2,3],[4,5,6]]
-- @
--
-- Each 'Array' is constructed and displayed in column-major order.
--
-- @
-- ArrayFire Array
-- [3 2 1 1]
--    1.0000     4.0000
--    2.0000     5.0000
--    3.0000     6.0000
-- @

-- $modules
--
-- All child modules are re-exported top-level in the "ArrayFire" module.
-- We recommend importing "ArrayFire" qualified so as to avoid naming collisions.
--
-- >>> import qualified ArrayFire as A
--

-- $exceptions
--
-- @
-- {\-\# LANGUAGE TypeApplications \#\-}
-- module Main where
--
-- import qualified ArrayFire         as A
-- import           Control.Exception ( catch )
--
-- main :: IO ()
-- main = A.printArray action \`catch\` (\\(e :: A.AFException) -> print e)
--   where
--     action =
--       A.matrix \@Double (3,3) [[1..],[1..],[1..]]
--         \`A.mul\` A.matrix \@Double (2,2) [[1..],[1..]]
-- @
--
-- The above operation is invalid since the matrix multiply has improper dimensions. The caught exception produces the following error:
--
-- > AFException {afExceptionType = SizeError, afExceptionCode = 203, afExceptionMsg = "Invalid input size"}
--

-- $construction
-- An 'Array' can be constructed using the following smart constructors:
--
-- /Note/: All smart constructors (and ArrayFire internally) assume column-major order.
--
-- @
-- >>> scalar \@Double 2.0
-- ArrayFire Array
-- [1 1 1 1]
--    2.0000
-- @
--
-- @
-- >>> vector \@Double 10 [1..]
-- ArrayFire Array
-- [10 1 1 1]
--     1.0000
--     2.0000
--     3.0000
--     4.0000
--     5.0000
--     6.0000
--     7.0000
--     8.0000
--     9.0000
--    10.0000
-- @
--
-- @
-- >>> matrix \@Double (2,2) [[1,2],[3,4]]
-- ArrayFire Array
-- [2 2 1 1]
--     1.0000     3.0000
--     2.0000     4.0000
-- @
--
-- @
-- >>> cube \@Double (2,2,2) [[[2,2],[2,2]],[[2,2],[2,2]]]
-- ArrayFire Array
-- [2 2 2 1]
--    2.0000     2.0000
--    2.0000     2.0000
--
--    2.0000     2.0000
--    2.0000     2.0000
-- @
--
-- @
-- >>> tensor \@Double (2,2,2,2) [[[[2,2],[2,2]],[[2,2],[2,2]]], [[[2,2],[2,2]],[[2,2],[2,2]]]]
-- ArrayFire Array
-- [2 2 2 2]
--     2.0000     2.0000
--     2.0000     2.0000
--
--     2.0000     2.0000
--     2.0000     2.0000
--
--
--     2.0000     2.0000
--     2.0000     2.0000
--
--     2.0000     2.0000
--     2.0000     2.0000
-- @
--
-- Array construction can use Haskell's lazy lists, since 'take' is called on each dimension before sending to the C API.
--
-- >>> mkArray @Double [5,3] [1..]
-- ArrayFire Array
-- [5 3 1 1]
--    1.0000     6.0000    11.0000
--    2.0000     7.0000    12.0000
--    3.0000     8.0000    13.0000
--    4.0000     9.0000    14.0000
--    5.0000    10.0000    15.0000
--
-- Specifying up to 4 dimensions is allowed (anything higher is ignored).

-- $laws
-- Every 'Array' has an instance of 'Eq', 'Num', 'Fractional', 'Floating' and 'Show'
--
-- 'Num'
--
-- >>> 2.0 :: Array Double
-- ArrayFire Array
-- [1 1 1 1]
--    2.0000
--
-- >>> scalar @Int 1 + scalar @Int 1
-- ArrayFire Array
-- [1 1 1 1]
--         2
--
-- >>> scalar @Int 1 - scalar @Int 1
-- ArrayFire Array
-- [1 1 1 1]
--         0
--
-- >>> scalar @Double 10 / scalar @Double 10
-- ArrayFire Array
-- [1 1 1 1]
--   1.0000
--
-- >>> abs $ scalar @Double (-10)
-- ArrayFire Array
-- [1 1 1 1]
--   10.0000
--
-- >>> negate (scalar @Double 10)
-- ArrayFire Array
-- [1 1 1 1]
--   -10.0000
--
-- >>> fromInteger 1.0 :: Array Double
-- ArrayFire Array
-- [1 1 1 1]
--    1.0000
--
-- 'Eq'
--
-- >>> scalar @Double 1 [10] == scalar @Double 1 [10]
-- True
-- >>> scalar @Double 1 [10] /= scalar @Double 1 [10]
-- False
--
-- 'Floating'
--
-- >>> pi :: Array Double
-- ArrayFire Array
-- [1 1 1 1]
--    3.1416
--
-- >>> A.sqrt pi :: Array Double
-- ArrayFire Array
-- [1 1 1 1]
--    1.7725
--
-- 'Fractional'
--
-- >>> (pi :: Array Double) / pi
-- ArrayFire Array
-- [1 1 1 1]
--    1.000
--
-- >>> recip 0.5 :: Array Double
-- ArrayFire Array
-- [1 1 1 1]
--    2.000
--
-- 'Show'
--
-- >>> 0.0 :: Array Double
-- ArrayFire Array
-- [1 1 1 1]
--    0.000
--

-- $conversion
-- Any 'Array' can be exported into Haskell using `toVector'. This will create a Storable vector suitable for use in other C programs.
--
-- >>> vector :: Vector Double <- toVector <$> randu @Double [10,10]
--

-- $serialization
-- Each 'Array' can be serialized to disk and deserialized from disk efficiently.
--
-- @
-- import qualified ArrayFire as A
-- import           Control.Monad
--
-- main :: IO ()
-- main = do
--   let arr = A.'constant' [1,1,1,1] 10
--   idx <- A.'saveArray' "key" arr "file.array" False
--   foundIndex <- A.'readArrayKeyCheck' "file.array" "key"
--   when (idx == foundIndex) $ do
--     array <- A.'readArrayKey' "file.array" "key"
--     'print' array
--
-- -- ArrayFire Array
-- -- [ 1 1 1 1 ]
-- --         10
-- @
--

-- $device
-- The ArrayFire API is able to see which devices are present, and will by default use the GPU if available.
--
-- >>> afInfo
-- ArrayFire v3.6.4 (OpenCL, 64-bit Mac OSX, build 1b8030c5)
-- [0] APPLE: AMD Radeon Pro 555X Compute Engine, 4096 MB <-- brackets [] signify device being used.
-- -1- APPLE: Intel(R) UHD Graphics 630, 1536 MB
--

-- $visualization
-- The ArrayFire API is able to display visualizations using the Forge library
-- >>> window <- createWindow 800 600 "Histogram"
--
