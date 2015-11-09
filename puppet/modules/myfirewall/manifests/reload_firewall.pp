class myfirewall::reload_firewall inherits myfirewall {

  exec { 'Reloading firewall rules':
    path        => '/bin:/sbin',
    command     => 'firewall-cmd --reload',
    refreshonly => true,
  }
}
