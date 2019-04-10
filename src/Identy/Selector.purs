module Identy.Selector where

import Prelude

import Data.Array (catMaybes)
import Data.Maybe (Maybe(..))
import Foreign.Object (Object, lookup)

-- | Get entity array with an object stored entities and an array stored identifiers.
resources :: forall a. Object a -> Array String -> Array a
resources entities ids =
  catMaybes $ flip lookup entities <$> ids

-- | Get an entity with an object stored entities and an identifier.
resource :: forall a. Object a -> Maybe String -> Maybe a
resource _ Nothing = Nothing
resource entities (Just id) = lookup id entities

-- | Get child entity array with an object stored child entities, an object stored has-many associations and an identifier of parent.
assocs :: forall a. Object a -> Object (Array String) -> Maybe String -> Array a
assocs _ _ Nothing = []
assocs entities hasMany (Just id) =
  case lookup id hasMany of
    Nothing -> []
    Just ids -> resources entities ids

-- | Get a child entity with an object stored child entities, an object stored has-one associations and an identifier of parent.
assoc :: forall a. Object a -> Object String -> Maybe String -> Maybe a
assoc _ _ Nothing = Nothing
assoc entities hasOne (Just id) =
  resource entities $ lookup id hasOne
