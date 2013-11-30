module.exports = function(grunt) {

  grunt.initConfig({
    coffee: {
      dist: {
        expand: true,
        cwd: 'src/js',
        src: ['**/*.coffee'],
        dest: '.tmp/js',
        ext: '.js'
      }
    },
    uglify: {
      options: {
        banner: '/*! Built with Grunt */',
        compress: false
      },
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/js',
          src: ['*.js'],
          dest: 'dist/js',
          ext: '.js'
        }, {
          src: ['bower_components/underscore/underscore.js'],
          dest: 'dist/js/underscore.js'
        }]
      }
    },
    less: {
      dist: {
        options: {
          yuicompress: true,
          concat: false
        },
        files: [{
          expand: true,
          cwd: 'src/css',
          src: ['*.less'],
          dest: 'dist/css',
          ext: '.css'
        }]
      }
    },
    htmlmin: {
      dist: {
        options: {
          removeComments: true,
          collapseWhitespace: true
        },
        files: [{
          expand: true,
          cwd: 'src',
          src: ['**/*.html'],
          dest: 'dist',
          ext: '.html'
        }]
      }
    },
    imagemin: {
      dist: {
        options: {
          removeComments: true
        },
        files: [{
          expand: true,
          cwd: 'src',
          src: ['**/*.{png,jpg,jpeg}'],
          dest: 'dist',
        }]
      }
    },
    copy: {
      dist: {
        files: [{
          expand: true,
          cwd: 'src',
          src: ['**/*.{webm}'],
          dest: 'dist',
        }]
      }
    },
    concurrent: {
      build: ['coffee', 'less', 'imagemin', 'htmlmin', 'copy'],
      postbuild: ['uglify']
    },
    clean: {
      pre: ['dist'],
      post: ['.tmp']
    }
  });

  grunt.loadNpmTasks('grunt-concurrent');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-imagemin');
  grunt.loadNpmTasks('grunt-contrib-htmlmin');

  grunt.registerTask('default', ['clean:pre', 'concurrent:build', 'concurrent:postbuild', 'clean:post']);

};