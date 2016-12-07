Chef::Log.info(" === :: CloudWatch - Enhanced Monitoring :: === ")

bash "cloudwatch-enhanced-monitoring-setup" do
    user "root"
    code <<-EOH
        apt-get install -y unzip libwww-perl libdatetime-perl
        cd ~/
        curl -O http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip
        unzip CloudWatchMonitoringScripts-1.2.1.zip
        rm CloudWatchMonitoringScripts-1.2.1.zip
        touch /var/log/cloudwatch-enhanced-monitoring-cron.log
    EOH
end

cron 'cloudwatch-enhanced-monitoring-cron' do
    user 'root'
    minute '*'
    command '~/aws-scripts-mon/mon-put-instance-data.pl --mem-util --swap-util --disk-path=/ --disk-space-util >> /var/log/cloudwatch-enhanced-monitoring-cron.log 2>&1'
end