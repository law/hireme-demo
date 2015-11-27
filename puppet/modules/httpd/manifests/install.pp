class httpd::install {
  package { $::httpd::httpd_packages:
    ensure => installed,
  }
}
