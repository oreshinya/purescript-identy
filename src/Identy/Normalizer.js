'use strict';

export function normalize_(left, right, foreign) {
  const state = { entities: {}, associations: {} };

  function run(res) {
    if (Array.isArray(res)) {
      return res.map(run);
    } else if (isNormalizable(res)) {
      const entity = {};
      for (var key in res) {
        const field = res[key];
        try {
          const r = field === null ? null : run(field);
          const refKey = toLowerCaseAtFirst(res.typename) + toUpperCaseAtFirst(key);
          state.associations[refKey] = state.associations[refKey] || {};
          state.associations[refKey][res.id] = r;
          if (r === null) {
            entity[key] = r;
          }
        } catch (e) {
          entity[key] = field;
        }
      }
      const entitiesKey = toLowerCaseAtFirst(res.typename);
      state.entities[entitiesKey] = state.entities[entitiesKey] || {};
      state.entities[entitiesKey][res.id] = entity;
      return res.id;
    } else {
      throw "The received foreign can't be normalized.";
    }
  }

  try {
    state.result = run(foreign);
    return right(state);
  } catch (e) {
    return left(e.message);
  }
}

function isNormalizable(res) {
  return res.typename && res.id;
}

function toUpperCaseAtFirst(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function toLowerCaseAtFirst(str) {
  return str.charAt(0).toLowerCase() + str.slice(1);
}
