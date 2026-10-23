output "instance_id" {
  description = "ID of the application EC2 instance"
  value       = aws_instance.app.id
}

output "private_ip" {
  description = "Private IP address of the application instance"
  value       = aws_instance.app.private_ip
}