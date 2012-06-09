#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Cartridge::Application.load_tasks

namespace :assets do
  desc 'Compile sass and coffeescript files and repackage jammit assets'
  task :generate => :environment do
    `compass compile --force`
    # Recompile coffeescript only if necessary, use rake barista:brew to force
    # recompilation
    Barista.compile_all! false, false
    require 'jammit'
    Jammit.package!

  end
end

# from https://gist.github.com/862102
desc 'Check Jammit packaging status'
task :before_deploy => :environment do
  Rake::Task['assets:precompile'].execute
  system "git add #{Rails.root}/public/assets/. && git commit -m 'automatically updated assets'"
end

task :deploy => :before_deploy do
  system "git push origin master"
  system "git push production master"
  system "rm -r #{Rails.root}/public/assets"
end
