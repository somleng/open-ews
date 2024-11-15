module "rds_cluster" {
  source = "../modules/rds_cluster"

  identifier = "scfmv2"
  region     = local.region
}
