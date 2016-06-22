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

  Chef::Log.info('Docker compose pull start')
  bash "docker-compose pull" do
    user "root"
    code <<-EOH
      docker-compose pull
    EOH
  end

  Chef::Log.info('docker-compose-run start')
  bash "docker-run" do
    user "root"
    code <<-EOH
      export PRIVATE_IP=#{node[:opsworks][:instance][:private_ip]}
      docker-compose down
      docker-compose up -d
    EOH
  end

end
Chef::Log.info("Exiting docker-compose-deploy")
