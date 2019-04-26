module Identy.Selector where

import Prelude

import Data.Array (catMaybes)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Identy.ObjectMap (ObjectMap, lookup)

-- | Get entity array with an object stored entities and an array stored identifiers.
resources :: forall k v. Newtype k String => ObjectMap k v -> Array k -> Array v
resources entities ids =
  catMaybes $ flip lookup entities <$> ids

-- | Get an entity with an object stored entities and an identifier.
resource :: forall k v. Newtype k String => ObjectMap k v -> Maybe k -> Maybe v
resource _ Nothing = Nothing
resource entities (Just id) = lookup id entities

-- | Get child entity array with an object stored child entities, an object stored has-many associations and an identifier of parent.
assocs
  :: forall k k' v
   . Newtype k String
  => Newtype k' String
  => ObjectMap k v
  -> ObjectMap k' (Array k)
  -> Maybe k'
  -> Array v
assocs _ _ Nothing = []
assocs entities hasMany (Just id) =
  case lookup id hasMany of
    Nothing -> []
    Just ids -> resources entities ids

-- | Get a child entity with an object stored child entities, an object stored has-one associations and an identifier of parent.
assoc
  :: forall k k' v
   . Newtype k String
  => Newtype k' String
  => ObjectMap k v
  -> ObjectMap k' k
  -> Maybe k'
  -> Maybe v
assoc _ _ Nothing = Nothing
assoc entities hasOne (Just id) =
  resource entities $ lookup id hasOne
