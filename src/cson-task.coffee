path = require 'path'
_ = require 'underscore'
CSON = require 'season'

module.exports = (grunt) ->
  grunt.registerMultiTask 'cson', 'Compile CSON files to JSON', ->
    rootObject = @options().rootObject ? false

    for mapping in @files
      source = mapping.src[0]
      destination = mapping.dest

      try
        content = CSON.readFileSync(source)

        if rootObject and (not _.isObject(content) or _.isArray(content))
          grunt.log.error("#{source} does not contain a root object")
          return false

        json = JSON.stringify(content, null, 2)
        grunt.file.write(destination, "#{json}\n")
        grunt.log.writeln("File #{destination.cyan} created.")
      catch error
        grunt.log.error("Parsing #{source.cyan} failed: #{error.message}")
        return false

    fileCount = @files.length
    grunt.log.ok("#{fileCount} #{grunt.util.pluralize(fileCount, 'file/files')} compiled to JSON.")
