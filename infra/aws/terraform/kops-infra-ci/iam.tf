/*
Copyright 2023 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

/* This file contains:
- IAM role for prow.k8s.io control plane to assume specific permissions
*/

data "aws_iam_policy_document" "google_prow_trust_policy" {
  provider = aws.kops-infra-ci

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.google_prow_idp.arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "container.googleapis.com/v1/projects/k8s-prow/locations/us-central1-f/clusters/prow:sub"
      values = [
        "system:serviceaccount:default:config-bootstrapper",
        "system:serviceaccount:default:crier",
        "system:serviceaccount:default:sinker",
        "system:serviceaccount:default:prow-controller-manager",
      ]
    }
  }
}


// Ensure service accounts for the prow control plan can assume this role
resource "aws_iam_role" "google_prow_trust_role" {
  provider = aws.kops-infra-ci

  name                 = "GoogleProwTrustRole"
  description          = ""
  max_session_duration = 43200
  assume_role_policy   = data.aws_iam_policy_document.google_prow_trust_policy.json
}
