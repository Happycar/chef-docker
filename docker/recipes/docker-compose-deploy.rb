include_recipe 'deploy'

Chef::Log.info("Entering docker-compose-deploy")

node[:deploy].each do |application, deploy|

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  unless deploy[:environment_variables].nil? 
    Chef::Log.info('docker-login start')
    bash "docker-login" do
      user "root"
      code <<-EOH
        docker login -u #{deploy[:environment_variables][:DOCKER_HUB_USER]} -p #{deploy[:environment_variables][:DOCKER_HUB_PASSWORD]}
      EOH
    end
    Chef::Log.info('docker-login stop')

    Chef::Log.info('docker-compose-run start')
    bash "docker-compose-run" do
      user "root"
      code <<-EOH
        export PRIVATE_IP=#{node[:opsworks][:instance][:private_ip]}
        docker-compose -f #{deploy[:deploy_to]}/current/docker-compose.yml pull
        docker-compose -f #{deploy[:deploy_to]}/current/docker-compose.yml down
        docker-compose -f #{deploy[:deploy_to]}/current/docker-compose.yml up -d
      EOH
    end
  end
  

end
Chef::Log.info("Exiting docker-compose-deploy")
