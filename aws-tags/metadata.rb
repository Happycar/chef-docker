name             "aws-tags"

maintainer       "Maik Schmidt"
maintainer_email "maik.schmidt@happycar.de"
license          "Apache"
description      "Assign tags on EC2 instances when using OpsWorks"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.0"

depends 'aws', '= 2.9.3'

provides 'aws-tags::ec2'