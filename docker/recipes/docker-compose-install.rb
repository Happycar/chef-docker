Chef::Log.info(" === :: Docker Compose install :: === ")

Chef::Application.fatal!("docker is not installed") unless ::File.exists?("/usr/bin/docker")

bash "docker-compose-install" do
  user "root"
  code <<-EOH
    curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  EOH
end
