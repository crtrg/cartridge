# Cartridge

## OPS

### Updating the Procfile

If you update the procfile, you have to update the upstart scripts. As a privileged user:

  sudo bundle exec foreman export upstart /etc/init -a cartridge

then restart the services

For more info:

[http://michaelvanrooijen.com/articles/2011/06/08-managing-and-monitoring-your-ruby-application-with-foreman-and-upstart/](http://michaelvanrooijen.com/articles/2011/06/08-managing-and-monitoring-your-ruby-application-with-foreman-and-upstart/)
