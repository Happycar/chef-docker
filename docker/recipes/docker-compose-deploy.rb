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

    composeEnv = deploy[:environment_variables].to_hash
    composeEnv['PRIVATE_IP'] = node[:opsworks][:instance][:private_ip]

    bash "docker-compose pull" do
      user "root"
      cwd deploy[:deploy_to] + "/current/"
      code <<-EOH
        docker-compose pull
      EOH
    end

    bash "docker-compose stop previous" do
      user "root"
      cwd deploy[:deploy_to]
      code <<-EOH
        cd $(ls | sort -r | head -2 | tail -1) && pwd && docker-compose down
      EOH
    end

    bash "docker-compose start current" do
      user "root"
      environment composeEnv
      cwd deploy[:deploy_to] + "/current/"
      code <<-EOH
        docker-compose up -d
      EOH
    end

  else
      Chef::Log.info("Cant't deploy, ENV is empty")
  end
  

end
Chef::Log.info("Exiting docker-compose-deploy")
