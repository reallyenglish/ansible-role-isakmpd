require 'spec_helper'
require 'serverspec'

package = 'isakmpd'
service = 'isakmpd'
config  = '/etc/ipsec.conf'
user    = '_isakmpd'
group   = '_isakmpd'
ports   = [ 500, 4500 ]
conf_dir = '/etc/pf.conf.d'

describe file(conf_dir) do
  it { should be_directory }
end

describe file("#{ conf_dir }/ipsec_anchor.pf") do
  it { should be_file }
  its(:content) { should match /pass in quick on egress proto udp from \$isakmpd_me to <ipsec_peers> port \{ 500, 4500 \}/ }
  its(:content) { should match /pass in quick on egress proto udp from \$isakmpd_me to any port \{ 500, 4500 \}/ }
end

describe command('pfctl -sA') do
  its(:stdout) { should match /ipsec_anchor/ }
end

describe command('pfctl -sr -a ipsec_anchor') do
  its(:stdout) { should match Regexp.escape('pass in quick on egress inet proto udp from 192.168.68.1 to any port = 500') }
  its(:stdout) { should match Regexp.escape('pass in quick on egress inet proto udp from 192.168.68.1 to any port = 4500') }
end

describe file('/etc/rc.conf.local') do
  it { should be_file }
  its(:content) { should match /isakmpd_flags=-K/ }
  its(:content) { should match /ipsec=YES/ }
end

describe file(config) do
  it { should be_file }

  its(:content) { should match Regexp.escape('me = "192.168.68.1"') }

  its(:content) { should match /^ike esp from \$me to \$peer2 peer \$peer2 \\/ }
  its(:content) { should match /^  main auth hmac-sha1 enc aes-128 group modp1024 \\/ }
  its(:content) { should match /^  quick auth hmac-sha1 enc aes-128 \\/ }
  its(:content) { should match /^  psk password/ }

  its(:content) { should match /^ike passive esp transport \\/ }
  its(:content) { should match /^  proto udp from \$me to any port 1701 \\/ }
  its(:content) { should match /^  main auth hmac-sha1 enc 3des group modp1024 \\/ }
  its(:content) { should match /^  quick auth hmac-sha2-256 enc aes \\/ }
  its(:content) { should match /^  psk password$/ }
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it do
      pending('serverspec does not work with netstat in OpenBSD')
      # sudo -p 'Password: ' /bin/sh -c netstat\ -nat\ -f\ inet\ \|\ egrep\ \'\(\(tcp\|udp\).\*.4500.\*LISTEN\$\)\'
      #
      # where the command returns:
      # udp          0      0  *.4500                 *.*                   
      #
      should be_listening.with('udp')
    end
  end
end
