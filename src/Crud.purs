module Crud (authenticate, gsBatchGet, gsUpdate) where

import Prelude

import Data.Either (Either)
import Effect.Aff (Aff, attempt)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Exception (Error)
import Google.Auth (Client, auth)
import Google.JWT (jwt)
import Types (RTKData, UpdateData)

foreign import _gsBatchGet :: Client -> EffectFnAff RTKData
foreign import _gsUpdate :: UpdateData -> EffectFnAff String

gsBatchGet :: Client -> Aff (Either Error RTKData)
gsBatchGet client = attempt $ fromEffectFnAff $ _gsBatchGet client

gsUpdate :: UpdateData -> Aff (Either Error String)
gsUpdate ud = attempt $ fromEffectFnAff $ _gsUpdate ud

authenticate :: Aff Client
authenticate = auth =<< jwt
