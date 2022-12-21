#outputs.tf file 
output "policy_arn" {
  value = "${aws_iam_policy.policy.arn}"
}
