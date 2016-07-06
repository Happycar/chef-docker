Chef::Log.info('docker-login start')
bash "docker-login" do
  user "root"
  code <<-EOH
    docker login -u #{node[:docker_registry][:user]} -p #{node[:docker_registry][:password]}
  EOH
end