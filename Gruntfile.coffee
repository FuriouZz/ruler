module.exports = (grunt)->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    #######################################
    #   Task : Connect
    #   Create a little apache server
    #   Tasks : livereload / dist
    #######################################
    connect:
      options:
        port: 9000
        livereload: 35729
        hostname: 'localhost'

      dev:
        options:
          open: true
          base: [
            '.tmp'
            'app'
          ]

      dist:
        options:
          open: true
          base: 'dist'
          livereload: false
          keepalive: true

    #######################################
    #   Task : Notify
    #   Send a notification popin
    #   Tasks : watch / connect/ dist
    #######################################
    notify:
      watch:
        options:
          message: 'File reloaded'

      connect:
        options:
          message: 'File reloaded!'

      dist:
        options:
          message: 'Server is ready!'

    #######################################
    #  Task : Watch
    #  Watch files. Reload the page if a file are edited
    #  Tasks : stylus / livereload
    #######################################
    watch:
      livereload:
        options:
          livereload:
            options:
              open: true
              base: [
                '.tmp'
                'app'
              ]

        files: [
          'app/**/*.html',
          '.tmp/styles/**/*.css',
          '{.tmp, app}/scripts/**/*.js',
          'app/assets/images/**/*.{gif,jpeg,jpg,png,svg,webp}'
        ]

      scripts:
        files: ['app/scripts/**/*.js'],
        options:
          livereload: true

      coffee:
        files: ['app/scripts/**/*.{coffee,litcoffee,coffee.md}'],
        tasks: ['newer:coffee:dist', 'notify:watch']
        livereload: true

      stylus:
        files: ['app/styles/**/*.styl']
        tasks: ['stylus']
        livereload: true


    #######################################
    #  Task : Stylus
    #  Compile stylus file
    #  Tasks : stylus
    #######################################
    stylus:
      options:
        compress: false
        paths: ['app/styles/stylus']

      compile:
        files:
          '.tmp/styles/app.css' : 'app/styles/**/*.styl'

    #######################################
    #   Task : Clean
    #   Clean tempory files
    #   Tasks : dist / tmp
    #######################################
    clean:
      dist:
        files: [
          dot: true
          src: ['.tmp', 'dist/*', '!dist/.git*']
        ]

      tmp:
        files: [
          dot: true
          src: '.tmp'
        ]

    #######################################
    #   Task : Copy
    #   Copy files
    #   Tasks : dist / styles
    #######################################
    copy:
      dist:
        files: [
          expand: true
          dot: true
          cwd: 'app'
          dest: 'dist'
          src: [
            '*.{ico,png,txt}'
            '.htaccess'
            'assets/**'
            'projects/**'
            '*.*'
            'styles/fonts/**/*.*'
            'scripts/**/{,*}*.json'
          ]
        ]

      compiled:
        expand: true
        dot: true
        cwd: '.tmp/concat'
        dest: 'dist/'
        src: '**/*.{css,js}'

      styles_uncompiled:
        expand: true
        dot: true
        cwd: 'app/styles'
        dest: '.tmp/styles'
        src: '**/*.css'

      scripts_uncompiled:
        expand: true
        dot: true
        cwd: 'app/scripts'
        dest: '.tmp/scripts'
        src: '**/*.js'

    ####################
    ##     USEMIN     ##
    ####################
    ## Optimize CSS & JS files
    ## Minify/Uglify/Regroup
    useminPrepare:
      options:
        dest: "dist"
      html: 'app/index.html'#['app/index.html', 'app/projects/**/*.html']

    usemin:
      options:
        assetsDirs: ['dist']
      html: ['dist/**/*.html']#['dist/{,*/}*.html'],
      css:  ['dist/styles/{,*/}*.css']

    ####################
    ##     UGLIFY     ##
    ####################
    ## Optimize JS files
    uglify:
      options:
        beautify: true
        preserveComments: true
        mangle: false
        compress: false

    ####################
    ##     CSSMIN     ##
    ####################
    ## Optimize CSS files
    cssmin:
      options:
        expand: false

    #######################################
    #  Task : Concurrent
    #  Launch multiple task in same time
    #  Tasks : dev / dist
    #######################################
    concurrent:
      dev: [
        'stylus'
        'coffee'
        'copy:compiled'
      ]

      dist: [
        'stylus'
        'coffee'
      ]

      copy_uncompiled: [
        'copy:dist'
        'copy:styles_uncompiled'
        'copy:scripts_uncompiled'
      ]

      copy_compiled: [
        'copy:compiled'
      ]

    #######################################
    #  Task : Coffee
    #  Compile coffee files
    #  Tasks : dist
    #######################################
    coffee:
      dist:
        files: [
          expand: true
          cwd: 'app/scripts/coffee'
          src: '**/*.{coffee,litcoffee,coffee.md}',
          dest: '.tmp/scripts',
          ext: '.js'
        ]


    ###############
    ## BOWER

    'bower-install':
      target:
        src: [
          'app/**/*.html'
        ]
        ignorePath: 'app/'

    bower:
      install:
        options:
          targetDir: "app/vendors"
          install: true
          verbose: true
          layout: "byComponent"
          cleanBowerDir: false
          copy: false

    grunt.loadNpmTasks('grunt-contrib-connect')
    grunt.loadNpmTasks("grunt-contrib-stylus")
    grunt.loadNpmTasks("grunt-contrib-coffee")
    grunt.loadNpmTasks("grunt-contrib-concat")
    grunt.loadNpmTasks("grunt-contrib-cssmin")
    grunt.loadNpmTasks("grunt-contrib-uglify")
    grunt.loadNpmTasks("grunt-bower-install")
    grunt.loadNpmTasks("grunt-contrib-watch")
    grunt.loadNpmTasks("grunt-contrib-clean")
    grunt.loadNpmTasks("grunt-relative-root")
    grunt.loadNpmTasks("grunt-contrib-copy")
    grunt.loadNpmTasks("grunt-bower-task")
    grunt.loadNpmTasks("grunt-concurrent")
    grunt.loadNpmTasks("grunt-notify")
    grunt.loadNpmTasks("grunt-usemin")
    grunt.loadNpmTasks("grunt-newer")

    grunt.registerTask("run", [
        "clean:tmp"
        "concurrent:dev"
        "connect:dev"
        "notify:connect"
        "watch"
    ])

    grunt.registerTask("dist", [
        "clean:dist"
        "useminPrepare"
        "concurrent:dist"
        "concurrent:copy_uncompiled"
        "concat"
        "concurrent:copy_compiled"
        # "uglify"
        "cssmin"
        "usemin"
        # "connect:dist"
        "notify:connect"
    ])

    grunt.registerTask "install", [
      "bower:install"
      "bower-install"
      # "shell:bundle-install"
    ]

    # Default task(s).
    grunt.registerTask('default', ['run'])
