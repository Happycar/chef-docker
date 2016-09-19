Chef::Log.level = :debug

Chef::Log.info(" === :: Docker Install :: === ")

bash "docker-install" do
    user "root"
    not_if { File.exists?("/usr/bin/docker") }
    code <<-EOH
      wget -qO- https://get.docker.com/ | sh
      export MIRROR_SOURCE=https://registry.hub.docker.com
      export MIRROR_SOURCE_INDEX=https://registry.hub.docker.com
    EOH
end

Chef::Application.fatal!("Docker is not installed") unless File.exists?("/usr/bin/docker")

service "docker" do
  action :start
end
