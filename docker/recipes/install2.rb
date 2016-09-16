Chef::Log.info(" === :: Docker Install :: === ")

sourceList = "/etc/apt/sources.list.d/docker.list"

bash "docker-install" do
  user "root"
  not_if { ::File.exists?("/usr/bin/docker") }
  code <<-EOH
    apt-get update
    apt-get install apt-transport-https ca-certificates -y
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" >> #{/etc/apt/sources.list.d/docker.list}
    apt-get update
    apt-get purge lxc-docker -y
    apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual docker-engine -y
  EOH
end

Chef::Application.fatal!("Docker is not installed") unless ::File.exists?("/usr/bin/docker")

service "docker" do
  action :start
end
