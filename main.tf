resource "aws_connect_instance" "commerce" {
  identity_management_type         = "CONNECT_MANAGED"
  instance_alias                   = "commerce-connect"
  inbound_calls_enabled            = true
  outbound_calls_enabled           = true
  auto_resolve_best_voices_enabled = false
  contact_flow_logs_enabled        = true
}

resource "aws_connect_contact_flow" "commerce-inbound-default" {
  instance_id  = aws_connect_instance.commerce.id
  name         = "Commerce Inbound Flow"
  description  = "Default inbound call flow"
  type         = "CONTACT_FLOW"

   content     = <<JSON
       {
       "Version": "2019-10-30",
       "StartAction": "ACTION001",
       "Actions": [ 
         {
           "Identifier": "ACTION001",
           "Type": "MessageParticipant",
           "Transitions": {
             "NextAction": "ACTION900",
             "Errors": [],
             "Conditions": []
           },
           "Parameters": {
             "Text": "Welcome to Commerce Company."
           }
         },
         {
           "Identifier": "ACTION900",
           "Type": "DisconnectParticipant",
           "Transitions": {},
           "Parameters": {}
         }
       ]
     }
     JSON

  tags = {
    "Name"   = "Commerce Inbound Flow"
  }
}