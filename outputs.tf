#outputs.tf file 
output "policy_arn" {
  value = "${aws_iam_policy.policy.0.arn}"
}
