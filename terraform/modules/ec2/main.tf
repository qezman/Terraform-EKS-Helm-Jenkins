resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = var.vpc_id

  # Allow SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # this would be restricted to my IP in production
  }

  # Allow access to Jenkins web UI on port 8080
  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-jenkins-sg"
    Environment = var.environment
  }
}

resource "aws_key_pair" "jenkins" {
  key_name   = "${var.project_name}-jenkins-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMiOrQRwePN6lDaPe3Q4qXEkBfCJCGl5/vi0RVmEVyyufjf/8AsgdhRPj8cevmj41Y5OMx/8JjVPz0uZ/3D/wm9vWdMa48MkvSGbhY4xp+ub/E6Q6aSawQQZol9tnA22NLGxt8Q02uELJ/DEzezLsPjy7jaZS4Y81vQg+ZCtAua2wmUR+XRvy4kJjK7m/9aBgBvKCEBK4jycchPC59wIizdB2ZK+Ex1uVthcFKQYNrqKc4Ro31zkyfgSWImkD2PPfTPOu424d42Fr6R8g9su6XgB0D9JvvXauEPqF4xJJw+4CyGHlJ94AhGmS1K8qTtEkyU6LMau970/Z3N+5WgmTZmYyX0p5XUf/kPxhmRXWIlPiG6NQmNjBNmW+ucBjpLfcFr727VLiWRo7YeY0dyqhkPifSNSqf1vWv4CCqSdQMmgsxh6WlLliSiSf+fe1zRzw3eLuR7VTybbtyMTwgvHMigpRs7so+zGvZlDCV8umlBTnTc35X9NchLAjS0c+Ww7dNmOqd8YniG1CMGSZrUzXd2qT8hARe+DKE3n/ptC56GiGkBbC3DPUkADuQpR3vQX7RNjfhUxqoM4r7EiC4JMIlzMOPoYbj+5m2PmAC7OMvFkj290VZ5T+Axk38jfHukheT84FOuUQbCH2XWlmxgcyvOktHvUn8rYEgZdbofYKE/Q== qossim_05@Qezman"

  tags = {
    Name        = "${var.project_name}-jenkins-key"
    Environment = var.environment
  }
}

# Jenkins EC2 instance
resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = aws_key_pair.jenkins.key_name

  # installs Jenkins, Java, Docker, and kubectl
  user_data = <<-EOF
    #!/bin/bash
    set -e
    exec > /var/log/user-data.log 2>&1

    # Update system
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg unzip

    # Install Java
    apt-get install -y openjdk-21-jdk

    # Add Jenkins repo with correct GPG method
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
    gpg --keyserver keyserver.ubuntu.com --recv-keys 7198F4B714ABFC68
    gpg --export 7198F4B714ABFC68 | tee /usr/share/keyrings/jenkins-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt-get update -y
    apt-get install -y jenkins

    # Create jenkins user properly
    useradd -m -d /var/lib/jenkins -s /bin/bash -g jenkins jenkins || true
    mkdir -p /var/lib/jenkins /var/cache/jenkins /var/log/jenkins
    chown -R jenkins:jenkins /var/lib/jenkins /var/cache/jenkins /var/log/jenkins

    # Start Jenkins
    systemctl daemon-reload
    systemctl start jenkins
    systemctl enable jenkins

    # Install Docker
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker jenkins

    # Install Node.js 20 (system-wide)
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs

    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install

    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  EOF

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name        = "${var.project_name}-jenkins"
    Environment = var.environment
  }
}
