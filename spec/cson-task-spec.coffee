fs = require 'fs'
path = require 'path'
grunt = require 'grunt'
temp = require 'temp'

describe 'CSON task', ->
  it 'compiles valid CSON files to JSON', ->
    tempDirectory = temp.mkdirSync('grunt-cson-')

    grunt.config.init
      pkg: grunt.file.readJSON(path.join(__dirname, 'fixtures', 'package.json'))

      cson:
        glob_to_multiple:
          expand: true
          src: ['**/fixtures/valid.cson' ]
          dest: tempDirectory
          ext: '.json'

    grunt.loadTasks(path.resolve(__dirname, '..', 'tasks'))

    tasksDone = false
    grunt.registerTask 'done', 'done',  -> tasksDone = true
    grunt.task.run(['cson', 'done']).start()
    waitsFor -> tasksDone
    runs ->
      jsonPath = path.join(tempDirectory, 'spec', 'fixtures', 'valid.json')
      expect(fs.existsSync(jsonPath)).toBe true
      expect(fs.statSync(jsonPath).isFile()).toBe true

  it 'fails on invalid CSON files', ->
    tempDirectory = temp.mkdirSync('grunt-cson-')

    grunt.config.init
      pkg: grunt.file.readJSON(path.join(__dirname, 'fixtures', 'package.json'))

      cson:
        glob_to_multiple:
          expand: true
          src: ['**/fixtures/invalid.cson' ]
          dest: tempDirectory
          ext: '.json'

    grunt.loadTasks(path.resolve(__dirname, '..', 'tasks'))

    tasksDone = false
    grunt.registerTask 'done', 'done',  -> tasksDone = true
    grunt.task.run(['cson', 'done']).start()
    waitsFor -> tasksDone
    runs ->
      jsonPath = path.join(tempDirectory, 'spec', 'fixtures', 'invalid.json')
      expect(fs.existsSync(jsonPath)).toBe false

  describe 'rootObject option', ->
    it 'fails if the CSON file does not have a root object', ->
      tempDirectory = temp.mkdirSync('grunt-cson-')

      grunt.config.init
        pkg: grunt.file.readJSON(path.join(__dirname, 'fixtures', 'package.json'))

        cson:
          options:
            rootObject: true
          glob_to_multiple:
            expand: true
            src: ['**/fixtures/array.cson' ]
            dest: tempDirectory
            ext: '.json'

      grunt.loadTasks(path.resolve(__dirname, '..', 'tasks'))

      tasksDone = false
      grunt.registerTask 'done', 'done',  -> tasksDone = true
      grunt.task.run(['cson', 'done']).start()
      waitsFor -> tasksDone
      runs ->
        jsonPath = path.join(tempDirectory, 'spec', 'fixtures', 'array.json')
        expect(fs.existsSync(jsonPath)).toBe false
