Chef::Log.info(" === :: EC2 - Assign Tags :: === ")

include_recipe "aws"

unless node['ec2_tags'].empty? || node['ec2_tags'].nil?
    aws_resource_tag node['ec2']['instance_id'] do
        tags(node['ec2_tags'])
        action :update
    end
end