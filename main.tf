resource "aws_connect_instance" "commerce" {
  identity_management_type         = "CONNECT_MANAGED"
  instance_alias                   = "commerce-connect"
  inbound_calls_enabled            = true
  outbound_calls_enabled           = true
  contact_flow_logs_enabled        = true
}