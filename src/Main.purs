module Main (main) where

import Options.Applicative
import Prelude

import Data.Either (Either(..), either)
import Data.String.Common (split)
import Data.String.Pattern (Pattern(..))
import Effect (Effect)
import Effect.Aff (Aff, attempt, launchAff_)
import Effect.Aff.Class (liftAff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Google.Auth (Client, auth)
import Google.JWT (jwt)
import OSX.Utils (pbcopy, pbpaste)
import Params (Query(..), keywords, isKanji)
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


validate :: Query -> Effect (Either String RTKArgs)
validate query = pure $
   case query of
     Keywords k -> (isKanji k) >>= 
        \kanji -> Right {cmd: "-k", args: split (Pattern "") kanji}


main :: Effect Unit
--main = launchAff_ do
main = do
 test <- (validate =<< execParser opts)
 either (\e -> launchAff_ $ paste e) (\args -> launchAff_ $ doWork args) test
  where
    opts = info (keywords <**> helper)
       (  fullDesc
       <> progDesc "Query the RTK Google Spreadsheet"
       <> header "heisig-kanjis" )

    paste :: String -> Aff Unit
    paste result = do
       pbcopy result
       pbpaste 

    doWork :: RTKArgs -> Aff Unit
    doWork args =
       either (\googErr -> paste $ show googErr) 
              (\rtk -> paste $ 
                 either identity identity (work args rtk)) 
               =<< (attempt $ gsRun =<< auth =<< jwt)
