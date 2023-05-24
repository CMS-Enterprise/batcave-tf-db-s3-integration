data "aws_iam_policy_document" "this" {
  count = var.create_role ? 1 : 0

  dynamic "statement" {
    for_each = var.oidc_providers

    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "Service"
        identifiers = ["rds.amazonaws.com"]
      }

      condition {
        test     = var.assume_role_condition_test
        variable = "aws:SourceAccount"
        values   = [var.aws_id]
      }
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name        = var.role_name
  path        = var.role_path
  description = var.role_description

  assume_role_policy    = data.aws_iam_policy_document.this[0].json
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.role_permissions_boundary_arn
  force_detach_policies = var.force_detach_policies

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in var.role_policy_arns : k => v if var.create_role }

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
