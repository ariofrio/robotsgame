require 'sugar'
async = require 'async'
fs = require 'fs'
path = require 'path'

module.exports = onthefly = (directory, converters = []) ->
  converters = converters.map (converter) ->
    switch converter
      when "coffee" 
        coffee = require 'coffee-script'
        (url, done) ->
          return done() unless url.endsWith ".js"
          fs.readFile path.join(directory, url.match(/^(.*)\.js$/)[1] + ".coffee"), (err, data) ->
            return done() if err?
            done(undefined, coffee.compile(data))

      when "less" 
        less = require 'less'
        (url, done) ->
          return done() unless url.endsWith ".css"
          fs.readFile path.join(directory, url.match(/^(.*)\.css$/)[1] + ".less"), (err, data) ->
            return done() if err?
            less.render new String(data), (err, out) ->
              return done(err) if err?
              done(undefined, out)
      else
        converter

  onthefly = (req, res, next) ->
    next() unless req.method == 'GET'

    async.forEachSeries converters, (converter, done) ->
      converter req.url, (err, out) ->
        if err?
          next(err)
          done(true) # break
        else if out?
          res.end(out)
          done(true) # break
        else # no arg means skip
          done()
    , (foundAMatch) -> next() unless foundAMatch

