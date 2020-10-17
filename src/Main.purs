module Main (main) where

import Prelude

import Data.Either (either)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console

import OSX.Utils (pbcopy, pbpaste)
import Params (cmdLineParser)
import RTK (indicesToFrames, kanjiToIndices, kanjiToKeywords, primsToFrames)
import Google.Auth (Client, auth)
import Google.JWT (jwt)
import Types (RTKData, RTKArgs)

foreign import _gsRun :: Client -> EffectFnAff RTKData


gsRun :: Client -> Aff RTKData
gsRun client = fromEffectFnAff $ _gsRun client

work :: RTKArgs -> RTKData -> String
work clArgs rtk =
  case clArgs of
    {cmd: "-p", args} -> primsToFrames args rtk.components rtk.kanji
    {cmd: "-f", args} -> indicesToFrames args rtk.indices rtk.kanji
    {cmd: "-k", args} -> kanjiToKeywords args rtk.kanji rtk.keywords
    {cmd: "-i", args} -> kanjiToIndices args rtk.kanji rtk.indices
    _ -> "Something went wrong!"

main :: Effect Unit
main = launchAff_ do
  args_ <- liftEffect cmdLineParser
  either (\e -> doError e)
         (\xs -> doWork xs) args_
  where 
    doError msg = do
      let errMsg = "Error: " <> msg
      pbcopy errMsg
      pbpaste 
      Console.error msg

    doWork xs = do
      rtkData <- gsRun =<< auth =<< jwt
      pbcopy $ work xs rtkData
      pbpaste
