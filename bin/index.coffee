#!/usr/bin/env coffee
# Id$ nonnax 2023-10-27 19:33:39 +0800
os = require 'os'
path = require 'path'
fs = require 'fs'

home = os.homedir()
currdir = process.cwd()
appdir = __dirname

# J, JSON read/write factory
J= (fname='log.db')->
 f=path.join(__dirname, fname)
 backupFile = path.join __dirname, "backup.#{fname}"

 to_s = (data)->JSON.stringify( data, null, 2)

 write = (data)->
  fs.promises
   .writeFile(f, to_s(data)  ) # neat formatting
   .then(console.log data)
   .catch((err)->console.log err)

 read = (fn)->
  fs.promises
   .readFile(f)
   .then((data)->
    backup()
    fn( JSON.parse(data) )
   )
   .catch((err)->
    console.log [err.message, "oops! creating #{f}... do it again"].join("\n")
    write({}, to_s({}) )
   )

 backup = ->
  fs.promises
  .copyFile(f, backupFile)
  .then(()->console.log 'backup saved.')
  .catch(()->console.log 'backup error!')

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

[head, ...tail] = content

if content.length >= 1

 if head is '.'
  J().read (data) -> console.log data[currdir]
 else
  update content

else
 J().read console.log
