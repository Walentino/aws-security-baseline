module "scps" {
  # OLD (wrong):
  # source = "../../../infra/modules/scps-baseline"

  # NEW (correct):
  source = "../../infra/modules/scps-baseline"

  allowed_regions    = var.allowed_regions
  attach_to_root     = var.attach_to_root
  root_id            = var.root_id
  policy_name_prefix = var.policy_name_prefix
}

