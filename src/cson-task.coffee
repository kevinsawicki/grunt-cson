path = require 'path'
_ = require 'underscore'
CSON = require 'season'

module.exports = (grunt) ->
  grunt.registerMultiTask 'cson', 'Compile CSON files to JSON', ->
    requireRoot = @options().requireRoot ? false

    for mapping in @files
      source = mapping.src[0]
      destination = mapping.dest

      try
        object = CSON.readFileSync(source)

        if requireRoot and (not _.isObject(object) or _.isArray(object))
          grunt.log.error("#{source} does not contain a root object")
          return false

        grunt.file.mkdir(path.dirname(destination))
        CSON.writeFileSync(destination, object)
        grunt.log.writeln("File #{destination.cyan} created.")
      catch error
        grunt.log.error("Parsing #{source.cyan} failed: #{error.message}")
        return false

    fileCount = @files.length
    grunt.log.ok("#{fileCount} #{grunt.util.pluralize(fileCount, 'file/files')} compiled to JSON.")
