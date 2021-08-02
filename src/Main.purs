module Main (main) where

import Prelude

import CmdLineParser (cmdLineParser)
import Crud (authenticate, batchGet)
import Data.Either (Either(..), either)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class.Console (log, logShow)
import RTK (indicesToFrames, kanjiToIndices, kanjiToKeywords, primsToFrames, updateComponents)
import Types (Command(..), RTKData, CmdArgs, Error)
import ValidateArgs (isIndexPrim, isIndices, isJukugo, isPrimitives)

work :: CmdArgs -> RTKData -> Aff (Either String String)
work {cmd, args} rtk = pure $
  case cmd of
    P2F -> primsToFrames args rtk.components rtk.kanji
    I2F -> indicesToFrames args rtk.indices rtk.kanji
    K2K -> kanjiToKeywords args rtk.kanji rtk.keywords
    K2I -> kanjiToIndices args rtk.kanji rtk.indices
    UC -> updateComponents args rtk.components
  

validateArgs :: CmdArgs -> Either Error CmdArgs
validateArgs {cmd, args} = 
  case cmd of
    P2F -> isPrimitives {cmd, args}
    I2F -> isIndices {cmd, args}
    K2K -> isJukugo {cmd, args}
    K2I -> isJukugo {cmd, args}
    UC  -> isIndexPrim {cmd, args}


main :: Effect Unit
main = do
  query <- cmdLineParser
  launchAff_ $ either log doWork query
  where
    -- | retreive spreadsheet columns and perform query
    doWork :: CmdArgs -> Aff Unit
    doWork cmdArgs =
      case (validateArgs cmdArgs) of
        Right _ -> authenticate >>=
                  batchGet >>=
                  either logShow \rtk -> work cmdArgs rtk >>= either log log
        Left e -> log e
