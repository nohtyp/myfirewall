class myfirewall::config inherits myfirewall {

  myfirewall { 'Second richrule':
    ensure  => present,
    zone    => 'public',
    service => 'https',
    notify  =>  Exec['Reloading firewall rules'],
  }
}
