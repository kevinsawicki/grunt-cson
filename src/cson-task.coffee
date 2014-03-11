path = require 'path'
_ = require 'underscore-plus'
CSONParser = require 'cson-safe'

module.exports = (grunt) ->
  grunt.registerMultiTask 'cson', 'Compile CSON files to JSON', ->
    rootObject = @options().rootObject ? false

    for mapping in @files
      source = mapping.src[0]
      destination = mapping.dest

      try
        sourceData = grunt.file.read(source, 'utf8')
        content = CSONParser.parse(sourceData)

        if rootObject and (not _.isObject(content) or _.isArray(content))
          grunt.log.error("#{source.yellow} does not contain a root object.")
          return false

        json = JSON.stringify(content, null, 2)
        grunt.file.write(destination, "#{json}\n")
        grunt.log.writeln("File #{destination.cyan} created.")
      catch error
        grunt.log.writeln("Parsing #{source.yellow} failed.")
        {message, location} = error
        grunt.log.error(message.red) if message
        if location?
          start = error.location.first_line
          end = error.location.last_line
          lines = sourceData.split('\n')
          for lineNumber in [start..end]
            errorLine = lines[lineNumber]
            continue unless errorLine?
            grunt.log.error("#{lineNumber+1}: #{lines[lineNumber]}")
        return false

    fileCount = @files.length
    grunt.log.ok("#{fileCount} #{grunt.util.pluralize(fileCount, 'file/files')} compiled to JSON.")
