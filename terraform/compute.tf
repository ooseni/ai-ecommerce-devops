data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "admin" {
  key_name   = "${var.project}-admin"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "aws_instance" "node" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.node.id]
  key_name                    = aws_key_pair.admin.key_name
  associate_public_ip_address = true

  # IMDSv2 only, which blocks the classic metadata theft through a web request.
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = {
    Name = "${var.project}-k3s"
  }
}

# A fixed address, so the kubeconfig and the Ansible inventory survive a stop and start.
resource "aws_eip" "node" {
  instance = aws_instance.node.id
  domain   = "vpc"

  tags = {
    Name = var.project
  }

  depends_on = [aws_internet_gateway.main]
}
