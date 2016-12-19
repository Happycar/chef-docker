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
        aws ec2 create-tags --region eu-central-1 --resources #{node[:ec2][:instance_id]} --cli-input-json '{"Tags":#{node[:ec2_tags]}}'
    EOH
end