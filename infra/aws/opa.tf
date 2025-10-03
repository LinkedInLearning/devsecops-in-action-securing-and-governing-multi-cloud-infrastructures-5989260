resource "aws_instance" "opa_aws" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t3.micro"

  tags = {
    Name        = "HelloWorld"
    Environment = "Sandbox"
    Project     = "Red30Tech"
  }
}
