module Google.JWT (JWT, jwt) where

import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign)

type JWT = Foreign

foreign import _jwt :: EffectFnAff JWT

jwt :: Aff JWT
jwt = fromEffectFnAff _jwt
