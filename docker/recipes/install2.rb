Chef::Log.info(" === :: Docker Install :: === ")
log = "/tmp/docker-install.log"
aufs-installed = "/tmp/aufs-installed"

file log do
	action :delete
end

# fixes the "module aufs not found" error that prevents docker install on some kernels
bash "aufs-install do"
not_if { ::File.exists?(aufs-installed) }
  user "root"
  apt-get install lxc wget bsdtar curl
  apt-get install linux-image-extra-$(uname -r)
  modprobe aufs
  touch #{aufs-installed}
end

bash "docker-install" do
  user "root"
  not_if { ::File.exists?("/usr/bin/docker") }
  code <<-EOH
    wget -qO- https://get.docker.com/ | sh > #{log} 2>&1
    export MIRROR_SOURCE=https://registry.hub.docker.com
    export MIRROR_SOURCE_INDEX=https://registry.hub.docker.com
  EOH
end

ruby_block "print-log" do
    only_if { ::File.exists?(log) }
    block do
        print "\n"
        print "docker install log"
        print File.open(log)
    end
end

Chef::Application.fatal!("Docker is not installed") unless ::File.exists?("/usr/bin/docker")

service "docker" do
  action :start
end
