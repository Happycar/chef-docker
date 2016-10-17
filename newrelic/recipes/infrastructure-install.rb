Chef::Log.info(" === :: New Relic - Infrastructure - Install :: === ")

bash "newrelic-infrastructure-install" do
  user "root"
  code <<-EOH
    echo "license_key: #{node[:newrelic][:infrastructure][:license_key]}" | sudo tee -a /etc/newrelic-infra.yml
    curl -s https://75aae388e7629eec895d26b0943bbfd06288356953c5777d:@packagecloud.io/install/repositories/newrelic/infra-beta/script.deb.sh | sudo bash
    apt-get install newrelic-infra -y
  EOH
end