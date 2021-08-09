module RTK ( kanjiToKeywords, primsToFrames
           , kanjiToIndices, indicesToFrames) where

import Prelude

import Data.Array (difference, elemIndex, head, index, intercalate, intersect, tail, uncons, zipWith)
import Data.Either (Either(..), note)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (Pattern(..), split, trim)
import Data.Traversable (traverse)
import Effect.Exception (error, Error)


-- TODO: Can this be a newtype?
type Separator = String
type Keys = Array String
type Values = Array String
type Kanji = Array String
type Keywords = Array String
type Query = Array String
type Indices = Array String
type Components = Array String

search_rtk 
  :: Array String 
  -> Keys 
  -> Values 
  -> Maybe Values
search_rtk query keys values =
  traverse (\x -> elemIndex x keys >>= index values) query


kanjiToKeywords :: Query -> Kanji -> Keywords -> Either Error String
kanjiToKeywords query kanji keywords = do
  let result = liftA1 (\xs -> intercalate ", " xs) $ 
                 search_rtk query kanji keywords
  note (error "kanjiToKeywords error") result

kanjiToIndices :: Query -> Kanji -> Indices -> Either Error String
kanjiToIndices query kanji indices = do
  let result = liftA1 (\xs -> intercalate ", " xs) $ 
                 search_rtk query kanji indices
  note (error "kanjiToIndices error") result

-- | Given an collection of indices return the RTK frames for each
-- | index as a string, otherwise return the error message parameter
indicesToFrames :: Query -> Keys -> Values -> Either Error String
indicesToFrames query indices kanji = do
  let mxs = search_rtk query indices kanji 
  case mxs of
    Just xs -> Right $ intercalate " " $ 
      zipWith (<>) xs $ (\x -> "[" <> x <> "]") <$> query
    Nothing -> Left $ error "indicesToFrames error"


-- | Given an collection of RTK primitives return the RTK frames for all
-- | kanji containings these primitives
-- TODO: include kanji that are themselves primitives in the results
primsToFrames 
  :: Query
  -> Components
  -> Kanji
  -> Either Error String
primsToFrames ps cs ks = Right $ go cs ks 1 ""
  where
    components s = trim <$> split (Pattern "...") s
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
