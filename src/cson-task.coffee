crypto = require 'crypto'
path = require 'path'
_ = require 'underscore-plus'
CSONParser = require 'cson-safe'

csonVersion = require('cson-safe/package.json').version

getCachePath = (source, options={}) ->
  {rootObject, cachePath} = options
  return null unless cachePath

  sha1 = crypto.createHash('sha1').update(source, 'utf8').digest('hex')
  if rootObject
    folderName = "#{csonVersion}-require-root"
  else
    folderName = csonVersion
  path.join(cachePath, folderName, "#{sha1}.json")

readFromCache = (grunt, fileCachePath) ->
  try
    grunt.file.read(fileCachePath, 'utf8')
  catch error
    null

writeToCache = (grunt, fileCachePath, json) ->
  try
    grunt.file.write(fileCachePath, json)

module.exports = (grunt) ->
  grunt.registerMultiTask 'cson', 'Compile CSON files to JSON', ->
    options = @options()
    {rootObject} = options
    rootObject ?= false
    fileCount = 0

    @files.forEach ({src, dest}) ->
      [source] = src

      try
        sourceData = grunt.file.read(source, 'utf8')

        fileCachePath = getCachePath(sourceData, options)
        json = readFromCache(grunt, fileCachePath) if fileCachePath

        unless json?
          content = CSONParser.parse(sourceData)

          if rootObject and (not _.isObject(content) or _.isArray(content))
            grunt.log.error("#{source.yellow} does not contain a root object.")
            return

          json = "#{JSON.stringify(content, null, 2)}\n"
          writeToCache(grunt, fileCachePath, json) if fileCachePath

        grunt.file.write(dest, json)
        fileCount++
        grunt.log.writeln("File #{dest.cyan} created.")

      catch error
        grunt.log.writeln("Parsing #{source.yellow} failed.")
        {message, location} = error
        message ?= 'Unknown error'
        grunt.log.error(message.red)
        if location?
          start = location.first_line
          end = location.last_line
          lines = sourceData.split('\n')
          for lineNumber in [start..end]
            errorLine = lines[lineNumber]
            continue unless errorLine?
            grunt.log.error("#{lineNumber+1}: #{lines[lineNumber]}")

    grunt.log.ok("#{fileCount} #{grunt.util.pluralize(fileCount, 'file/files')} compiled to JSON.")
    return false if @errorCount > 0
