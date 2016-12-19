Chef::Log.info(" === :: AWS CLI - EC2 - Create Tags :: === ")

bash "awscli-ec2-create-tags" do
    user "root"
    code <<-EOH
        TAGS='#{node['awscli']['ec2-create-tags']}'
        if [ -n "$TAGS" ]; then
            JSON_TAGS=$(echo ${TAGS} | sed -e 's/=>/:/g')
            JSON_TAGS=$(echo ${JSON_TAGS} | sed -e 's/"/\\"/g')
            echo ${TAGS}
            echo ${JSON_TAGS}
            aws ec2 create-tags --region #{node['opsworks']['instance']['region']} --resources #{node['opsworks']['instance']['aws_instance_id']} --cli-input-json "$(echo ${JSON_TAGS})"
        fi
    EOH
end