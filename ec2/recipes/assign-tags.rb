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
        TAGS=$(echo ${TAGS} | sed -e 's/=>/:/g')
        TAGS=$(echo ${TAGS} | sed -e 's/"/\\"/g')
        echo ${TAGS}
        aws ec2 create-tags --region #{node[:opsworks][:instance][:region]} --resources #{node[:opsworks][:instance][:aws_instance_id]} --cli-input-json $(echo ${TAGS})
    EOH
end