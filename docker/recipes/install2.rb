Chef::Log.info(" === :: Docker Install :: === ")

package "docker.io" do
  action :install
end

Chef::Application.fatal!("Docker is not installed") unless File.exists?("/usr/bin/docker")

service "docker" do
  action :start
end
