module.exports =
  fromTree: (object, prefix="") ->
    pairs = {}
    for key, value of object
      if _.isObject(value)
        _.extend(pairs, exports.fromTree(value, key + "."))
      else
        pairs[prefix + key] = value
    pairs

  toTree: (pairs) ->
    final = {}
    for path, value of pairs
      object = final
      for segment in path.split(".")[...-1]
        object = (object[segment] ?= {})
      object[path.split(".").pop()] = value
    final

