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
import Effect.Exception (Error)
import Google.Auth (Client)
import RTK (indicesToFrames, kanjiToIndices, kanjiToKeywords, primsToFrames)
import Types (CmdArgs, Command(..))
import ValidateArgs (validateArgs)

  
updateClient :: Client -> Array String -> Aff (Either Error String)
updateClient client args = 
  gsUpdate {client, range, value}
  where
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


work :: Client -> CmdArgs -> Aff (Either Error String)
work client {cmd, args} = do 
  case cmd of
    P2F -> 
      gsBatchGet client >>= \rtk -> pure $
      either
        (\e -> Left e)
        (\x -> primsToFrames args x.components x.kanji)
        rtk
    I2F ->
      gsBatchGet client >>= \rtk -> pure $
      either
        (\e -> Left e)
        (\x -> indicesToFrames args x.indices x.kanji)
        rtk
    K2K ->
      gsBatchGet client >>= \rtk -> pure $
      either
        (\e -> Left e)
        (\x -> kanjiToKeywords args x.kanji x.keywords)
        rtk
    K2I ->
      gsBatchGet client >>= \rtk -> pure $
      either
        (\e -> Left e)
        (\x -> kanjiToIndices args x.kanji x.indices)
        rtk
    UC ->  updateClient client args 


main :: Effect Unit
main = do
    query <- cmdLineParser >>= \x -> pure $ validateArgs x
    either logShow (\x -> launchAff_ $ doWork x) query
   where
    doWork :: CmdArgs -> Aff Unit
    doWork cmdArgs = do
      client <- authenticate 
      result <- work client cmdArgs
      either logShow log result
