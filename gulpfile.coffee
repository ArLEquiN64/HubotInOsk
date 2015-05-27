'use strict'

gulp = require 'gulp'
$ = (require 'gulp-load-plugins') lazy: false
del = require 'del'
es = require 'event-stream'
boolifyString = require 'boolify-string'

paths =
  lint: [
    './gulpfile.coffee'
    './scripts/**/*.coffee'
  ]
  watch: [
    './gulpfile.coffee'
    './scripts/**/*.coffee'
    './test/**/*.coffee'
    '!test/{temp,temp/**}'
  ]
  tests: [
    './test/**/*.coffee'
    '!test/{temp,temp/**}'
  ]
  source: [
    './scripts/**/*.coffee'
  ]


gulp.task 'lint', ->
  gulp.src paths.lint
    .pipe $.coffeelint('./coffeelint.json')
    .pipe $.coffeelint.reporter()

gulp.task 'clean', del.bind(null, ['./compile'])
gulp.task 'clean:coverage', del.bind(null, ['./coverage'])

gulp.task 'compile', ['lint'], ->
  es.merge(
    gulp.src paths.source
      .pipe $.sourcemaps.init()
      .pipe($.coffee(bare: true).on('error', $.util.log))
      .pipe $.sourcemaps.write()
      .pipe gulp.dest('./compile/src')
    gulp.src paths.tests
      .pipe $.sourcemaps.init()
      .pipe($.coffee({ bare: true }).on('error', $.util.log))
      .pipe $.sourcemaps.write()
      .pipe $.espower()
      .pipe gulp.dest('./compile/test')
  )

gulp.task 'istanbul', ['clean:coverage', 'compile'], (cb) ->
  gulp.src ['./compile/src/**/*.js']
    #Covering files
    .pipe $.istanbul({includeUntested: true})
    .pipe $.istanbul.hookRequire()
    .on 'finish', ->
      gulp.src ['./compile/test/**/*.js'], {cwd: __dirname}
        .pipe $.if(!boolifyString(process.env.CI), $.plumber())
        .pipe $.mocha()
        #Creating the reports after tests runned
        .pipe $.istanbul.writeReports()
        .on 'end', ->
          process.chdir __dirname
          cb()
  undefined

gulp.task 'watch', ['test'], ->
  gulp.watch paths.watch, ['test']

gulp.task 'default', ['test']
gulp.task 'test', ['istanbul']
