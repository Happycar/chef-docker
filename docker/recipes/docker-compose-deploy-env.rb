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
  
  deployVersion = "latest"
  
  unless node[:DEPLOY_VERSION].nil?
    deployVersion = node[:DEPLOY_VERSION]
  end
  
  composeEnv["DEPLOY_VERSION"] = deployVersion
  
  Chef::Log.info('DEPLOY_VERSION set to ' + deployVersion)
  
  Chef::Log.info('docker-compose-run start')
  bash "docker-run" do
    environment composeEnv
    user "root"
    code <<-EOH
      docker-compose -f #{deploy[:deploy_to]}/current/docker-compose.yml down
      docker-compose -f #{deploy[:deploy_to]}/current/docker-compose.yml up -d --remove-orphans 
    EOH
  end

end
Chef::Log.info("Exiting docker-compose-deploy")
