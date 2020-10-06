module RTK ( find_keywords
           , find_indices
           , find_kanji
           ) where

import Prelude

import Data.Array (elemIndex, index, intercalate)
import Data.Traversable (traverse)
import Data.Maybe (Maybe (..))

type Compound = Array String
type Kanji = Array String
type Keywords = Array String
type Indices = Array String
type Separator = String
type Primitives = Array String

search_rtk :: Compound -> Kanji -> Array String -> Maybe (Array String)
search_rtk compound kanji xs =
  traverse (\x -> elemIndex x kanji >>= index xs) compound

rtk_result :: String -> Maybe String -> String
rtk_result usage result = 
  case result of
    Just s -> s
    Nothing -> usage

intercalate_ :: Separator -> Maybe (Array String) -> Maybe String
intercalate_ separator mas =
  liftA1 (\xs -> intercalate separator xs) mas

-- | Given a compound, find the compound's keywords.
find_keywords :: Compound -> Kanji -> Keywords -> Separator -> String
find_keywords compound kanji keywords separator = 
 rtk_result "Usage: kw 漢字" $
   intercalate_ separator $ 
   search_rtk compound kanji keywords 

-- | Given a compound, find the compound's indices.
find_indices :: Compound -> Kanji -> Indices -> Separator -> String
find_indices compound kanji indices separator = 
  rtk_result "Usage: ix 漢字" $
   intercalate_ separator $ 
   search_rtk compound kanji indices 

find_kanji :: Primitives -> Keywords -> Kanji -> Separator -> String
find_kanji query keywords kanji separator = 
   rtk_result "Usage: kanji Sino- character" $
     intercalate_ separator $
     search_rtk query keywords kanji 
