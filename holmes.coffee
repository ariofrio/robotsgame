fs = require 'fs'
path = require 'path'
detective = require 'detective'
coffee = null

module.exports = holmes = (root) ->
  modules = []

  # Recursively find all modules that `name` requires,
  # including itself.
  find = (name, isRoot = true) ->
    return unless modules.indexOf(name) == -1

    src = null
    try
      src = fs.readFileSync path.join(root, "#{name}.js"), "UTF-8"
    catch err
      throw err unless err.code == 'ENOENT'
      src = fs.readFileSync path.join(root, "#{name}.coffee"), "UTF-8"
      coffee ?= require 'coffee-script'
      src = coffee.compile(src)

    for req in detective(src)
      if req.indexOf('./') == 0 # relative
        find path.join(path.dirname(name), req), false
      else # absolute
        find req, false
    modules.push(name)

    # Clean up `modules`
    if isRoot
      [ret, modules] = [modules, []]
      ret

