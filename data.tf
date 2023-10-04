
data "aws_availability_zones" "available" {
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "region-name"
    values = [var.aws_region]
  }

}
