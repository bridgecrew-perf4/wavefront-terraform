provider "wavefront" {
  address = "try.wavefront.com" // your wavefront endpoint
  token = "buwic36-t22biwn-92082-jscsnw-928291" // your wavefront access token
}

resource "wavefront_dashboard" "aws_dashboard" {
  name = "AWS Dashboard"
  description = "AWS dashboard for Wavefront"
  url = "demo-dashboard"

  section{
    name = "EC2 Metrics"
    row {
      chart {
        name = "CPU Utilization"
        units = "%"
        source {
          name = "CPU Utilization"
          query = "ts(aws.ec2.cpu.utilization, environment=prod)"
        }
        chart_setting {
          type = "line"
        }
        summarization = "MEAN"
      }
      chart {
        name = "Memory Utilization"
        units = "%"
        source {
          name = "Memory Utilization"
          query = "ts(aws.ec2.memory.utilization, environment=prod)"
        }
        chart_setting {
          type = "line"
        }
        summarization = "MEAN"
      }
    }
  }
}

resource "wavefront_alert_target" "ec2_alert_target" {
  name = "EC2 Alert Target"
  method = "EMAIL"
  recipient = "test@example.com"
  email_subject = "EC2 threshold has been breached"
  is_html_content = true
  template = "{}"
  triggers = [
    "ALERT_OPENED",
    "ALERT_RESOLVED"
  ]
}

resource "wavefront_alert" "cpu_utilization_alert" {
  name = "CPU Utilization Alert"
  alert_type = "THRESHOLD"
  minutes = 5
  resolve_after_minutes = 5
  display_expression = "ts(aws.ec2.cpu.utilization, environment=prod)"

  conditions = {
    "severe" = "ts(aws.ec2.cpu.utilization, environment=prod) > 80"
    "warn" = "ts(aws.ec2.cpu.utilization, environment=prod) > 60"
  }

  threshold_targets = {
    "severe" = "target:${wavefront_alert_target.ec2_alert_target.id}"
    "warn" = "target:${wavefront_alert_target.ec2_alert_target.id}"
  }
}