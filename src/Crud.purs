module Crud (authenticate, batchGet) where

import Prelude

import Data.Either (Either)
import Effect.Aff (Aff, attempt)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Exception (Error)
import Google.Auth (Client, auth)
import Google.JWT (jwt)
import Types (RTKData)

foreign import _gsBatchGet :: Client -> EffectFnAff RTKData
foreign import _gsUpdate :: Client -> Array String -> EffectFnAff RTKData

gsBatchGet :: Client -> Aff RTKData
gsBatchGet client = fromEffectFnAff $ _gsBatchGet client

gsUpdate :: Client -> Array String -> Aff RTKData
gsUpdate client components = fromEffectFnAff $ _gsUpdate client components

authenticate :: Aff Client
authenticate = auth =<< jwt

batchGet :: Client -> Aff (Either Error RTKData)
batchGet client =
  attempt $ gsBatchGet client


