#
# @summary Install packet filtering rules for FreeIPA.
#
# @param allow_address_ipv4
#   IPv4 address to allow access from.
#
# @param allow_address_ipv6
#   IPv6 address to allow access from.
#
class easy_ipa::packetfilter::server (
  Variant[Stdlib::IP::Address::V4,Array[Stdlib::IP::Address::V4]] $allow_address_ipv4 = '127.0.0.1',
  Variant[Stdlib::IP::Address::V6,Array[Stdlib::IP::Address::V6]] $allow_address_ipv6 = '::1'
) {
  # Convert string parameters to arrays
  $allow_addresses_ipv4 = any2array($allow_address_ipv4)
  $allow_addresses_ipv6 = any2array($allow_address_ipv6)

  # A hash containing the data for packet filtering rules
  $services = { 'dns'             => { 'tcp' => 53,  'udp' => 53 },
    'http'            => { 'tcp' => 80 },
    'https'           => { 'tcp' => 443 },
    'kerberos'        => { 'tcp' => 88,  'udp' => 88 },
    'kerberos passwd' => { 'tcp' => 464, 'udp' => 464 },
    'ldaps'           => { 'tcp' => 636 },
    'ldap'            => { 'tcp' => 389 },
    'ntp'             => { 'udp' => 123 },
    'webcache'        => { 'tcp' => 8080 },
  }

  Firewall {
    chain    => 'INPUT',
    action   => 'accept',
  }

  $services.each |$service| {
    $service[1].each |$rule| {
      $service_name = $service[0]
      $protocol = $rule[0]
      $dport = $rule[1]

      $allow_addresses_ipv4.each |$addr_v4| {
        @firewall { "008 ipv4 accept ${service_name} ${protocol} ${dport} from ${addr_v4}":
          provider => 'iptables',
          proto    => $protocol,
          source   => $addr_v4,
          dport    => $dport,
          tag      => 'default',
        }
      }

      $allow_addresses_ipv6.each |$addr_v6| {
        @firewall { "008 ipv6 accept ${service_name} ${protocol} ${dport} from ${addr_v6}":
          provider => 'ip6tables',
          proto    => $protocol,
          source   => $addr_v6,
          dport    => $dport,
          tag      => 'default',
        }
      }
    }
  }
}
