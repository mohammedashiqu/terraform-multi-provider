module "ashiq" {
  source = "../multi-provider"
  providers = {
    aws = aws.a
  }
}
module "kiran" {
  source = "../multi-provider"
  providers = {
    aws = aws.k
  }
}