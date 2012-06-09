desc 'deploy cartridge'
task :deploy do
  remote = `git remote show production 2> /dev/null`
  if remote.blank?
    puts "Please add the production remote. For example:"
    puts "\t$ git remote add production user@example.com:/path/to/myapp"
    return
  end
  system %{git push production master}
end
