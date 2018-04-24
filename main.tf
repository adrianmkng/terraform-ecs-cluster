resource "aws_ecs_cluster" "main" {
  name = "${terraform.workspace}"
}

resource "aws_launch_configuration" "ecs" {
  name_prefix   = "${terraform.workspace}-"
  image_id      = "ami-efda148d"
  instance_type = "t2.micro"
  user_data     = "${base64encode("${data.template_file.user_data.rendered}")}"
  associate_public_ip_address = "true"
  security_groups = ["${aws_security_group.ecs_sg.id}"]
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "${aws_launch_configuration.ecs.name}"
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  tags = ["${concat(
    list(
      map("key", "system", "value", "ecs", "propagate_at_launch", true),
      map("key", "environment", "value", "${terraform.workspace}", "propagate_at_launch", true)
    )
  )}"]

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"
  vars {
    environment = "${terraform.workspace}"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Security group for ECS instances"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "ingress_allow_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.ecs_sg.id}"
}

resource "aws_security_group_rule" "egress_allow_all" {
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.ecs_sg.id}"
}
