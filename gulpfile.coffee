gulp = require 'gulp'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'
coffee = require 'gulp-coffee'
gulpUtil = require 'gulp-util'
del = require 'del'
nodemon = require 'gulp-nodemon'

serverSrc = 'src/server/**/*.coffee'
clientCoffeeSrc = 'src/client/cjsx/**/*.cjsx'
clientHtmlSrc = 'src/client/**/*.html'

src = [
  serverSrc
  clientCoffeeSrc
  clientHtmlSrc
]

script = './build/server/index.js'

gulp.task 'development', ['build'], ->
  gulp.watch src, ['build']
  nodemon
    script: script
    watch: 'build/server/'
    ext: 'js'

gulp.task 'start', ['build'], ->
  nodemon
    script: script

gulp.task 'build', ['build:server', 'build:client']

gulp.task 'build:server', ['clean'], ->
  gulp.src(serverSrc)
    .pipe(
      coffee
        bare: true
    )
    .pipe(gulp.dest './build/server/')

gulp.task 'build:client', ['build:client:cjsx', 'build:client:html']

gulp.task 'build:client:cjsx', ['clean'], ->
  browserify
    entries: './src/client/cjsx/app.cjsx'
    extensions: '.cjsx'
    debug: true
  .transform('coffee-reactify')
  .bundle()
  .pipe(source 'app.js')
  .pipe(buffer())
  .pipe(sourcemaps.init {loadmaps: true})
  .pipe(uglify())
  .pipe(sourcemaps.write './')
  .pipe(gulp.dest './build/client/js/')

gulp.task 'build:client:html', ['clean'], ->
  gulp.src(clientHtmlSrc)
    .pipe(gulp.dest './build/client/')

gulp.task 'clean', (callback) ->
  del 'build', callback
