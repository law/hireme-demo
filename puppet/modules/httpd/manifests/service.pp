class httpd::service {
  service { $::httpd::httpd_svc:
    enable    => true,
    ensure    => 'running',
    require   => Class['httpd::config'],
    subscribe => File[$::httpd::httpd_conf]
  }
}
