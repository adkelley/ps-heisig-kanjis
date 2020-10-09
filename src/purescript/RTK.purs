--module RTK (query_rtk, frames, prims) where
module RTK where

import Prelude

import Data.Array (elemIndex, index, intercalate, uncons
                  , zipWith, intersect, difference
                  , head, tail
                  )
import Data.Maybe (Maybe (..), fromMaybe)
import Data.String (Pattern (..), split, trim)
import Data.Traversable (traverse)

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
  -> String
prims ps cs ks = go cs ks 1 ""
  where
    components s = trim <$> split (Pattern ";") s
    hasPrims xs = [] == (difference ps $ intersect ps xs)
    frame c k i = 
      if (hasPrims $ components c) 
        then k <> "[" <> i <> "] "
        else ""
    go [] _ _ result = trim result
    go cs' ks' i result = 
      case uncons cs' of
        Just {head: hcs, tail: tcs} -> 
          let 
            hks = fromMaybe "" $ head ks'
            tks = fromMaybe [] $ tail ks'
            s = frame hcs hks $ show i
          in
            go tcs tks (i+1) (result <> s)
        Nothing -> "" -- we never reach here

-- implementation using folds
--prims 
--  :: Array String 
--  -> Array String 
--  -> Array String 
--  -> Array String
--  -> String
--prims ps cs ks is = go
--  where
--    components s = trim <$> split (Pattern ";") s
--    hasPrims xs = [] == (difference ps $ intersect ps xs)
--    frame :: Tuple (Array String) (Tuple String String) -> String
--    frame (Tuple c (Tuple k i)) = 
--      if (hasPrims c)
--        then k <> "[" <> i <> "]"
--        else ""
--    fs = zipWith (\x y -> components x /\ y) cs $ zip ks is
--    go = foldr (\x -> (<>) (frame x)) "" fs
