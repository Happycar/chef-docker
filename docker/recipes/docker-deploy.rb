include_recipe 'deploy'

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

  bash "docker-cleanup" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      if docker ps | grep #{deploy[:application]}; 
      then
        docker stop #{deploy[:application]}
        sleep 3
      else
        if find #{deploy[:deploy_to]}/current -name 'Dockerfile'
            docker build -t=#{deploy[:application]} . > #{deploy[:application]}-docker.out
        fi
      fi
    EOH
  end

  dockerenvs = " "
  deploy[:environment_variables].each do |key, value|
    dockerenvs=dockerenvs+" -e "+key+"="+value
  end

  bash "create-path-to-mount" do
      user "root"
      code <<-EOH
       mkdir -p #{deploy[:environment_variables][:host_code_path]}
      EOH
    end

    bash "clear-mounted-path" do
        user "root"
        cwd "#{deploy[:environment_variables][:host_code_path]}"
        code <<-EOH
         rm -rf *
        EOH
      end

  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      docker run #{dockerenvs} -p #{node[:opsworks][:instance][:private_ip]}:#{deploy[:environment_variables][:service_port]}:#{deploy[:environment_variables][:container_port]} --name #{deploy[:application]} -v #{deploy[:environment_variables][:host_code_path]}:#{deploy[:environment_variables][:docker_mount_path]} -d #{deploy[:application]}
    EOH
  end


end