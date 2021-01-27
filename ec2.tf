resource "aws_instance" "myec2" {
    ami                 = "ami-0e80a462ede03e653"
    instance_type       = "t2.micro"
}