gulp       = require 'gulp'
path       = require 'path'
del        = require 'del'
coffee     = require 'gulp-coffee'
sourcemaps = require 'gulp-sourcemaps'

nodemon    = require 'gulp-nodemon'
#nodeInspector = require 'node-insector' # required to have installed, not used
# compile coffeescript
gulp.task 'coffee', ->
    gulp.src path.join __dirname, 'src', '*.coffee'
        .pipe sourcemaps.init()
        .pipe coffee()
        .on 'error', (e) ->
            console.log "ERROR: #{e.toString()}"
        .pipe sourcemaps.write()
        .pipe gulp.dest path.join __dirname, 'lib'

makeTask = (name) ->
  gulp.task name, ['coffee'], ()->

    files = ['./Cookies', './cookies.json', './refreshtoken.txt']
    del files
    .then (paths) ->
      console.log 'INFO: Deleted paths:\n  - ', paths.join('\n  - ')
    .then () ->
      gulp.src path.join __dirname, name, '*'
        .pipe gulp.dest(__dirname)
      .on 'end', () ->
        nodemon {
          exec: 'node --debug --inspect'
          ext: 'coffee'
          watch: './src/*'
          script: './lib/login.js'
          verbose: true
          tasks: ['coffee']
        }
        .on('start',[''])
        #require('./lib/login.js')

for el in ['av', 'jma', 'lmc']
  makeTask(el)

gulp.task 'default', ['jma']
