module Params (cmdLineParser) where

import Prelude

import Data.List (List (..), fromFoldable, drop, (:)) 
import Data.Array (fromFoldable) as A
import Effect (Effect)
import Node.Process (argv)
import Data.String.Common (split)
import Data.String.Pattern (Pattern (..)) 
import Data.Either (Either (..))

import Types (RTKArgs)

args :: Effect (List String)
args = do
  xs <- argv
  pure $ drop 2 $ fromFoldable xs
  

mkArgs :: String -> Array String -> RTKArgs
mkArgs cmd args_ = {cmd, args: args_}

splitNode :: List String -> Array String
splitNode (Nil) = [""]
splitNode (x : _) = 
  split (Pattern "") x

cmdLineParser :: Effect (Either String RTKArgs)
cmdLineParser = do
  args_ <- args
  pure $ case args_ of
    "-p" : rest -> Right $ mkArgs "primsToFrames" $ A.fromFoldable rest
    "-k" : rest -> Right $ mkArgs "kanjiToKeywords" $ splitNode rest
    "-i" : rest -> Right $ mkArgs "kanjiToIndices" $ splitNode rest 
    "-f" : rest -> Right $ mkArgs "indicesToFrames" $ A.fromFoldable rest 
    Nil -> Left $ "Usage: node index.js <cmd> <arguments>"
    _ -> Left $ "Usage: node index.js <cmd> <arguments>"

