fs = require 'fs'
path = require 'path'

_ = require 'underscore-plus'
CSONParser = require 'cson-parser'
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
      expect(_.isEqual(JSON.parse(fs.readFileSync(jsonPath)), {a: 1, b: {c: true}})).toBe true

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

  describe 'cachePath option', ->
    it 'only compiles uncached files', ->
      spyOn(CSONParser, 'parse').andCallThrough()

      tempDirectory = temp.mkdirSync('grunt-cson-')
      cacheDirectory = path.join(tempDirectory, 'cache')

      grunt.config.init
        pkg: grunt.file.readJSON(path.join(__dirname, 'fixtures', 'package.json'))

        cson:
          options:
            cachePath: cacheDirectory

          glob_to_multiple:
            expand: true
            src: ['**/fixtures/valid.cson', '**/fixtures/same-as-valid.cson']
            dest: tempDirectory
            ext: '.json'

      grunt.loadTasks(path.resolve(__dirname, '..', 'tasks'))

      tasksDone = false
      grunt.registerTask 'done', 'done',  -> tasksDone = true
      grunt.task.run(['cson', 'done']).start()
      waitsFor -> tasksDone
      runs ->
        jsonPath1 = path.join(tempDirectory, 'spec', 'fixtures', 'valid.json')
        jsonPath2 = path.join(tempDirectory, 'spec', 'fixtures', 'same-as-valid.json')
        json1 = fs.readFileSync(jsonPath1, 'utf8')
        json2 = fs.readFileSync(jsonPath2, 'utf8')

        expect(_.isEqual(JSON.parse(json1), {a: 1, b: {c: true}})).toBe true
        expect(json1).toBe json2
        expect(CSONParser.parse.callCount).toBe 1
        expect(fs.readdirSync(cacheDirectory).length).toBe 1
