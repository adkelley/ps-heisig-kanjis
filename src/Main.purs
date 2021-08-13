module Main (main) where

import Prelude

import CmdLineParser (cmdLineParser)
import Crud (authenticate, gsBatchGet, gsUpdate)
import Data.Array (head, intercalate, tail)
import Data.Either (Either(..), either)
import Data.Int.Parse (parseInt, toRadix)
import Data.Maybe (fromMaybe)
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class.Console (log, logShow)
import Effect.Exception (Error)
import Google.Auth (Client)
import RTK (indicesToFrames, kanjiToIndices, kanjiToKeywords, primsToFrames)
import Types (CmdArgs, Command(..))
import ValidateArgs (validateArgs)



-- | Updatethe components (Column F) in spreadsheet with the primititives
-- | that make up that kanji
updatePrims :: Client -> Array String -> Aff (Either Error String)
updatePrims client args = 
  gsUpdate {client, range, value}
  where
    value :: String
    value =
      intercalate " ... "  $ fromMaybe [""] $ tail args

    range :: String
    range = 
      let
        si = fromMaybe "0" $ head args
        i = fromMaybe 0 $ parseInt si $ toRadix 10
        index = show (i + 1)
      in
        "Heisig!F" <> index <> ":F" <> index

-- | Update the frames (Column J) in spreadsheet that belong to the
-- | same group (pure, mixed) etc.
updateFrame
  :: Client
  -> Array String
  -> String
  -> Aff Unit
updateFrame client args frame = do
  traverse_ (\a -> gsUpdate {client, range: (range a), value: frame}) args
  where
    range :: String -> String
    range s = 
      let
        i = fromMaybe 0 $ parseInt s $ toRadix 10
        index = show (i + 1)
      in
        "Heisig!J" <> index <> ":J" <> index

-- | This is our controller 
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
      gsBatchGet client >>= \rtk -> 
      either
        (\e -> pure $ Left e)
        (\x -> indicesToFrames args x.indices x.kanji #
               either
                 (\e -> pure $ Left e)
                 \f -> updateFrame client args f >>= 
                       \_ -> pure $ Right f
         )
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
    UC ->  updatePrims client args 


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
