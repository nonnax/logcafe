#!/usr/bin/env coffee
# Id$ nonnax 2023-10-28 20:26:20 +0800
os = require 'os'
path = require 'path'
fs = require 'fs'

Dir= (path="") ->
 home= -> Dir(os.homedir())
 pwd= -> Dir(process.cwd())
 name= -> Dir(__dirname)
 value= -> path

 {
  home,
  pwd,
  name,
  value,
  short: path.replace os.homedir() , ''
 }

module.exports= {Dir}
# console.log  Dir().pwd().short
# console.log  Dir().name().short
