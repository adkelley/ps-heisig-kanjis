module Params (cmdLineParser) where

import Prelude

import Control.Alternative ((<|>))
import Data.Array (head, (!!))
import Data.Either (Either(..))
import Data.Foldable (fold)
import Data.Int.Parse (parseInt, toRadix)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String.Common (split)
import Data.String.Pattern (Pattern(..))
import Data.String.Regex (regex, test, parseFlags)
import Data.Traversable (traverse)
import Effect (Effect)
import Options.Applicative (Parser, execParser, fullDesc, header, help, helper, info, long, metavar, progDesc, short, strOption, (<**>))
import Types (Error, RTKArgs)

data Query
  = Keywords String
  | Indices String
  | Primitives String
  | Frames String
  | Update String

keywords :: Parser Query
keywords = ado
  kanji <- strOption $ fold
    [ long "keywords"
    , short 'k'
    , metavar "QUERY"
    , help "Query for keywords command"
    ]
  in Keywords kanji

indices :: Parser Query
indices = ado
  kanji <- strOption $ fold
    [ long "indices"
    , short 'i'
    , metavar "QUERY"
    , help "Query for indices command"
    ]
  in Indices kanji


primitives :: Parser Query
primitives = ado
  prims <- strOption $ fold
    [ long "primitives"
    , short 'p'
    , metavar "QUERY"
    , help "Query for primitives command"
    ]
  in Primitives prims


frames :: Parser Query
frames = ado
  indices <- strOption $ fold
    [ long "frames"
    , short 'f'
    , metavar "QUERY"
    , help "Query for frames command"
    ]
  in Frames indices


update :: Parser Query
update = ado
  indices <- strOption $ fold
    [ long "update"
    , short 'w'
    , metavar "QUERY"
    , help "Query for update command"
    ]
  in Update indices


-- | A RTK index should be an integer > 0 and < 3001
-- | Indices are separated by spaces
isIndices :: String -> Either Error (Array String)
isIndices is = 
  traverse (\i -> isIndex i) $ split (Pattern " ") is
  where
    isIndex index = do
      let i = fromMaybe 0 $ parseInt index $ toRadix 10 
      if (i > 0 && i < 3001)
        then Right index
        else Left "RTK indices must be integers > 0 and < 3001\n"


-- UNICODE RANGE : DESCRIPTION
-- 
-- 3000-303F : punctuation
-- 3040-309F : hiragana
-- 30A0-30FF : katakana
-- FF00-FFEF : Full-width roman + half-width katakana
-- 4E00-9FAF : Common and uncommon kanji
-- 
-- Non-Japanese punctuation/formatting characters commonly used in Japanese text
-- 2605-2606 : Stars
-- 2190-2195 : Arrows
-- u203B     : Weird asterisk thing
isJukugo :: String -> Either Error (Array String)
isJukugo jukugo = 
  traverse (\k -> isKanji k) $ split (Pattern "") jukugo
  where
    isKanji kanji = do
      expression <- regex "[\\u4E00-\\u9FAF]" $ parseFlags "g" 
      if (test expression kanji)
        then Right jukugo
        else Left "A jukugo must be a kanji character or kanji compound\n"


-- | A primitive must be lower case english string
arePrimitives :: String -> Either Error (Array String)
arePrimitives prims = 
  traverse (\p -> isPrimitive p) $ split (Pattern " ") prims
  where 
    isPrimitive p = do
      expression <- regex "[a-z]" $ parseFlags "g" 
      if (test expression p)
        then Right p
        else Left "Primitives must be lower case english strings\n"

-- | Valididate that arguements contain a valid index and primitives 
isIndexPrim :: String -> Either Error (Array String)
isIndexPrim q = 
  let 
    indexPrim = split (Pattern " ") q
    radix10 = toRadix 10
    mbIndex = head indexPrim >>=
              (\i -> parseInt i radix10) #
              liftA1 (\x -> x - 1) >>=
              \i -> if (i >= 0)
                       then Just i
                       else Nothing
  in 
   case mbIndex of
     Just index -> do
        expression <- regex "[a-z/. ]" $ parseFlags "g" 
        if (test expression p)
          then Right indexPrim
          else Left "Argument must have an index and primitives\n"
        where
          p = fromMaybe "" $ indexPrim !! 1
     Nothing -> Left "Invalid index\n"

validate :: Query -> Effect (Either Error RTKArgs)
validate query = pure $
   case query of
     Keywords k -> (isJukugo k) >>= 
                       (\args -> Right {cmd: "-k", args: args})
     Indices i -> (isJukugo i) >>= 
                       (\args -> Right {cmd: "-i", args: args})
     Primitives p -> (arePrimitives p) >>= 
                       (\args -> Right {cmd: "-p", args: args})
     Frames f -> (isIndices f) >>= 
                       (\args -> Right {cmd: "-f", args: args})
     Update w -> (isIndexPrim w) >>= 
                       (\args -> Right {cmd: "-w", args: args})

cmdLineParser :: Effect (Either Error RTKArgs)
cmdLineParser = validate =<< execParser opts
  where
     opts = info (keywords <|> indices <|> primitives <|> 
                  frames <|> update <**> helper)
      ( fullDesc
     <> progDesc "return the result of an RTK QUERY"
     <> header "rtk - query utilities for the rtk google spreadsheet" )
