Chef::Log.info(" === :: Docker Install :: === ")

bash "docker-install" do
  user "root"
  code <<-EOH
    wget -qO- https://get.docker.com/ | sh
    export MIRROR_SOURCE=https://registry.hub.docker.com
    export MIRROR_SOURCE_INDEX=https://registry.hub.docker.com
  EOH
end

service "docker" do
  action :start
end
