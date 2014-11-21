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

  bash "create-path-to-mount" do
    user "root"
    code <<-EOH
     mkdir -p #{deploy[:environment_variables][:host_code_path]}
    EOH
  end

  bash "move-code-to-mounted-folder" do
    user "root"
    code <<-EOH
     if ! -e "#{deploy[:deploy_to]}/current/" + "Dockerfile"
     then
        cp -r #{deploy[:deploy_to]}/current/* #{deploy[:environment_variables][:host_code_path]}
     fi
    EOH
  end

end


