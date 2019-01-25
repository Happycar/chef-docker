Chef::Log.info('docker remove unused images')
bash "docker-cleanup" do
  user "root"
  code <<-EOH
    docker images | awk 'NR>1 {img=$1":"$2; print img}' > images.txt
    docker ps | awk 'NR>1 {print $2}' | grep -F -vf - images.txt > ./obsolate-images.txt
    awk '{system("docker rmi "$1)}' ./obsolate-images.txt
  EOH
end
