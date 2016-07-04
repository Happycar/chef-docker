unless  node[:docker_registry].nil? do

  registry = node[:docker_registry][:type]
  accessToken = Chef::JSONCompat.to_json(node[:docker_registry][:auth_data])

  unless File.readlines("/etc/ecs/ecs.config").grep(/ECS_ENGINE_AUTH_TYPE/).size > 0

    bash 'ecs add docker registry auth' do
      user "root" 
      code <<-EOH
        echo "ECS_ENGINE_AUTH_TYPE=#{registry}" >> /etc/ecs/ecs.config
        echo "ECS_ENGINE_AUTH_DATA=#{accessToken}" >> /etc/ecs/ecs.config
      EOH
    end

  else

    bash 'update ecs docker auth' do
      user "root"
      code <<-EOH
        sed -i -e 's/ECS_ENGINE_AUTH_TYPE=.*/ECS_ENGINE_AUTH_TYPE=#{registry}/' /etc/ecs/ecs.config
        sed -i -e 's/ECS_ENGINE_AUTH_TYPE=.*/ECS_ENGINE_AUTH_TYPE=#{accessToken}/' /etc/ecs/ecs.config
      EOH
    end

  end

else

  Chef::Log.info('No docker registry credentials were provided. Skipping')

end