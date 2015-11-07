node 'test.familyguy.local' { 
  include rabbitmq
}
node 'test02.familyguy.local' { 
  class {'role::sensu_server':}
}
