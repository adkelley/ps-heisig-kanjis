module Main (main) where

import Prelude

import CmdLineParser (cmdLineParser)
import Crud (authenticate, batchGet)
import Data.Either (Either(..), either)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class.Console (log, logShow)
import Effect.Exception (error, Error)
import Google.Auth (Client)
import RTK (indicesToFrames, kanjiToIndices, kanjiToKeywords, primsToFrames, updateComponents)
import Types (CmdArgs, Command(..), RTKData)
import ValidateArgs (isIndexPrim, isIndices, isJukugo, isPrimitives)

--work :: CmdArgs -> RTKData -> Aff (Either String String)
--work {cmd, args} rtk = pure $
--  case cmd of
--    P2F -> primsToFrames args rtk.components rtk.kanji
--    I2F -> indicesToFrames args rtk.indices rtk.kanji
--    K2K -> kanjiToKeywords args rtk.kanji rtk.keywords
--    K2I -> kanjiToIndices args rtk.kanji rtk.indices
--    UC -> updateComponents args rtk.components
  
work :: Client -> CmdArgs -> Aff (Either Error String)
work client {cmd, args} = do 
  batch <- batchGet client
  pure $ doWork batch
  where
    go :: Either String String -> Either Error String
    go = case _ of
      Right x -> Right x
      Left  x -> Left $ error x
  
    doWork :: Either Error RTKData -> Either Error String
    doWork rtk =
      case rtk of
        Right rtk_ ->
          case cmd of
            P2F -> go $ primsToFrames args rtk_.components rtk_.kanji
            I2F -> go $ indicesToFrames args rtk_.indices rtk_.kanji
            K2K -> go $ kanjiToKeywords args rtk_.kanji rtk_.keywords
            K2I -> go $ kanjiToIndices args rtk_.kanji rtk_.indices
            UC -> go $ updateComponents args rtk_.components
        Left e -> Left e

validateArgs :: CmdArgs -> Either String CmdArgs
validateArgs {cmd, args} = 
  case cmd of
    P2F -> validate isPrimitives 
    I2F -> validate isIndices 
    K2K -> validate isJukugo 
    K2I -> validate isJukugo
    UC  -> validate isIndexPrim
  where
    validate
      :: (Array String -> Either String (Array String))
      -> Either String CmdArgs
    validate f =
      case f args of
        Right _ -> Right {cmd, args}
        Left e  -> Left e


main :: Effect Unit
main = do
  query <- cmdLineParser
  launchAff_ $ doWork query
  where
    -- | retreive spreadsheet columns and perform query
    doWork :: CmdArgs -> Aff Unit
    doWork cmdArgs =
      case (validateArgs cmdArgs) of
        Right _ -> do
                    client <- authenticate 
                    result <- work client cmdArgs
                    either logShow log result
        Left e -> logShow e
