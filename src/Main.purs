module Main (main) where

import Prelude

import Data.Either (Either(..), either)
import Effect (Effect)
import Effect.Aff (Aff, attempt, launchAff_)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Class.Console (log, logShow)
import Effect.Exception (Error)
import Google.Auth (Client, auth)
import Google.JWT (jwt)
import Params (cmdLineParser)
import RTK (indicesToFrames, kanjiToIndices, kanjiToKeywords, primsToFrames, updateComponents)
import Types (RTKArgs, RTKData)

foreign import _gsBatchGet :: Client -> EffectFnAff RTKData
foreign import _gsUpdate :: Client -> Array String -> EffectFnAff RTKData


gsBatchGet :: Client -> Aff RTKData
gsBatchGet client = fromEffectFnAff $ _gsBatchGet client

gsUpdate :: Client -> Array String -> Aff RTKData
gsUpdate client components = fromEffectFnAff $ _gsUpdate client components

work :: RTKArgs -> RTKData -> Aff (Either String String)
work {cmd, args} rtk =
  case cmd of
    "-p" -> pure $ primsToFrames args rtk.components rtk.kanji
    "-f" -> pure $ indicesToFrames args rtk.indices rtk.kanji
    "-k" -> pure $ kanjiToKeywords args rtk.kanji rtk.keywords
    "-i" -> pure $ kanjiToIndices args rtk.kanji rtk.indices
    "-w" -> pure $ updateComponents args rtk.components
    _ -> pure $ Left "Something went wrong!"

--work :: RTKArgs -> RTKData -> Either String String
--work {cmd, args} rtk =
--  case cmd of
--    "-p" -> primsToFrames args rtk.components rtk.kanji
--    "-f" -> indicesToFrames args rtk.indices rtk.kanji
--    "-k" -> kanjiToKeywords args rtk.kanji rtk.keywords
--    "-i" -> kanjiToIndices args rtk.kanji rtk.indices
--    "-w" -> updateComponents args rtk.components
--    _ -> Left "Something went wrong!"


batchGet :: Aff (Either Error RTKData)
batchGet =
  attempt $ gsBatchGet =<< auth =<< jwt

main :: Effect Unit
main = do
 query <- cmdLineParser
 launchAff_ $ either (\e -> log $ "Error: " <> e) (\args -> doWork args) query
  where
    -- | retreive spreadsheet columns and perform query
    doWork :: RTKArgs -> Aff Unit
    doWork args =
      batchGet >>=
      either
        (\googErr -> logShow googErr)
        \rtk -> work args rtk >>= \x -> either log log x
----        \rtk -> (work args rtk) #
--            either log log 
