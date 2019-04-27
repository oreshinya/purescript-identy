module Identy.Populater
  ( class ObjectPopulatable
  , populateObjects
  , populate
  ) where

import Prelude

import Data.Symbol (class IsSymbol, SProxy(..))
import Identy.ObjectMap (ObjectMap, union)
import Prim.Row as Row
import Prim.RowList as RL
import Record (get, modify)
import Type.Data.RowList (RLProxy(..))
import Unsafe.Coerce (unsafeCoerce)

-- | Merge identy-style records.
populate
  :: forall rl1 rl2 r1 r2 r1' r2' from to
   . RL.RowToList r1 rl1
  => RL.RowToList r2 rl2
  => ObjectPopulatable rl1 r1 r1'
  => ObjectPopulatable rl2 r2 r2'
  => { entities :: { | r1 }, associations :: { | r2 } | from }
  -> { entities :: { | r1' }, associations :: { | r2' } | to }
  -> { entities :: { | r1' }, associations :: { | r2' } | to }
populate from =
  modify (SProxy :: _ "entities") (populateObjects (RLProxy :: _ rl1) from.entities)
    >>> modify (SProxy :: _ "associations") (populateObjects (RLProxy :: _ rl2) from.associations)

populateObject
  :: forall k sym v fromtail totail from to
   . IsSymbol sym
  => Row.Cons sym (ObjectMap k v) fromtail from
  => Row.Cons sym (ObjectMap k v) totail to
  => SProxy sym
  -> { | from }
  -> { | to }
  -> { | to }
populateObject proxy from =
  modify proxy $ union $ get proxy from

class ObjectPopulatable (rl :: RL.RowList) (from :: # Type) (to :: # Type) | rl -> from where
  populateObjects :: RLProxy rl -> { | from } -> { | to } -> { | to }

instance objectPopulatableNil :: ObjectPopulatable RL.Nil () to where
  populateObjects _ _ to = to

instance objectPopulatableCons
  :: ( IsSymbol sym
     , Row.Cons sym (ObjectMap k v) fromtail from
     , Row.Cons sym (ObjectMap k v) totail to
     , ObjectPopulatable rlfromtail fromtail to
     )
  => ObjectPopulatable (RL.Cons sym (ObjectMap k v) rlfromtail) from to where
  populateObjects _ from to =
    populateObjects (RLProxy :: _ rlfromtail) (unsafeCoerce from)
      $ populateObject (SProxy :: _ sym) from to
