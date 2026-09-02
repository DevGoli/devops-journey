terraform {
  backend "s3" {
    bucket       = "netflix-s3-backendtf-english"
    key          = "mc/terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}