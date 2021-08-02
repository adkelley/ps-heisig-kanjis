module ValidateArgs (isPrimitives, isJukugo, isIndices, isIndexPrim) where

import Prelude

import Data.Array (head, tail)
import Data.Either (Either(..))
import Data.Int.Parse (parseInt, toRadix)
import Data.Maybe (fromMaybe)
import Data.String.Regex (regex, test, parseFlags)
import Data.Traversable (traverse)
import Types (Error, CmdArgs)

isIndex :: String -> Either Error String
isIndex index = do
  let i = fromMaybe 0 $ parseInt index $ toRadix 10 
  if (i > 0 && i < 3001)
    then Right index
    else Left "An index must be > 0 and < 3001"
  
-- | A RTK index should be an integer > 0 and < 3001
-- | Indices are separated by spaces
isIndices :: CmdArgs -> Either Error CmdArgs
isIndices {cmd, args} =
  case (traverse (\i -> isIndex i) args) of
    Right xs -> Right {cmd: cmd, args: args}
    Left e -> Left e

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
isJukugo :: CmdArgs -> Either Error CmdArgs
isJukugo {cmd, args} = 
  case (traverse (\k -> isKanji k) args) of
    Right xs -> Right {cmd: cmd, args: args}
    Left e -> Left e
  where
    isKanji :: String -> Either Error String
    isKanji k = do
      expression <- regex "[\\u4E00-\\u9FAF]" $ parseFlags "g" 
      if (test expression k)
        then Right k
        else Left "A jukugo must be a kanji character or kanji compound\n"


-- | An RTK primitive must be lower case english string
isPrimitives :: CmdArgs -> Either Error CmdArgs
isPrimitives {cmd, args} = 
  case (traverse (\p -> isPrimitive p) args) of
    Right _ -> Right {cmd: cmd, args: args}
    Left e -> Left e
  where 
    isPrimitive :: String -> Either Error String
    isPrimitive p = do
      expression <- regex "[a-z]" $ parseFlags "g" 
      if (test expression p)
        then Right p
        else Left "Primitives must be lower case english strings\n"


-- | Valididate that arguements contain a valid index and primitives 
isIndexPrim :: CmdArgs -> Either Error CmdArgs
isIndexPrim {cmd, args} = 
  let 
    mbIndex = isIndex $ fromMaybe "0" $ head args
  in 
   case mbIndex of
     Right index -> 
       case (isPrimitives {cmd, args: ps}) of
         Right tp -> Right {cmd: cmd, args: args}
         Left e -> Left e
        where
          ps = fromMaybe [""] $ tail args
     Left e -> Left e
