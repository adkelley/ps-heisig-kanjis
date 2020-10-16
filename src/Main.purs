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
    {cmd: "primsToFrames", args} -> primsToFrames args rtk.components rtk.kanji
    {cmd: "indicesToFrames", args} -> indicesToFrames args rtk.indices rtk.kanji
    {cmd: "kanjiToKeywords", args} -> kanjiToKeywords args rtk.kanji rtk.keywords
    {cmd: "kanjiToIndices", args} -> kanjiToIndices args rtk.kanji rtk.indices
    _ -> "Undefined"

main :: Effect Unit
main = launchAff_ do
  args_ <- liftEffect cmdLineParser
  either (\e -> do 
            let errMsg = "Error: " <> e
            Console.error errMsg
            pbcopy errMsg
            pbpaste) 
         (\xs -> doWork xs) args_
  where 
    doWork xs = do
      rtkData <- gsRun =<< auth =<< jwt
      pbcopy $ work xs rtkData
      pbpaste
