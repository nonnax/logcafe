#!/usr/bin/env coffee
# Id$ nonnax 2023-10-27 19:33:39 +0800
os = require 'os'
path = require 'path'
fs = require 'fs'

home = os.homedir()
currdir = process.cwd()
appdir = __dirname
DBNAME = 'log.db'

# J, JSON read/write factory
J= (fname=DBNAME)->
 f=path.join(__dirname, fname)

 to_s = (data)->JSON.stringify( data, null, 2)
 write = (data)->
  fs.promises
   .writeFile(f, to_s(data)  ) # neat formatting
   .then(console.log data)
   .catch((err)->console.log err)

 read = (fn)->
  fs.promises
   .readFile(f)
   .then((data)->fn( JSON.parse(data) ) )
   .catch((err)->
    console.log [err.message, "oops! creating #{DBNAME}... do it again"].join("\n")
    write({}, to_s({}) )
   )

 {read, write}


# DB factory
DB = (db={})->
 newdb = {...db} # clone

 timenow = ->
  (new Date).toLocaleString()

 # add and return a new DB factory
 add = (content)->
  e = {[timenow()]: content}
  (newdb[currdir] ||= []).push e
  DB(newdb)

 value = (fn) ->
  fn(newdb)

 { add, value }

# read/write new data
update = (content) ->
 J().read (obj) ->
  DB(obj)
  .add content.join(' ')
  .value (v)-> J().write (v)


# main
[...content] = process.argv[2...]


if content.length > 1
 update content
else if content.length==1
 J().read (data) -> console.log data[currdir]
else
 J().read console.log
