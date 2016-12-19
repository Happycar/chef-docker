Chef::Log.info(" === :: EC2 - Assign Tags :: === ")

bash "ec2-assign-tags-setup" do
    user "root"
    code <<-EOH
        apt-get install -y unzip
        cd ~/
        curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
        unzip awscli-bundle.zip
        rm awscli-bundle.zip
        ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
        TAGS='#{node[:ec2_tags]}'
        JSON_TAGS=$(echo ${TAGS} | sed -e 's/=>/:/g')
        JSON_TAGS=$(echo ${JSON_TAGS} | sed -e 's/"/\\"/g')
        echo ${TAGS}
        echo ${JSON_TAGS}
        aws ec2 create-tags --region #{node[:opsworks][:instance][:region]} --resources #{node[:opsworks][:instance][:aws_instance_id]} --cli-input-json "$(echo ${JSON_TAGS})"
    EOH
end