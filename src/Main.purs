module Main (main) where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Class (liftEffect)
--import Effect.Class.Console as Console
import Data.Either (Either (..), either)

import OSX.Utils (pbcopy, pbpaste)
import Params (cmdLineParser)
import RTK (indicesToFrames, kanjiToIndices, kanjiToKeywords, primsToFrames)
import Google.Auth (Client, auth)
import Google.JWT (jwt)
import Types (RTKData, RTKArgs, Error)

foreign import _gsRun :: Client -> EffectFnAff RTKData


gsRun :: Client -> Aff RTKData
gsRun client = fromEffectFnAff $ _gsRun client

work :: RTKArgs -> RTKData -> Either Error String
work {cmd, args} rtk =
  case cmd of
    "-p" -> primsToFrames args rtk.components rtk.kanji
    "-f" -> indicesToFrames args rtk.indices rtk.kanji
    "-k" -> kanjiToKeywords args rtk.kanji rtk.keywords
    "-i" -> kanjiToIndices args rtk.kanji rtk.indices
    _ -> Left "Something went wrong!"

main :: Effect Unit
main = launchAff_ do
  args <- liftEffect cmdLineParser
  either (\e -> paste $ "Error: " <> e)
         (\as -> doWork as) args
  where 
    paste result = do
      pbcopy result
      pbpaste 

    doWork xs = do
      rtkData <- gsRun =<< auth =<< jwt
      case (work xs rtkData) of
        Right s -> paste s 
        Left e -> paste e
