require 'spec_helper'
require 'serverspec'

package = 'isakmpd'
service = 'isakmpd'
config  = '/etc/ipsec.conf'
user    = '_isakmpd'
group   = '_isakmpd'
ports   = [ 500, 4500 ]

describe file('/etc/rc.conf.local') do
  it { should be_file }
  its(:content) { should match /isakmpd_flags=-K/ }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match /^ike esp from \$me to \$gw2_dcjp02 peer \$gw2_dcjp02 \\/ }
  its(:content) { should match /^  main auth hmac-sha1 enc aes-128 \\/ }
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
    it { should be_listening.with('udp') }
  end
end
