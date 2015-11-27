class httpd::config {
  file { $::httpd::httpd_conf:
    source  => [
      "puppet:///modules/httpd/${fqdn}/httpd.conf",
      "puppet:///modules/httpd/${operatingsystem}/httpd.conf",
      "puppet:///modules/httpd/${lsbmajdistrelease}/httpd.conf",
      'puppet:///modules/httpd/httpd.conf'
    ],
    require => Class['httpd::install']
  }
  
  file { 'httpd_siteconfig':
    path    => '/etc/httpd/sites-enabled',
    mode    => '0755',
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => Class['httpd::install']
  }

  file { $::httpd::httpd_vhost_conf:
    source  => [
      "puppet:///modules/httpd/${fqdn}/httpd_vhost.conf",
      "puppet:///modules/httpd/${operatingsystem}/httpd_vhost.conf",
      "puppet:///modules/httpd/${lsbmajdistrelease}/httpd_vhost.conf",
      'puppet:///modules/httpd/httpd_vhost.conf'
    ],
    require => File['httpd_siteconfig']
  }
}
