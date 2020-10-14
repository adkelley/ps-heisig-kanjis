module OSX.Utils (pbcopy, pbpaste) where

import Prelude

import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)

foreign import _pbcopy :: String -> EffectFnAff Unit
foreign import _pbpaste :: EffectFnAff Unit

-- | Copies a string to the Mac OS clipboard. See
-- | $ man pbcopy
pbcopy :: String -> Aff Unit
pbcopy result = fromEffectFnAff $ _pbcopy result

-- | Copies a string to the Mac OS clipboard. See
-- | $ man pbcopy
pbpaste :: Aff Unit
pbpaste = fromEffectFnAff _pbpaste
