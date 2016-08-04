include_recipe 'deploy'

Chef::Log.info("Entering docker-compose-deploy")

node[:deploy].each do |application, deploy|

  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.debug("Skipping deploy::docker application #{application} as it is not deployed to this layer")
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

  unless deploy[:environment_variables].nil? 
    if ::File.exists?(deploy[:deploy_to] + "/current/docker-compose.yml")
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
        cwd deploy[:deploy_to] + "/releases/"
        code <<-EOH
          cd $(ls | sort -r | head -2 | tail -1) && docker-compose down
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

    else
      Chef::Log.info("Cant't deploy, docker-compose file does not exists")
    end
  else
      Chef::Log.info("Cant't deploy, ENV is empty or docker-compose file does not exists")
  end

end
Chef::Log.info("Exiting docker-compose-deploy")
