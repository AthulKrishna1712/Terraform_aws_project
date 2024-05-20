# terraform {
#   backend "s3" {
#     bucket = "athulterraform2024"
#     key = "state/terraform.tfstate"
#     region = "ap-south-1"
#     encrypt = true
#     dynamodb_table = "terraform-lock"
#   }
# }