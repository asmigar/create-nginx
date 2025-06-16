data "aws_iam_policy_document" "github_action" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GithubAction",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/wtf"]
      type = "AWS"
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      identifiers = [aws_iam_openid_connect_provider.github.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.organisation}/*:*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}


resource "aws_iam_role" "github_action" {
  name                = "GithubAction"
  assume_role_policy  = data.aws_iam_policy_document.github_action.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}

