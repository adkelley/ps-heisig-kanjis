--module RTK (query_rtk, frames, prims) where
module RTK where

import Prelude

import Data.Array (elemIndex, index, intercalate
                  , zipWith, zip, intersect, difference
                  )
import Data.Maybe (Maybe (..))
import Data.Foldable (foldr)
import Data.String (Pattern (..), split, trim)
import Data.Traversable (traverse)
import Data.Tuple (Tuple (..))
import Data.Tuple.Nested ((/\))

-- TODO: Can this be a newtype?
type Query = Array String
type Indices = Array String
type Separator = String
type Keys = Array String
type Values = Array String

search_rtk 
  :: Array String 
  -> Keys 
  -> Values 
  -> Maybe Values
search_rtk query keys values =
  traverse (\x -> elemIndex x keys >>= index values) query

rtk_result :: String -> Maybe String -> String
rtk_result errMsg result = 
  case result of
    Just s -> s
    Nothing -> errMsg

-- | Given a query, keys and values, find the query's values
-- | and append them into a string using a separator. If there's
-- | and error then return the error message parameter
query_rtk :: Query -> Keys -> Values -> String -> String -> String
query_rtk query keys values separator errMsg = 
  rtk_result errMsg $ 
    liftA1 (\xs -> intercalate separator xs) $ 
    search_rtk query keys values

-- | given an collection of indices return the RTK frames for each
-- | index as a string, otherwise return the error message parameter
frames :: Query -> Keys -> Values -> String -> String -> String
frames query indices kanji separator errMsg = do
  let mxs = search_rtk query indices kanji 
  case mxs of
    Just xs -> intercalate separator $ 
      zipWith (<>) xs $ (\x -> "[" <> x <> "]") <$> query
    Nothing -> errMsg


prims 
  :: Array String 
  -> Array String 
  -> Array String 
  -> Array String
  -> String
prims ps cs ks is = go
  where
    components s = trim <$> split (Pattern ";") s
    isSubset xs = [] == (difference ps $ intersect ps xs)
    frame :: Tuple (Array String) (Tuple String String) -> String
    frame (Tuple c (Tuple k i)) = 
      if (isSubset c)
        then k <> "[" <> i <> "]"
        else ""
    fs = zipWith (\x y -> components x /\ y) cs $ zip ks is
    go = foldr (\x -> (<>) (frame x)) "" fs
