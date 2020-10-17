module Google.Auth (Client, auth) where

import Prelude 

import Effect.Exception (Error)
import Effect.Aff (Aff, attempt)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Data.Either (Either)
import Foreign (Foreign)

import Google.JWT (JWT)

type Client = Foreign

foreign import _auth :: JWT -> EffectFnAff Client

auth :: JWT -> Aff (Either Error Client)
auth token = 
  attempt $ fromEffectFnAff $ _auth token
