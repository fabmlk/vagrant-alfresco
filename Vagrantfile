# automatically install needed plugins if not present
required_plugins = %w(vagrant-hostmanager)
need_restart_plugins = %w(vagrant-hostmanager)
need_restart = false
required_plugins.each do |plugin|
  if !Vagrant.has_plugin? plugin
     system "vagrant plugin install #{plugin}"
     need_restart ||= need_restart_plugins.include? plugin
  end
end

if need_restart
  puts "Missing plugins installed. Please run vagrant up again."
  exit
end

vm_name = "VALFRESCO-" + ENV['USERNAME'][0..4].upcase  # 15 chars max for NetBIOS
if_name = ENV['TMS_VAGRANT_INTERFACE']
username = ENV['USERNAME']
password = ENV['TMS_VAGRANT_SMB_PASSWORD']
gitlab_token = ENV['TMS_VAGRANT_GITLAB_TOKEN']

Vagrant.configure(2) do |config|
  config.vm.box = "generic/debian9"
  
  config.vm.hostname = vm_name
  
  config.vm.synced_folder ".", "/vagrant", type: "smb", smb_username: username, smb_password: password
  
  config.vm.network :public_network, bridge: if_name

  config.vm.provision "shell", path: "provision/provision.sh", env: {"GITLAB_PRIVATE_TOKEN" => gitlab_token}
	
  config.vm.provider :hyperv do |h|	
    h.vmname = vm_name
    h.differencing_disk = true
    h.enable_virtualization_extensions = true
    h.memory = 3072
    h.maxmemory = 3072
  end
		
  # hostmanager plugin
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  
  config.vm.provision "shell", run: "always", inline: "su -c 'sudo service alfresco start' vagrant"
end
