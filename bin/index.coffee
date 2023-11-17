#!/usr/bin/env coffee
# Id$ nonnax 2023-10-27 19:33:39 +0800
os = require 'os'
path = require 'path'
fs = require 'fs'
dir = require '../lib/dir'
{toYAML:Y} = require 'toolkit'

# utils/global functions
pwd = ->
  dir.Dir()
  .pwd()
  .short

pathFullname = (f) ->
  path.join __dirname, f

timenow = ->
  (new Date).toLocaleString()

to_s = (data) ->
  JSON.stringify( data, null, 2)

writeBlank = (f) ->
  fs.writeFileSync(f, "{}")

backupFile = (f, bak)->
 fs.promises
 .copyFile(f, bak)
 .then(()->console.log 'backup saved.')
 .catch(()->console.log 'backup error!')


# J, JSON read/write factory
J = (fname='log.db')->
 f       = pathFullname fname
 bakFile = pathFullname "backup.#{fname}"

 write = (data)->
  backupFile(f, bakFile)

  fs.promises
   .writeFile(f, to_s(data)  ) # neat formatting
   .then(() -> console.log Object.keys(data))
   .catch((err)->console.log err)

 read = (fn)->
  fs.promises
   .readFile(f)
   .then((data)->
    d = if data? then JSON.parse(data) else String(data)
    fn( d )
   )
   .catch((err)->
    console.log [err.message, "oops! creating #{f}... do it again"].join("\n")
    writeBlank(f) unless fs.existsSync(f)

   )

 {read, write}


# DB factory
DB = (db={})->
 newdb = {...db} # clone

 # add and return a new DB factory
 add = (content)->
  e = {time: timenow(), log: content}
  (newdb[pwd()] ||= []).push e
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


not_found = ->
  [{info: '404'}]

# main
[...content] = process.argv[2...]

[head, ...tail] = content

if content.length >= 1

 if head is '.'
  J()
  .read (data) ->
    d = if data[pwd()]? then data[pwd()] else not_found()
    console.log Y(d)
 else
  update content

else
 J()
 .read (data) ->
    Object.keys(data).map (k)->
      console.log k
      console.log Y(data[k])
