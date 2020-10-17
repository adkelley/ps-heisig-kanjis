module Google.JWT (JWT, jwt) where

import Prelude (($))
import Effect.Exception (Error)
import Effect.Aff (Aff, attempt)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Data.Either (Either)
import Foreign (Foreign)

type JWT = Foreign

foreign import _jwt :: EffectFnAff JWT

jwt :: Aff (Either Error JWT)
jwt = attempt $ fromEffectFnAff _jwt
  
