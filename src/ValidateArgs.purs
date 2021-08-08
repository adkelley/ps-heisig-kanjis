module ValidateArgs (validateArgs) where

import Prelude

import Data.Array (head, tail)
import Data.Either (Either(..), either)
import Data.Int.Parse (parseInt, toRadix)
import Data.Maybe (fromMaybe)
import Data.String.Regex (regex, test, parseFlags)
import Data.Traversable (traverse)
import Effect.Exception (Error, error)
import Types (Command(..), CmdArgs)

isIndex :: String -> Either Error String
isIndex index = do
  let i = fromMaybe 0 $ parseInt index $ toRadix 10 
  if (i > 0 && i < 3001)
    then Right index
    else Left $ error "Indices must be > 0 and < 3001"
  
  
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
            else Left $ error "A jukugo must be a kanji character or kanji compound"
        Left s -> Left $ error s


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
                    else Left $ error "Primitives must be lower case english strings"
        Left s -> Left $ error s


---- | Valididate that arguements contain a valid index and primitives 
isIndexPrim :: Array String -> Either Error (Array String)
isIndexPrim args = 
  either (\e -> Left e) (\_ -> indexPrims) mbIndex 
  where
    mbIndex = isIndex $ fromMaybe "0" $ head args
    tailArgs = fromMaybe [""] $ tail args
    indexPrims =
      either (\e -> Left e) (\_ -> Right args) $ isPrimitives tailArgs


validateArgs :: CmdArgs -> Either Error CmdArgs
validateArgs {cmd, args} = 
  case cmd of
    P2F -> validate isPrimitives 
    I2F -> validate isIndices 
    K2K -> validate isJukugo 
    K2I -> validate isJukugo
    UC  -> validate isIndexPrim
  where
    validate
      :: (Array String -> Either Error (Array String))
      -> Either Error CmdArgs
    validate fn =
      either 
      (\e -> Left e)
      (\_ -> Right {cmd, args}) $ fn args
