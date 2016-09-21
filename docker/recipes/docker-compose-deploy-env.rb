include_recipe 'deploy'

Chef::Log.info("Entering docker-compose-deploy-env")

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
  
  deployEnv = deploy[:environment_variables].to_hash
  nodeEnv = node[:environment_variables].to_hash
  
  composeEnv = deployEnv.merge(nodeEnv)
  
  imageVersion = "latest"
  
  unless node[:IMAGE_VERSION].nil?
    imageVersion = node[:IMAGE_VERSION]
  end
  
  composeEnv["IMAGE_VERSION"]   = imageVersion
  composeEnv["HOST_PRIVATE_IP"] = node[:opsworks][:instance][:private_ip]
  composeEnv["HOST_NAME"]       = node[:opsworks][:instance][:hostname]
  
  Chef::Log.info('IMAGE_VERSION set to ' + imageVersion)
  
  bash "docker-compose pull" do
    environment composeEnv
    user "root"
    cwd deploy[:deploy_to] + "/current/"
    code <<-EOH
      docker-compose pull
    EOH
  end
  
  bash "docker-compose stop previous" do
    user "root"
    code <<-EOH
      docker stop $(docker ps -a -q) || true
      docker rm $(docker ps -a -q) || true
    EOH
  end
  
  bash "docker-compose run" do
    environment composeEnv
    user "root"
    cwd deploy[:deploy_to] + "/current/"
    code <<-EOH
      docker-compose up -d --remove-orphans 
    EOH
  end
  
  # removes all unused images 
  # exited containers 
  # unused volumes 
  bash "docker cleanup" do
    user "root"
    code <<-EOH
      docker ps -q -f status=exited | xargs --no-run-if-empty docker rm
      docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi
      docker volume ls -q -f dangling=true | xargs --no-run-if-empty docker volume rm
    EOH
  end
end

Chef::Log.info("Exiting docker-compose-deploy")
