require_relative '../inecas_helpers'

katello_ip = '192.168.121.11'

InecasHelpers.define_vm('mco-katello', plugin: 'mcollective', base: 'centos6', setup: true) do |machine|
  machine.vm.network "public_network", ip: katello_ip
  machine.vm.provision "shell", path: "plugins/mcollective/setup_katello_puppet_mcollective.sh"
end

InecasHelpers.define_vm('mco-client', plugin: 'mcollective', base: 'centos6', setup: false) do |machine|
  machine.vm.provision "shell" do |s|
    s.args = [katello_ip]
    s.path = "plugins/mcollective/setup_client_puppet.sh"
  end

  machine.vm.provider :libvirt do |provider|
    provider.provider.memory = 1024
  end
end
