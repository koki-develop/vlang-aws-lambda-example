resource "aws_lambda_function" "main" {
  function_name = local.name
  role          = aws_iam_role.main.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.main.repository_url}:latest"
}
