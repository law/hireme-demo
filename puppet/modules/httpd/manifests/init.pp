class httpd {
  File {  owner => 'root',
    group => 'root',
    mode => '0644'
  }

  $httpd_packages = [ 'httpd', 'git' ]
  $httpd_svc = 'httpd'
  $httpd_conf = '/etc/httpd/conf/httpd.conf'
  $httpd_vhost_conf = '/etc/httpd/sites-enabled/httpd_vhost.conf'

  include httpd::install
  include httpd::config
  include httpd::service
  include httpd::demo

}
