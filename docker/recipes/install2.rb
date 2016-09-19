Chef::Log.info(" === :: Docker BUILD :: === ")
bash "docker-install" do
user "root"
#cwd "#{deploy[:deploy_to]}/current"
code <<-EOH
  wget -qO- https://get.docker.com/ | sh
  export MIRROR_SOURCE=https://registry.hub.docker.com
  export MIRROR_SOURCE_INDEX=https://registry.hub.docker.com
EOH
end

service "docker" do
  action :start
end
