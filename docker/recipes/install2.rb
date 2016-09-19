Chef::Log.level = :debug

Chef::Log.info(" === :: Docker Install :: === ")

logfile = "/tmp/docker-install.log"
file logfile do
    action :delete
end

bash "Install Docker" do
  user "root"
  not_if { ::File.exists?("/usr/bin/docker") }
  code <<-EOH
    apt-get update >> #{logfile}
    apt-get install apt-transport-https ca-certificates -y >> #{logfile}
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D >> #{logfile}
    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" >> "/etc/apt/sources.list.d/docker.list" >> #{logfile}
    apt-get update >> #{logfile}
    apt-get purge lxc-docker -y >> #{logfile}
    apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual docker-engine -y >> #{logfile}
  EOH
end

ruby_block "Print Logs" do
    only_if { ::File.exists?(logfile) }
    block do
        print "\n"
        File.open(logfile).each do |line|
            print line
        end
    end
end

Chef::Application.fatal!("Docker is not installed") unless ::File.exists?("/usr/bin/docker")

service "docker" do
  action :start
end
