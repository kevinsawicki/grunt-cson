# Grunt CSON plugin

[Grunt](http://gruntjs.com) plugin to compile CSON files to JSON.

## Installing

```sh
npm install grunt-cson
```

## Building
  * Clone the repository
  * Run `npm install`
  * Run `grunt` to compile the CoffeeScript code
  * Run `grunt test` to run the specs
  
## Configuring

Add the following to your `Gruntfile.coffee`:

```coffeescript
grunt.initConfig
  cson:
    glob_to_multiple:
      expand: true
      src: ['src/**/*.cson' ]
      dest: 'lib'
      ext: '.json'

grunt.loadNpmTasks('grunt-cson')
```

Then simply run `grunt cson` to compile all the `.cson` files under `src/`
to `.json` files under `lib/`.
