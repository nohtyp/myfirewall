class myfirewall::params {

$firewall_status  = 'running'
$firewall_service = 'firewalld'
$myport = [ '22', '53', '25', '21' ]
$myproto = true
$servicerule = [ 'https', 'ftp', 'ssh' ]
#$myrichrule  = 'rule family="ipv4" source address="192.168.0.0/24" service name="http" accept'
#$myrichrule1 = [ 'rule family="ipv4" source address="192.168.10.0/24" port port="3000" protocol="tcp" accept',]
                 #'rule family="ipv4" source address="192.168.10.0/24" port port="3010" protocol="tcp" accept', 
                 #'rule family="ipv4" source address="192.167.0.0/24" port port="2010" protocol="tcp" accept', 
               
}
