include_recipe 'deploy'

Chef::Log.info("Entering docker-image-deploy")

node[:deploy].each do |application, deploy|

  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.warn("Skipping deploy::docker application #{application} as it is not deployed to this layer")
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

  Chef::Log.info('Docker cleanup')
  bash "docker-cleanup" do
    user "root"
    returns [0, 1]
    code <<-EOH
      if docker ps | grep #{deploy[:application]};
      then
        docker stop #{deploy[:application]}
        sleep 3
        docker rm -f #{deploy[:application]}
      fi
      if docker ps -a | grep #{deploy[:application]};
      then
        docker rm -f #{deploy[:application]}
      fi
      if docker images | grep #{deploy[:environment_variables][:registry_image]};
      then
        docker rmi -f $(docker images | grep -m 1 #{deploy[:environment_variables][:registry_image]} | awk {'print $3'})
      fi
    EOH
  end

  Chef::Log.info('docker-login start')
  # Chef::Log.info("REGISTRY: Login as #{deploy[:environment_variables][:registry_username]} to #{deploy[:environment_variables][:registry_url]}")
  bash "docker-login" do
    user "root"
    code <<-EOH
      docker login -u #{deploy[:environment_variables][:registry_username]} -p #{deploy[:environment_variables][:registry_password]} -e #{deploy[:environment_variables][:registry_email]}
    EOH
  end
  Chef::Log.info('docker-login stop')

  Chef::Log.info('docker-pull start')
  bash "docker-pull" do
    user "root"
    code <<-EOH
      docker pull #{deploy[:environment_variables][:registry_image]}:#{deploy[:environment_variables][:registry_tag]}
    EOH
  end
  Chef::Log.info('docker-pull stop')

  dockerenvs = " "
  deploy[:environment_variables].each do |key, value|
    dockerenvs=dockerenvs+" -e "+key+"="+value unless key == "registry_password"
  end
  Chef::Log.info("ENVs: #{dockerenvs}")

  Chef::Log.info('docker-run start')
  bash "docker-run" do
    user "root"
    code <<-EOH
      docker run #{dockerenvs} -e DOCKER_HOST_IP=#{node[:opsworks][:instance][:private_ip]} -e DOCKER_HOST_NAME=#{node[:opsworks][:instance][:hostname]} -p #{node[:opsworks][:instance][:private_ip]}:#{deploy[:environment_variables][:service_port]}:#{deploy[:environment_variables][:container_port]} --name #{deploy[:application]} -d #{deploy[:environment_variables][:registry_image]}:#{deploy[:environment_variables][:registry_tag]}
    EOH
  end
  Chef::Log.info('docker-run stop')
end
Chef::Log.info("Exiting docker-image-deploy")
