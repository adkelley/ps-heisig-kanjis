module Main (main) where

import Prelude

import Data.Either (Either(..), either)
import Effect (Effect)
import Effect.Aff (Aff, attempt, launchAff_)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Class.Console (log)
import Google.Auth (Client, auth)
import Google.JWT (jwt)
import Params (cmdLineParser)
import RTK (indicesToFrames, kanjiToIndices, kanjiToKeywords, primsToFrames)
import Types (RTKData, RTKArgs)

foreign import _gsRun :: Client -> EffectFnAff RTKData


gsRun :: Client -> Aff RTKData
gsRun client = fromEffectFnAff $ _gsRun client

work :: RTKArgs -> RTKData -> Either String String
work {cmd, args} rtk =
  case cmd of
    "-p" -> primsToFrames args rtk.components rtk.kanji
    "-f" -> indicesToFrames args rtk.indices rtk.kanji
    "-k" -> kanjiToKeywords args rtk.kanji rtk.keywords
    "-i" -> kanjiToIndices args rtk.kanji rtk.indices
    _ -> Left "Something went wrong!"


main :: Effect Unit
main = do
 query <- cmdLineParser
 launchAff_ $ either (\e -> print $ "Error: " <> e) (\args -> doWork args) query
  where
    -- | print to output
    print :: String -> Aff Unit
    print result = log result

    -- | retreive spreadsheet columns and perform query
    doWork :: RTKArgs -> Aff Unit
    doWork args =
       either (\googErr -> print $ show googErr) 
              (\rtk -> print $ 
                 either identity identity (work args rtk)) 
               =<< (attempt $ gsRun =<< auth =<< jwt)
