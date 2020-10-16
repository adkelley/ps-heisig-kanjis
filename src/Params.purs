module Params (cmdLineParser) where

import Prelude

import Data.List (List (..), fromFoldable, drop, (:)) 
import Data.Traversable (traverse)
import Data.Array (fromFoldable) as A
import Effect (Effect)
import Node.Process (argv)
import Data.String.Common (split)
import Data.String.Pattern (Pattern (..)) 
import Data.Either (Either (..))
import Data.Maybe (fromMaybe)
import Data.Int.Parse (parseInt, toRadix)
import Data.String.Regex (regex, test, parseFlags)

import Types (RTKArgs)

type Error = String

getArgs :: Effect (List String)
getArgs = do
  xs <- argv
  pure $ drop 2 $ fromFoldable xs
  
-- | A RTK index should be an integer > 0 and < 3001
inRange :: String -> Either Error String
inRange index = do
  let i = fromMaybe 0 $ parseInt index $ toRadix 10 
  if (i > 0 && i < 3001)
    then Right index
    else Left "RTK index must be integer > 0 and < 3001"


validateIndices :: List String -> Either Error (List String)
validateIndices = traverse inRange

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


isKanji :: String -> Either Error String
isKanji kanji = do 
  expression <- regex "[\\u4E00-\\u9FAF]" $ parseFlags "g" 
  if (test expression kanji)
    then Right kanji
    else Left "Invalid jukugo"


validateJukugo :: List String -> Either Error (List String)
validateJukugo = traverse isKanji


mkArgs :: String -> Array String -> Either Error RTKArgs
mkArgs cmd args_ = Right {cmd, args: args_}

splitNode :: List String -> Array String
splitNode (Nil) = [""]
splitNode (x : _) = 
  split (Pattern "") x

cmdLineParser :: Effect (Either Error RTKArgs)
cmdLineParser = do
  args <- getArgs
  pure $ case args of
    "-p" : rest -> mkArgs "primsToFrames" $ A.fromFoldable rest
    "-k" : rest -> (validateJukugo rest) >>=
                       (\xs -> mkArgs "kanjiToKeywords" $ splitNode xs)
    "-i" : rest -> (validateJukugo rest) >>= 
                     (\xs -> mkArgs "kanjiToIndices" $ splitNode xs) 
    "-f" : rest -> (validateIndices rest) >>= 
                      (\xs -> mkArgs "indicesToFrames" $ A.fromFoldable xs) 
    Nil -> Left $ "Usage: node index.js <cmd> <arguments>"
    _ -> Left $ "Usage: node index.js <cmd> <arguments>"

