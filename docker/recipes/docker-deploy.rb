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


  dockerenvs = " "
  deploy[:environment_variables].each do |key, value|
    dockerenvs=dockerenvs+" -e "+key+"="+value
  end

   bash "create-path-to-mount-if-not-exist" do
      user "root"
      code <<-EOH
       mkdir -p #{deploy[:environment_variables][:host_code_path]}
      EOH
    end

  bash "docker-cleanup" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      if docker ps | grep #{deploy[:application]};
      then
        docker stop #{deploy[:application]}
        sleep 3
        docker rm #{deploy[:application]}
        sleep 3
      else
        DOCKERS = find . -name 'Dockerfile' | wc -l
        if [[ $DOCKERS -eq 0 ]]
        then
            cp -r #{deploy[:deploy_to]}/current/* #{deploy[:environment_variables][:host_code_path]}
        fi
        for i in $(find . -name 'Dockerfile' );
        do
            docker build -t=#{deploy[:application]} . > #{deploy[:application]}-docker.out
        done
      fi
    EOH
  end

  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      if docker images | grep #{deploy[:application]};
      then
        docker run #{dockerenvs} -p #{node[:opsworks][:instance][:private_ip]}:#{deploy[:environment_variables][:service_port]}:#{deploy[:environment_variables][:container_port]} --name #{deploy[:application]} -v '#{deploy[:environment_variables][:host_code_path]}':#{deploy[:environment_variables][:docker_mount_path]} -d #{deploy[:application]}
      fi
    EOH
  end


end