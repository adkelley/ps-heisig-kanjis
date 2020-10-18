module Google.Auth (Client, auth) where

import Prelude 

import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign)

import Google.JWT (JWT)

type Client = Foreign

foreign import _auth :: JWT -> EffectFnAff Client

auth :: JWT -> Aff Client
auth token = 
  fromEffectFnAff $ _auth token
