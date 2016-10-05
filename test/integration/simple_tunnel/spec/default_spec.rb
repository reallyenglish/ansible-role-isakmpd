require 'spec_helper'

class ServiceNotReady < StandardError
end

sleep ENV['JENKINS_HOME'] ? 20 : 15

context 'after provisioning finished' do

  [ server(:gw1), server(:gw2) ].each do |s|
    describe s do
      let(:src) { s.name == server(:gw1).name ? server(:gw1).server.address : server(:gw2).server.address }
      let(:dst) { s.name == server(:gw1).name ? server(:gw2).server.address : server(:gw1).server.address }

      it 'shows the IPSec flows' do
        result = current_server.ssh_exec('sudo ipsecctl -s flow')
        # FLOWS:
        # flow esp  in from 192.168.52.102 to 192.168.52.101 peer 192.168.52.102 srcid 192.168.52.101/32 dstid 192.168.52.102/32 type use
        # flow esp out from 192.168.52.101 to 192.168.52.102 peer 192.168.52.102 srcid 192.168.52.101/32 dstid 192.168.52.102/32 type require
        expect(result).to match /^flow esp in from #{dst} to #{src} peer #{dst} srcid #{src}\/32 dstid #{dst}\/32 type use/
        expect(result).to match /^flow esp out from #{src} to #{dst} peer #{dst} srcid #{src}\/32 dstid #{dst}\/32 type require/
      end

      it 'shows the IPSec SA' do
        result = current_server.ssh_exec('sudo ipsecctl -s sa')
        # SAD:
        # esp tunnel from 192.168.52.102 to 192.168.52.101 spi 0x264b4573 auth hmac-sha1 enc aes
        # esp tunnel from 192.168.52.101 to 192.168.52.102 spi 0x98f12547 auth hmac-sha1 enc aes
        expect(result).to match /^esp tunnel from #{dst} to #{src} spi 0x[0-9a-z]+ auth hmac-sha1 enc aes/
        expect(result).to match /^esp tunnel from #{src} to #{dst} spi 0x[0-9a-z]+ auth hmac-sha1 enc aes/
        # there is a race when both hosts create flows, resulting 4 SAs
        expect(result.split("\n").length).to satisfy { |v| v == 2 or v == 4 }
      end
    end
  end

end
