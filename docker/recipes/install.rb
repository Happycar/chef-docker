Chef::Log.info(" === :: Docker Inslall :: === ")
log = "/tmp/docker-install.log"

file log do
	action :delete
end

bash "docker-install" do
  user "root"
  code <<-EOH
    wget -qO- https://get.docker.com/ | sh
    export MIRROR_SOURCE=https://registry.hub.docker.com
    export MIRROR_SOURCE_INDEX=https://registry.hub.docker.com
  EOH
end

ruby_block "Results" do
    only_if { ::File.exists?(log) }
    block do
        print "\n"
        print "docker install log"
        print File.open(results)
    end
end

Chef::Application.fatal!("Docker is not installed") unless ::File.exists?("/usr/bin/docker")

service "docker" do
  action :start
end