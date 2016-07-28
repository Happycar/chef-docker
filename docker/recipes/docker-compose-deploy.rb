include_recipe 'deploy'

Chef::Log.info("Entering docker-compose-deploy")

node[:deploy].each do |application, deploy|
  
  Chef::Log.info("Attempting do deploy application #{application}")
  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.info("Skipping deployment of application #{application} because the apps layer environment does not match")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  Chef::Log.info('docker-login start')
  bash "docker-login" do
    user "root"
    code <<-EOH
      docker login -u #{deploy[:environment_variables][:DOCKER_HUB_USER]} -p #{deploy[:environment_variables][:DOCKER_HUB_PASSWORD]}
    EOH
  end
  Chef::Log.info('docker-login stop')
  
  dockerenvs = ""
  node[:environment_variables].each do |key, value|
    Chef::Log.info('added node env key:' + key)
    dockerenvs=dockerenvs+key+"="+value+"\n"
  end
  deploy[:environment_variables].each do |key, value|
    Chef::Log.info('added deploy env key:' + key)
    dockerenvs=dockerenvs+key+"="+value+"\n"
  end
  
  env_file="#{deploy[:deploy_to]}/current/.env"

  Chef::Log.info('docker-compose-run start')
  bash "docker-run" do
    user "root"
    code <<-EOH
      touch #{env_file}
      chmod 700 #{env_file}
      echo "#{dockerenvs}" >> #{env_file}
      echo "PRIVATE_IP=#{node[:opsworks][:instance][:private_ip]}" >> #{env_file}
      
      docker-compose -f #{deploy[:deploy_to]}/current/docker-compose.yml down
      docker-compose -f #{deploy[:deploy_to]}/current/docker-compose.yml up -d --remove-orphans 
      docker rmi $(sudo docker images -f "dangling=true" -q)
    EOH
  end

end
Chef::Log.info("Exiting docker-compose-deploy")
