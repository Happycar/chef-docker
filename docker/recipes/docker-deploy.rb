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

  bash "copy-code" do
        user "www-data"
        code <<-EOH
         if [ ! -f  #{deploy[:deploy_to]}/current/Dockerfile ]
         then
           sudo rm -rf #{deploy[:environment_variables][:host_code_path]}/*
           sudo cp -r #{deploy[:deploy_to]}/current/* #{deploy[:environment_variables][:host_code_path]}
         fi
        EOH
  end

  bash "docker-cleanup" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      if [ ! -f  #{deploy[:deploy_to]}/current/Dockerfile ]
      then
        echo "Code being deployed - just stop the container"
        docker stop #{deploy[:application]}
        sleep 3
        docker rm #{deploy[:application]}
        sleep 3
      else
        echo "Docker being deployed - cleanup images and rebuild"
        for i in $(find . -name 'Dockerfile' );
        do
            docker stop $(sudo docker ps -a -q)
            docker rm $(sudo docker ps -a -q)
            docker rmi $(sudo docker images -q)
            docker build -t=#{deploy[:application]} . > #{deploy[:application]}-docker.out
        done
      fi
    EOH
  end

  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      if docker images | grep #{deploy[:application]}
      then
        docker run #{dockerenvs} -p #{node[:opsworks][:instance][:private_ip]}:#{deploy[:environment_variables][:service_port]}:#{deploy[:environment_variables][:container_port]} --name #{deploy[:application]} -v '#{deploy[:environment_variables][:host_code_path]}':#{deploy[:environment_variables][:docker_mount_path]} -d #{deploy[:application]}
      fi
    EOH
  end


end