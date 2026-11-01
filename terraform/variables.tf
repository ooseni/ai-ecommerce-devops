variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Name used for tags and resource names."
  type        = string
  default     = "ai-ecommerce-devops"
}

variable "instance_type" {
  description = "EC2 type for the single k3s node."
  type        = string
  default     = "t3.large"
}

variable "admin_cidr" {
  description = "The one address allowed to reach SSH and the Kubernetes API, as x.x.x.x/32."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "Set admin_cidr to your own address, such as 203.0.113.7/32. 0.0.0.0/0 is refused."
  }
}

variable "ssh_public_key_path" {
  description = "Public half of the key used to log in to the instance."
  type        = string
  default     = "~/.ssh/capstone-ec2.pub"
}

variable "budget_email" {
  description = "Where AWS Budgets sends its alerts. Empty means no budget alert."
  type        = string
  default     = ""
}

variable "monthly_budget_usd" {
  description = "Monthly limit that the budget alert watches."
  type        = number
  default     = 15
}
