module ValidateArgs (isPrimitives, isJukugo, isIndices, isIndexPrim) where

import Prelude

import Data.Array (head, tail)
import Data.Either (Either(..))
import Data.Int.Parse (parseInt, toRadix)
import Data.Maybe (fromMaybe)
import Data.String.Regex (regex, test, parseFlags)
import Data.Traversable (traverse)

type Error = String

isIndex :: String -> Either Error String
isIndex index = do
  let i = fromMaybe 0 $ parseInt index $ toRadix 10 
  if (i > 0 && i < 3001)
    then Right index
    else Left "Indices must be > 0 and < 3001"
  
  
-- | A RTK index should be an integer > 0 and < 3001
-- | Indices are separated by spaces
isIndices :: Array String -> Either Error (Array String)
isIndices = traverse (\i -> isIndex i) 

-- UNICODE RANGE : DESCRIPTION
-- 
-- 3000-303F : punctuation
-- 3040-309F : hiragana
-- 30A0-30FF : katakana
-- FF00-FFEF : Full-width roman + half-width katakana
-- 4E00-9FAF : Common and uncommon kanji
-- 
-- Non-Japanese punctuation/formatting characters commonly used in Japanese text
-- 2605-2606 : Stars
-- 2190-2195 : Arrows
-- u203B     : Weird asterisk thing
isJukugo :: Array String -> Either Error (Array String)
isJukugo args = 
  traverse (\k -> isKanji k) args
  where
    isKanji :: String -> Either Error String
    isKanji k = do
      let expression = regex "[\\u4E00-\\u9FAF]" $ parseFlags "g" 
      case expression of
        Right e ->
          if (test e k)
            then Right k
            else Left "A jukugo must be a kanji character or kanji compound"
        Left s -> Left s


-- | An RTK primitive must be lower case english string
isPrimitives :: Array String -> Either Error (Array String)
isPrimitives args = 
  traverse (\p -> isPrimitive p) args
  where 
    isPrimitive :: String -> Either Error String
    isPrimitive p = do
      let expression = regex "[a-z]" $ parseFlags "g" 
      case expression of
        Right e -> if (test e p)
                    then Right p
                    else Left "Primitives must be lower case english strings"
        Left s -> Left s


---- | Valididate that arguements contain a valid index and primitives 
isIndexPrim :: Array String -> Either Error (Array String)
isIndexPrim args = 
  case mbIndex of
    Right _ -> indexPrims
    Left e -> Left e
  where
    mbIndex = isIndex $ fromMaybe "0" $ head args
    tailArgs = fromMaybe [""] $ tail args
    indexPrims =
      case isPrimitives(tailArgs) of
        Right _ -> Right args
        Left e -> Left e
