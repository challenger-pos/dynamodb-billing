terraform {
  backend "s3" {
    bucket         = "tf-state-challenge-bucket"
    key            = "v4/dynamodb-billing/homologation/terraform.tfstate"
    region         = "us-east-2"
  }
}
