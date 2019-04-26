module Identy.ObjectMap
  ( ObjectMap
  , keys
  , values
  , update
  , union
  , size
  , singleton
  , member
  , lookup
  , isEmpty
  , insert
  , empty
  , delete
  , alter
  ) where

import Prelude

import Data.Foldable (class Foldable)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype, unwrap, wrap)
import Data.Traversable (class Traversable)
import Foreign.Object as Object
import Simple.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)

newtype ObjectMap k v = ObjectMap (Object.Object v)

derive newtype instance eqObjectMap :: (Eq v) => Eq (ObjectMap k v)
derive newtype instance showObjectMap :: (Show v) => Show (ObjectMap k v)
derive newtype instance semigroupObjectMap :: (Semigroup v) => Semigroup (ObjectMap k v)
derive newtype instance monoidObjectMap :: (Semigroup v) => Monoid (ObjectMap k v)
derive newtype instance functorObjectMap :: Functor (ObjectMap k)
derive newtype instance foldableObjectMap :: Foldable (ObjectMap k)
derive newtype instance traversableObjectMap :: Traversable (ObjectMap k)
derive instance newtypeObjectMap :: Newtype (ObjectMap k v) _

instance readForeignObjectMap :: (Newtype k String, ReadForeign v) => ReadForeign (ObjectMap k v) where
  readImpl x = wrap <$> readImpl x

instance writeForeignObjectMap :: (Newtype k String, WriteForeign v) => WriteForeign (ObjectMap k v) where
  writeImpl = unwrap >>> writeImpl

keys :: forall k v. Newtype k String => ObjectMap k v -> Array k
keys x = wrap <$> (Object.keys $ unwrap x)

values :: forall k v. ObjectMap k v -> Array v
values = unwrap >>> Object.values

update :: forall k v. Newtype k String => (v -> Maybe v) -> k -> ObjectMap k v -> ObjectMap k v
update f k = unwrap >>> Object.update f (unwrap k) >>> wrap

union :: forall k v. ObjectMap k v -> ObjectMap k v -> ObjectMap k v
union x = unwrap >>> Object.union (unwrap x) >>> wrap

size :: forall k v. ObjectMap k v -> Int
size = unwrap >>> Object.size

singleton :: forall k v. Newtype k String => k -> v -> ObjectMap k v
singleton k v = wrap $ Object.singleton (unwrap k) v

member :: forall k v. Newtype k String => k -> ObjectMap k v -> Boolean
member k = unwrap >>> Object.member (unwrap k)

lookup :: forall k v. Newtype k String => k -> ObjectMap k v -> Maybe v
lookup k = unwrap >>> Object.lookup (unwrap k)

isEmpty :: forall k v. ObjectMap k v -> Boolean
isEmpty = unwrap >>> Object.isEmpty

insert :: forall k v. Newtype k String => k -> v -> ObjectMap k v -> ObjectMap k v
insert k v = unwrap >>> Object.insert (unwrap k) v >>> wrap

empty :: forall k v. ObjectMap k v
empty = wrap Object.empty

delete :: forall k v. Newtype k String => k -> ObjectMap k v -> ObjectMap k v
delete k = unwrap >>> Object.delete (unwrap k) >>> wrap

alter :: forall k v. Newtype k String => (Maybe v -> Maybe v) -> k -> ObjectMap k v -> ObjectMap k v
alter f k = unwrap >>> Object.alter f (unwrap k) >>> wrap
