output "backend_public_ip" {
  description = "Public IP address of the Backend machine"
  value       = aws_instance.backend.public_ip
}

output "frontend_public_ip" {
  description = "Public IP address of the Frontend machine"
  value       = aws_instance.frontend.public_ip
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS database"
  value       = aws_db_instance.default.endpoint
}