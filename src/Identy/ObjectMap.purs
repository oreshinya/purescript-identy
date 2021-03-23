module Identy.ObjectMap
  ( ObjectMap(..)
  , fromFoldable
  , toUnfoldable
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

import Control.Monad.ST as ST
import Data.Array as Array
import Data.Foldable (class Foldable)
import Data.FoldableWithIndex (class FoldableWithIndex, foldMapWithIndex, foldlWithIndex, foldrWithIndex)
import Data.FunctorWithIndex (class FunctorWithIndex, mapWithIndex)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype, unwrap, wrap)
import Data.Traversable (class Traversable)
import Data.TraversableWithIndex (class TraversableWithIndex, traverseWithIndex)
import Data.Tuple (Tuple(..))
import Data.Unfoldable (class Unfoldable)
import Foreign.Object as Object
import Foreign.Object.ST as STObject
import Simple.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)

newtype ObjectMap :: Type -> Type -> Type
newtype ObjectMap k v = ObjectMap (Object.Object v)

derive newtype instance eqObjectMap :: (Eq v) => Eq (ObjectMap k v)
derive newtype instance showObjectMap :: (Show v) => Show (ObjectMap k v)
derive newtype instance semigroupObjectMap :: (Semigroup v) => Semigroup (ObjectMap k v)
derive newtype instance monoidObjectMap :: (Semigroup v) => Monoid (ObjectMap k v)
derive newtype instance functorObjectMap :: Functor (ObjectMap k)
derive newtype instance foldableObjectMap :: Foldable (ObjectMap k)
derive newtype instance traversableObjectMap :: Traversable (ObjectMap k)
derive instance newtypeObjectMap :: Newtype (ObjectMap k v) _

instance functorWithIndexObjectMap :: (Newtype k String) => FunctorWithIndex k (ObjectMap k) where
  mapWithIndex f = unwrap >>> mapWithIndex (wrap >>> f) >>> wrap

instance foldableWithIndexObjectMap :: (Newtype k String) => FoldableWithIndex k (ObjectMap k) where
  foldrWithIndex f acc = unwrap >>> foldrWithIndex (wrap >>> f) acc
  foldlWithIndex f acc = unwrap >>> foldlWithIndex (wrap >>> f) acc
  foldMapWithIndex f = unwrap >>> foldMapWithIndex (wrap >>> f)

instance traversableWithIndexObjectMap :: (Newtype k String) => TraversableWithIndex k (ObjectMap k) where
  traverseWithIndex f x = wrap <$> traverseWithIndex (wrap >>> f) (unwrap x)

instance readForeignObjectMap :: (Newtype k String, ReadForeign v) => ReadForeign (ObjectMap k v) where
  readImpl x = wrap <$> readImpl x

instance writeForeignObjectMap :: (Newtype k String, WriteForeign v) => WriteForeign (ObjectMap k v) where
  writeImpl = unwrap >>> writeImpl

fromFoldable
  :: forall f k v
   . Foldable f
  => Newtype k String
  => f (Tuple k v)
  -> ObjectMap k v
fromFoldable l = wrap $ Object.runST do
  s <- STObject.new
  ST.foreach (Array.fromFoldable l) \(Tuple k v) ->
    void $ STObject.poke (unwrap k) v s
  pure s

toUnfoldable
  :: forall f k v
   . Unfoldable f
  => Newtype k String
  => ObjectMap k v
  -> f (Tuple k v)
toUnfoldable = unwrap
  >>> Object.toArrayWithKey (wrap >>> Tuple)
  >>> Array.toUnfoldable

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
