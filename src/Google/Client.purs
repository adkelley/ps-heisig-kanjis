module Google.Client (Client, client) where

import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign)

type Client = Foreign

foreign import _client :: EffectFnAff Client

client :: Aff Client
client = fromEffectFnAff _client
