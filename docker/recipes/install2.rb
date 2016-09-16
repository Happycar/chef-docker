Chef::Log.info(" === :: Docker Install :: === ")

log = "/tmp/docker-install.log"
aufs = "/tmp/aufs-installed"
docker = "/usr/bin/docker"

file log do
  action :delete
end

Chef::Log.info("Install aufs ...")

# fixes the "module aufs not found" error that prevents docker install on some kernels
bash "aufs-install" do
  user "root"	
  not_if { File.exists?("/tmp/aufs-installed") }
  code <<-EOH
    apt-get install lxc wget bsdtar curl -y
    apt-get install linux-image-extra-$(uname -r) -y
    modprobe aufs
    touch "/tmp/aufs-installed"
  EOH
end

Chef::Log.info("Install Docker ...")

bash "docker-install" do
  user "root"
  not_if { File.exists?(docker) }
  code <<-EOH
    wget -qO- https://get.docker.com/ | sh > #{log} 2>&1
    export MIRROR_SOURCE=https://registry.hub.docker.com
    export MIRROR_SOURCE_INDEX=https://registry.hub.docker.com
  EOH
end

ruby_block "print-log" do
    only_if { File.exists?(log) }
    block do
        print "\n"
        print "docker install log"
        print File.open(log)
    end
end

Chef::Application.fatal!("Docker is not installed") unless File.exists?(docker)

service "docker" do
  action :start
end
