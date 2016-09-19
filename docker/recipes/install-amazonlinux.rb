Chef::Log.level = :debug

Chef::Log.info(" === :: Docker & Compose Install :: === ")

bash "docker-compose-install" do
    user "ec2-user"
    code <<-EOH
      sudo yum install -y docker
      sudo usermod -a -G docker ec2-user
      sudo curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose
      sudo chmod +x /usr/bin/docker-compose
    EOH
end

service "docker" do
  action :start
end
