data "aws_region" "current" {}
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

resource "aws_lex_intent" "commerce-inbound-order" {
  create_version = true
  name           = "connect_commerce_lex_intent"
  fulfillment_activity {
    type = "ReturnIntent"
  }
  sample_utterances = [
    "I would like to order flowers",
    "I would like to order candies",
  ]
}


resource "aws_lex_bot" "commerce-inbound-order" {
  abort_statement {
    message {
      content      = "Sorry, I am not able to assist at this time"
      content_type = "PlainText"
    }
  }
  clarification_prompt {
    max_attempts = 2
    message {
      content      = "I didn't understand you, what would you like to do?"
      content_type = "PlainText"
    }
  }
  intent {
    intent_name    = aws_lex_intent.commerce-inbound-order.name
    intent_version = "1"
  }

  child_directed   = false
  name             = "connect_commerce_lex_bot"
  process_behavior = "BUILD"
}

resource "aws_connect_bot_association" "commerce-inbound-order" {
  instance_id = aws_connect_instance.commerce.id
  lex_bot {
    lex_region = data.aws_region.current.name
    name       = aws_lex_bot.commerce-inbound-order.name

  }
}
