class myfirewall::service inherits myfirewall {

  service { $firewall_service:
    ensure => $firewall_status,
  }
}
