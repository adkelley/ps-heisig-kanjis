module Main (main) where

import Prelude

import CmdLineParser (cmdLineParser)
import Crud (authenticate, gsBatchGet, gsUpdate)
import Data.Array (head, intercalate, tail)
import Data.Either (Either(..), either)
import Data.Int.Parse (parseInt, toRadix)
import Data.Maybe (fromMaybe)
import Data.String (Pattern(..), Replacement(..), replaceAll)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class.Console (log, logShow)
import Effect.Exception (error, Error)
import Google.Auth (Client)
import RTK (indicesToFrames, kanjiToIndices, kanjiToKeywords, primsToFrames)
import Types (CmdArgs, Command(..), RTKData)
import ValidateArgs (isIndexPrim, isIndices, isJukugo, isPrimitives)

--work :: CmdArgs -> RTKData -> Aff (Either String String)
--work {cmd, args} rtk = pure $
--  case cmd of
--    P2F -> primsToFrames args rtk.components rtk.kanji
--    I2F -> indicesToFrames args rtk.indices rtk.kanji
--    K2K -> kanjiToKeywords args rtk.kanji rtk.keywords
--    K2I -> kanjiToIndices args rtk.kanji rtk.indices
--    UC -> insertPrimitive args rtk.components
  
work :: Client -> CmdArgs -> Aff (Either Error String)
work client {cmd, args} = do 
  batch <- gsBatchGet client
  doWork batch
  where
    go :: Either String String -> Aff (Either Error String)
    go = case _ of
      Right x -> pure $ Right x
      Left  x -> pure $ Left $ error x

    value :: String
    value =
      let
        t = fromMaybe [""] $ tail args
        r = replaceAll (Pattern "_") (Replacement " ")
      in
        intercalate " ... "  $ map r t

    range :: String
    range = 
      let
        si = fromMaybe "0" $ head args
        i = fromMaybe 0 $ parseInt si $ toRadix 10
        index = show (i + 1)
      in
        "Heisig!F" <> index <> ":F" <> index

    updateClient :: Aff (Either Error String)
    updateClient = 
      gsUpdate {client: client, range: range, value: value}

    doWork :: Either Error RTKData -> Aff (Either Error String)
    doWork batch =
      case batch of
        Right rtk ->
          case cmd of
            P2F -> go $ primsToFrames args rtk.components rtk.kanji
            I2F -> go $ indicesToFrames args rtk.indices rtk.kanji
            K2K -> go $ kanjiToKeywords args rtk.kanji rtk.keywords
            K2I -> go $ kanjiToIndices args rtk.kanji rtk.indices
            UC ->  updateClient 
        Left e -> pure $ Left e

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
