class myfirewall::install inherits myfirewall {

  package { $firewall_service:
    ensure => installed,
  }
}
