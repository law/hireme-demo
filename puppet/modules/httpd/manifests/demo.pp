class httpd::demo {
  file { 'httpd_demodir':
    path    => '/var/www/law-demo',
    mode    => '0755',
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => Class['httpd::config']
  }

  package { 'webapp':
    provider => 'rpm',
    source   => '/root/demo/assets/webapp-1.0-1.noarch.rpm',
  }
  
}
