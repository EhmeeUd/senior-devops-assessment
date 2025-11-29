terraform {
  backend "s3" {
    bucket         = "spinbet-assessment-bucket"
    key            = "task2/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}