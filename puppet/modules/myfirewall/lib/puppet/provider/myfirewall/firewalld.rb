# encoding: UTF-8

Puppet::Type.type(:myfirewall).provide(:firewalld) do
  @doc = <<-EOS
            This Firewall module will modify the firewalld firewall.
            The following are examples of how to use provider and type
            Examples:

           Firewall service:
           myfirewall { 'Firewall Test':
             ensure          => present,
             name            => 'public',
             zone            => 'public',
             service         => 'https',
             permanent       => true,
           }

           Adding a permanent firewall rule service:
           myfirewall { 'Firewall Rule':
             ensure     => present,
             name       => 'public',
             zone       => 'public',
             port       => '3000',
             protocol   => 'tcp',
             permanent  => true,
           }

           Remove a service
           myfirewall { 'Second richrule':
             ensure     => absent,
             zone       => 'public',
             protocol   => 'tcp',
             port       => '1534',
             notify     =>  Exec['Reloading firewall rules'],
           }


           Remove port and protocol:
           myfirewall { 'Second richrule':
             ensure     => absent,
             zone       => 'public',
             port       => $myport,
             protocol   => 'tcp',
             notify     =>  Exec['Reloading firewall rules'],
           }

           Add firewall richrule:
           myfirewall { 'Firewall Rule':
             ensure     => absent,
             zone       => 'public',
             richrule   => 'rule family="ipv4" source address="192.168.10.0/24" port port="3001" protocol="tcp" accept',
             permanent  => true,
           }

           Adding multiple rich rules with heira:
           myfirewall { 'Firewall Rule':
             ensure     => absent,
             zone       => 'public',
             richrule   => $richrule1,
             permanent  => true,
           }

           /myfirewall/hieradata/test02.familyguy.local.yaml
           myfirewall::myrichrule1: 
             - rule family="ipv4" source address="192.168.10.0/24" port port="3001" protocol="tcp" accept
             - rule family="ipv4" source address="192.168.10.0/24" port port="3051" protocol="tcp" accept

          Adding ports with multiple protocols (currently tcp and udp)
          myfirewall { 'Second richrule':
            ensure     => absent,
            zone       => 'public',
            port       => $myports,
            tcp_udp    => true,
            notify     =>  Exec['Reloading firewall rules'],
           }

          Adding multiple ports with a single protocol
          myfirewall { 'Second':
            ensure     => present,
            zone       => 'public',
            port       => $myports,
            protocol   => 'tcp',
            notify     =>  Exec['Reloading firewall rules'],
           }

          /myfirewall/hieradata/test02.familyguy.local.yaml
          myfirewall::myports:
            - 53
            - 22
            - 21
            - 110
  EOS

  confine :osfamily => :redhat
  defaultfor :operatingsystemmajrelease => 7

  commands :firewalld => 'firewall-cmd'

  def build_parameters
    params = [] 

    if @resource[:zone] && "#{@resource[:ensure]}" == 'present'
      if @resource[:port] && @resource[:port].nil? && @resource[:protocol] && @resource[:protocol].nil?
        fail("You have to provide a zone, port and protocol")
      elsif @resource[:service] && @resource[:service].nil?
        fail("You have to provide a zone and service")
      elsif @resource[:richrule] && @resource[:richrule].nil?
        fail("You have to provide a zone and richrule")
      end
    elsif @resource[:zone] && "#{@resource[:ensure]}" == 'absent'
      if @resource[:port] && @resource[:port].nil? && @resource[:protocol] && @resource[:protocol].nil?
        fail("You have to provide a zone, port and protocol")
      elsif @resource[:service] && @resource[:service].nil?
        fail("You have to provide a zone and service")
      elsif @resource[:richrule] && @resource[:richrule].nil?
        fail("You have to provide a zone and richrule")
      end
    end
    
    if "#{@resource[:ensure]}" == 'present'
      params << "--zone=#{@resource[:zone]}" unless @resource[:zone].nil?
      if @resource[:service].is_a?(Array) && @resource[:service]
        @resource[:service].each do |myservice|
          params << "--add-service=#{myservice}" 
        end
      elsif @resource[:service] && !@resource[:service].nil?
          params << "--add-service=#{@resource[:service]}"
      end
      params << "--add-source=#{@resource[:source]}" unless @resource[:source].nil?
      if @resource[:richrule].is_a?(Array) && @resource[:richrule]
        @resource[:richrule].each do |rule|
          params << "--add-rich-rule=#{rule}" 
        end
      elsif @resource[:richrule] && !@resource[:richrule].nil?
          params << "--add-rich-rule=#{@resource[:richrule]}"
      end

      if @resource[:port].is_a?(Array) && !@resource[:port].nil? && @resource[:tcp_udp].nil?
        Puppet.debug("this is using resource port")
        @resource[:port].each do |myport|
          params << "--add-port=#{myport}/#{@resource[:protocol]}" 
        end
      elsif @resource[:port] && !@resource[:port].nil? && @resource[:tcp_udp].nil?
          params << "--add-port=#{@resource[:port]}/#{@resource[:protocol]}"
      end

      if @resource[:tcp_udp]
        protocols = [ 'udp', 'tcp' ]
          if @resource[:port].is_a?(Array) && !@resource[:port].nil?
            protocols.each do | proto|
              @resource[:port].each do |myport|
                params << "--add-port=#{myport}/#{proto}" unless @resource[:port].nil?
              end
            end
          elsif @resource[:port] && !@resource[:port].nil?
            protocols.each do |proto|
                params << "--add-port=#{@resource[:port]}/#{proto}" unless @resource[:port].nil?
            end
          end
      end

    else
      params << "--zone=#{@resource[:zone]}" unless @resource[:zone].nil?
      if @resource[:service].is_a?(Array) && @resource[:service]
        @resource[:service].each do |myservice|
          params << "--remove-service=#{myservice}" 
        end
      elsif @resource[:service] && !@resource[:service].nil?
          params << "--remove-service=#{@resource[:service]}"
      end
      params << "--remove-source=#{@resource[:source]}" unless @resource[:source].nil?
      if @resource[:richrule].is_a?(Array) && @resource[:richrule]
        @resource[:richrule].each do |rule|
          params << "--remove-rich-rule=#{rule}" 
        end
      elsif @resource[:richrule] && !@resource[:richrule].nil?
          params << "--remove-rich-rule=#{@resource[:richrule]}"
      end

      if @resource[:port].is_a?(Array) && @resource[:port] && @resource[:tcp_udp].nil?
        @resource[:port].each do |myport|
          params << "--remove-port=#{myport}/#{@resource[:protocol]}" 
        end
      elsif @resource[:port] && !@resource[:port].nil? && @resource[:tcp_udp].nil?
          Puppet.debug("this is the resource port")
          params << "--remove-port=#{@resource[:port]}/#{@resource[:protocol]}"
      end

      if @resource[:tcp_udp]
        protocols = [ 'udp', 'tcp' ]
          if @resource[:port].is_a?(Array) && !@resource[:port].nil?
            protocols.each do | proto|
              @resource[:port].each do |myport|
                params << "--remove-port=#{myport}/#{proto}" unless @resource[:port].nil?
              end
            end
          elsif @resource[:port] && !@resource[:port].nil?
            protocols.each do |proto|
                params << "--remove-port=#{@resource[:port]}/#{proto}" unless @resource[:port].nil?
            end
          end
      end
     end

    params.each do |key|
      Puppet.debug("#{key}")
    end
   params
  end

  def firewalldestroy
    Puppet.debug("Deleting temporary firewall rule")
    options = build_parameters
    firewalld(*options)
  end

  def firewalldestroyperm
    Puppet.debug("Deleting permanent firewall rule")
    options = build_parameters
    firewalld(*options)
    firewalld(*options, '--permanent')
  end


  def firewallcreate
    Puppet.debug("Creating temporary firewall rule")
    options = build_parameters
    firewalld(*options)
  end

  def firewallcreateperm
    Puppet.debug("Creating permanent firewall rule")
    options = build_parameters
    firewalld(*options)
    firewalld(*options, '--permanent')
  end

  def check
   if @resource[:permanent] == true
     if @resource[:port]
       fwlistperm = firewalld('--list-ports', "--zone=#{@resource[:zone]}", '--permanent')
       Puppet.debug("Checking if permanent port/protocol rule is active in firewall")
       if @resource[:port].is_a?(Array) && @resource[:port]
        resource[:port].each do |port|
          if "#{fwlistperm}".include?"#{port}"
            Puppet.debug("port listed in permanent rules for firewall.")
            next
            #return true
          else
           Puppet.debug("port is not listed in permanent rules for firewall.")
           return false
          end
        end
       elsif "#{fwlistperm}".include?"#{@resource[:port]}"
         Puppet.debug("port is listed in permanent rules for firewall.")
         return true
       else 
         Puppet.debug("port is not listed in permanent rules for firewall.")
         return false
       end

     elsif @resource[:source]
       Puppet.debug("Checking if permanent source rule is active in firewall")
       fwlistperm = firewalld('--list-sources', '--permanent', "--zone=#{@resource[:zone]}")
       if "#{fwlistperm}".include?"#{@resource[:source]}"
         Puppet.debug("source is listed in permanent rules for firewall.")
         return true
       else
         Puppet.debug("source is not listed in permanent rules for firewall.")
         return false
       end 

     elsif @resource[:richrule]
       Puppet.debug("Checking if permanent rich rule is active in firewall")
       fwlistperm = firewalld('--list-rich-rules', '--permanent', "--zone=#{@resource[:zone]}")
       if @resource[:richrule].is_a?(Array) && @resource[:richrule]
        resource[:richrule].each do |rule|
          if "#{fwlistperm}".include?"#{rule}"
            Puppet.debug("richrule is listed in permanent rules for firewall.")
            next
            #return true
          else
           Puppet.debug("richrule is not listed in permanent rules for firewall.")
           return false
          end
        end
       elsif "#{fwlistperm}".include?"#{@resource[:richrule]}"
         Puppet.debug("richrule is listed in permanent rules for firewall.")
         return true
       else 
         Puppet.debug("richrule is not listed in permanent rules for firewall.")
         return false
       end

     elsif @resource[:service]
       Puppet.debug("Checking if permanent service rule is active in firewall")
       fwlistperm = firewalld('--list-services', "--zone=#{@resource[:zone]}", '--permanent')
       if @resource[:service].is_a?(Array) && @resource[:service]
        resource[:service].each do |myservice|
          if "#{fwlistperm}".include?"#{myservice}"
            Puppet.debug("service is listed in permanent rules for firewall.")
            next
            #return true
          else
           Puppet.debug("service is not listed in permanent rules for firewall.")
           return false
          end
        end
       elsif "#{fwlistperm}".include?"#{@resource[:service]}"
         Puppet.debug("service is listed in permanent rules for firewall.")
         return true
       else
         Puppet.debug("service is not listed in permanent rules for firewall.")
         return false
       end 
     end

   else @resource[:permanent] == false
     if @resource[:port]
       Puppet.debug("Checking if temporary port/protocol rule is active in firewall")
       fwlistperm = firewalld('--list-ports', "--zone=#{@resource[:zone]}")
       if "#{fwlistperm}".include?"#{@resource[:port]}/#{@resource[:protocol]}"
         Puppet.debug("port/protocol is listed in temporary rules for firewall.")
         return true
       else
         Puppet.debug("port/protocol is not listed in temporary rules for firewall.")
         return false
       end 

     elsif @resource[:source]
       Puppet.debug("Checking if temporary source rule is active in firewall")
       fwlistperm = firewalld('--list-sources', "--zone=#{@resource[:zone]}")
       if "#{fwlistperm}".include?"#{@resource[:source]}"
         Puppet.debug("source is listed in temporary rules for firewall.")
         return true
       else
         Puppet.debug("source is not listed in temporary rules for firewall.")
         return false
       end 

     elsif @resource[:richrule]
       Puppet.debug("Checking if temporary rich rule is active in firewall")
       fwlistperm = firewalld('--list-rich-rules', "--zone=#{@resource[:zone]}")
       if @resource[:richrule].is_a?(Array) && @resource[:richrule]
        resource[:richrule].each do |rule|
          if "#{fwlistperm}".include?"#{rule}"
            Puppet.debug("richrule is listed in temporary rules for firewall.")
            next
            #return true
          else
           Puppet.debug("richrule is not listed in temporary rules for firewall.")
           return false
          end
        end

       elsif "#{fwlistperm}".include?"#{@resource[:richrule]}"
         Puppet.debug("richrule is listed in permanent rules for firewall.")
         return true
       else 
         Puppet.debug("richrule is not listed in permanent rules for firewall.")
         return false
       end

     elsif @resource[:service]
       Puppet.debug("Checking if permanent service rule is active in firewall")
       fwlistperm = firewalld('--list-services', "--zone=#{@resource[:zone]}", '--permanent')
       if @resource[:service].is_a?(Array) && @resource[:service]
        resource[:service].each do |myservice|
          if "#{fwlistperm}".include?"#{myservice}"
            Puppet.debug("service is listed in permanent rules for firewall.")
            next
            #return true
          else
           Puppet.debug("service is not listed in permanent rules for firewall.")
           return false
          end
        end

       elsif "#{fwlistperm}".include?"#{@resource[:service]}"
         Puppet.debug("service is listed in permanent rules for firewall.")
         return true
       else
         Puppet.debug("service is not listed in permanent rules for firewall.")
         return false
       end 
     end
   end
  end

  def create
   if @resource[:permanent] == true
     firewallcreateperm
   else
     firewallcreate
   end
  end

  def destroy
   if @resource[:permanent] == true
     firewalldestroyperm
   else
     firewalldestroy
   end
  end

  def exists?
    #@sourcefile = "/etc/firewalld/zones/#{@resource[:zone]}.xml"
    if @resource[:permanent] == true
      Puppet.debug("The permanent option was set to true.  Continuing with permanent firewall rule.")
      check
    else
      Puppet.debug("The permanent option was not set to true.  Continuing with temporary firewall rule.")
      check
    end
  end
end
