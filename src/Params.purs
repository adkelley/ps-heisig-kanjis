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

import Types (RTKArgs)

type Error = String

getArgs :: Effect (List String)
getArgs = do
  xs <- argv
  pure $ drop 2 $ fromFoldable xs
  
-- | A RTK index should be > 0 and < 3001
inRange :: String -> Either Error String
inRange index = do
  let i = fromMaybe 0 $ parseInt index $ toRadix 10 
  if (i > 0 && i < 3001)
    then Right index
    else Left "RTK index must be > 0 and < 3001"


validateIndices :: List String -> Either Error (List String)
validateIndices xs = traverse inRange xs


mkArgs :: String -> Array String -> Either Error RTKArgs
mkArgs cmd args_ = Right {cmd, args: args_}

splitNode :: List String -> Array String
splitNode (Nil) = [""]
splitNode (x : _) = 
  split (Pattern "") x

cmdLineParser :: Effect (Either Error RTKArgs)
cmdLineParser = do
  args_ <- getArgs
  pure $ case args_ of
    "-p" : rest -> mkArgs "primsToFrames" $ A.fromFoldable rest
    "-k" : rest -> mkArgs "kanjiToKeywords" $ splitNode rest
    "-i" : rest -> mkArgs "kanjiToIndices" $ splitNode rest 
    "-f" : rest -> (validateIndices rest) >>= 
                      (\xs -> mkArgs "indicesToFrames" $ A.fromFoldable xs) 
    Nil -> Left $ "Usage: node index.js <cmd> <arguments>"
    _ -> Left $ "Usage: node index.js <cmd> <arguments>"

