terraform {
  backend "s3" {
    bucket = "tfstate-nktest-9809"
    key = "backend/two-tier-terraform-project/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "remote-backend"

  }
}

