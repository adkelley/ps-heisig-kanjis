module RTK ( kanjiToKeywords, primsToFrames
           , kanjiToIndices, indicesToFrames
           , updateComponents) where

import Prelude

import Data.Array (difference, elemIndex, head, index, intercalate, intersect, tail, uncons, zipWith, (!!))
import Data.Either (Either(..), note)
import Data.Int.Parse (parseInt, toRadix)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (Pattern(..), split, trim)
import Data.Traversable (traverse)


-- TODO: Can this be a newtype?
type Separator = String
type Keys = Array String
type Values = Array String
type Kanji = Array String
type Keywords = Array String
type Query = Array String
type Indices = Array String
type Components = Array String
type Error = String

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
  note "kanjiToKeywords error" result

kanjiToIndices :: Query -> Kanji -> Indices -> Either Error String
kanjiToIndices query kanji indices = do
  let result = liftA1 (\xs -> intercalate ", " xs) $ 
                 search_rtk query kanji indices
  note "kanjiToIndices error" result

-- | Given an collection of indices return the RTK frames for each
-- | index as a string, otherwise return the error message parameter
indicesToFrames :: Query -> Keys -> Values -> Either Error String
indicesToFrames query indices kanji = do
  let mxs = search_rtk query indices kanji 
  case mxs of
    Just xs -> Right $ intercalate " " $ 
      zipWith (<>) xs $ (\x -> "[" <> x <> "]") <$> query
    Nothing -> Left "indicesToFrames error"


-- | Given an collection of RTK primitives return the RTK frames for all
-- | kanji containings these primitives, otherwise return the error 
-- | message parameter
-- | Primaitives are separated by ';'
primsToFrames 
  :: Query
  -> Components
  -> Kanji
  -> Either Error String
primsToFrames ps cs ks = Right $ go cs ks 1 ""
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

updateComponents
  :: Query
  -> Components
  -> Either Error String
updateComponents q cs =
  let
    radix10 = toRadix 10
    index = head q >>=
            (\i -> parseInt i radix10) #
            liftA1 (\x -> x - 1) #
            fromMaybe (-1) 
    mbComponent = cs !! index
    primitives = fromMaybe "" $ q !! 1
    in
     case mbComponent of
       Just component -> Right component
       Nothing -> Right "error"
