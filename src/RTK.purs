module RTK ( query_rtk, kanjiToKeywords, primsToFrames
           , kanjiToIndices, indicesToFrames) where

import Prelude

import Data.Array (elemIndex, index, intercalate, uncons
                  , zipWith, intersect, difference
                  , head, tail
                  )
import Data.Maybe (Maybe (..), fromMaybe)
import Data.String (Pattern (..), split, trim)
import Data.Traversable (traverse)

import Types (Kanji, Keywords, Query, Indices)

-- TODO: Can this be a newtype?
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

kanjiToKeywords :: Query -> Kanji -> Keywords -> String
kanjiToKeywords query kanji keywords = do
  let errMsg = "Usage: node index.js -k 熟語"
  query_rtk query kanji keywords ", " errMsg

kanjiToIndices :: Query -> Kanji -> Indices -> String
kanjiToIndices query kanji indices = do
  let errMsg = "Usage: node index.js -i 10 20"
  query_rtk query kanji indices ", " errMsg

-- | given an collection of indices return the RTK frames for each
-- | index as a string, otherwise return the error message parameter
indicesToFrames :: Query -> Keys -> Values -> String
indicesToFrames query indices kanji = do
  let mxs = search_rtk query indices kanji 
  case mxs of
    Just xs -> intercalate " " $ 
      zipWith (<>) xs $ (\x -> "[" <> x <> "]") <$> query
    Nothing -> "Usage: node index.js -f 10 20"


primsToFrames 
  :: Array String 
  -> Array String 
  -> Array String 
  -> String
primsToFrames ps cs ks = go cs ks 1 ""
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
