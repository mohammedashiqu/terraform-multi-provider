provider "aws" {
  version = "~>3.0"
  region = "us-east-2"
  profile = "admin"
  alias = "a"
}
provider "aws" {
  version = "~>3.0"
  region = "us-east-1"
  profile = "kiran"
  alias = "k"
}
