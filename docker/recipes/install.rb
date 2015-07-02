Chef::Log.info(" === :: Docker BUILD :: === ")
bash "docker-install" do
user "root"
#cwd "#{deploy[:deploy_to]}/current"
code <<-EOH
  wget -qO- https://get.docker.com/ | sh
EOH
end

service "docker" do
  action :start
end