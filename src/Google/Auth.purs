module Google.Auth (auth) where

import Prelude 

import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)

import Google.Client (Client, client)

foreign import _auth :: Client -> EffectFnAff Client

auth :: Aff Client
auth = do
  jwtClient <- client
  fromEffectFnAff $ _auth jwtClient
