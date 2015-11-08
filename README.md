# myfirewall

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with myfirewall](#setup)
    * [Installing myfirewall](#Installing my firewall)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module is meant to provide a simple interface to manage firewalld (currently)
and eventually iptables.

The module currently only supports RedHat 7 family, but I am working to allow this 
module to work with other OSes.

## Module Description

This module provides a provider and type for the firewalld service.  Currently,
firewalld is the only firewall supported, however, I am in the process of creating
an iptables provider.

This module manages the firewwalld service and configures the rules for the
firewall.

## Setup

### Installing myfirewall
In your puppet modules directory:

  git clone https://github.com/nohtyp/myfirewall.git

Ensure the module is present in your puppetmaster's own environment (it doesn't
have to use it) and that the master has pluginsync enabled.  Run the agent on
the puppetmaster to cause the custom types to be synced to its local libdir
(`puppet master --configprint libdir`) and then restart the puppetmaster so it
loads them.

## Usage

###Create firewall rule for https service in public zone:

<pre>
myfirewall { 'Firewall Test':
    ensure          => present,
    name            => 'public',
    zone            => 'public',
    service         => 'https',
    permanent       => true,
   }
</pre>

###Adding a permanent port/protocol firewall rule in public zone:

<pre>
myfirewall { 'Firewall Rule':
    ensure     => present,
    name       => 'public',
    zone       => 'public',
    port       => '3000',
    protocol   => 'tcp',
    permanent  => true,
   }
</pre>

###Remove a service

<pre>
myfirewall { 'Second richrule':
    ensure     => absent,
    zone       => 'public',
    protocol   => 'tcp',
    port       => '1534',
    notify     =>  Exec['Reloading firewall rules'],
   }
</pre>

###Add firewall richrule:

<pre>
myfirewall { 'Firewall Rule':
    ensure     => absent,
    zone       => 'public',
    richrule   => 'rule family="ipv4" source address="192.168.10.0/24" port port="3001" protocol="tcp" accept',
    permanent  => true,
   }
</pre>



###Advanced example with heira:
This example will create multiple rules in the firewall
that will use only tcp.

Adding multiple ports with a single protocol
<pre>
 myfirewall { 'Second':
    ensure     => present,
    zone       => 'public',
    port       => $myports,
    protocol   => 'tcp',
    notify     =>  Exec['Reloading firewall rules'],
   }
</pre>

##myfirewall/hieradata/test02.familyguy.local.yaml
<pre>
myfirewall::myports:
    - 53
    - 22
    - 21
    - 110
</pre>


## Reference

The following providers and types are created within this module:

###Types and Providers
- `myfirewall`
- `firewalld`

## Limitations

Currently this module is compatible with RedHat 7 family.  I am working on 
other OSes and will update this accordingly.  The module currently
supports the following options:

- `name`
- `zone`
- `protocol`
- `tcp_udp`
- `port` (allows string or array)
- `service` (allows string or array)
- `source`
- `richrule` (allows string or array)
- `permanent` (true|false)

Currently this module is working for RedHat 7 family.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**
This is the first release of this module.  I will be updating
the notes when applicable.
