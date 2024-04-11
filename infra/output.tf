output "ssh_command_master_node" {
  value       =  "ssh -i ~/.ssh/${aws_key_pair.this.key_name}.pem ec2-user@${aws_instance.nginx.public_dns} ${aws_instance.backend.private_ip}"
  description = "ssh command for connecting to the nginx node"
}

output "ssh_command_private_instance" {
  value       = <<-SSHCOMMAND
  ssh-add -K ~/.ssh/${aws_key_pair.this.key_name}.pem
  ssh -A ec2-user@${aws_instance.nginx.public_dns}
  #from ${aws_instance.nginx.public_dns} host
  ssh ec2-user@${aws_instance.backend.private_ip}
  SSHCOMMAND
  description = "ssh command for connecting to the backend instance"
}

output "access_nginx_here" {
  value       =  "http://${aws_instance.nginx.public_dns}"
  description = "url to access nginx"
}


