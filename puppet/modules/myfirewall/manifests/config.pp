class myfirewall::config inherits myfirewall {

  #myfirewall { 'First richrule':
  #  ensure     => absent,
  #  zone       => 'public',
  #  richrule   => $myrichrule,
  #  permanent  => true,
  # }
  myfirewall { 'Second richrule':
    ensure     => present,
    zone       => 'public',
    service    => $servicerule,
    notify     =>  Exec['Reloading firewall rules'],
   }
}
