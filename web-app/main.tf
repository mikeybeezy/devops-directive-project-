

module "web_app_1" {
  source = "../web-app-module "

  #input  variables

  bucket_name      = ""
  domain           = ""
  app_name         = ""
  environment_name = ""
  instance_type    = ""
  create_dns_zone  = ""
  db_name          = ""
  db_pass          = ""
  db_user          = ""


}
