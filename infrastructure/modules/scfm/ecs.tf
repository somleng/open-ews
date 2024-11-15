locals {
  shared_container_secrets = [
    {
      name      = "RAILS_MASTER_KEY"
      valueFrom = aws_ssm_parameter.rails_master_key.arn
    },
    {
      name      = "DATABASE_PASSWORD"
      valueFrom = var.rds_cluster.db_master_password_parameter.arn
    }
  ]

  shared_container_healthcheck = {
    command  = ["CMD-SHELL", "wget --server-response --spider --quiet http://localhost:3000/health_checks 2>&1 | grep '200 OK' > /dev/null"],
    interval = 10,
    retries  = 10,
    timeout  = 5
  }

  shared_container_environment = [
    {
      name  = "RAILS_ENV",
      value = var.app_environment
    },
    {
      name  = "RACK_ENV",
      value = var.app_environment
    },
    {
      name  = "AWS_SQS_HIGH_PRIORITY_QUEUE_NAME",
      value = aws_sqs_queue.high_priority.name
    },
    {
      name  = "AWS_SQS_DEFAULT_QUEUE_NAME",
      value = aws_sqs_queue.default.name
    },
    {
      name  = "AWS_SQS_LOW_PRIORITY_QUEUE_NAME",
      value = aws_sqs_queue.low_priority.name
    },
    {
      name  = "AWS_SQS_SCHEDULER_QUEUE_NAME",
      value = aws_sqs_queue.scheduler.name
    },
    {
      name  = "AWS_DEFAULT_REGION",
      value = var.aws_region
    },
    {
      name  = "DATABASE_NAME",
      value = var.db_name
    },
    {
      name  = "DATABASE_USERNAME",
      value = var.rds_cluster.this.master_username
    },
    {
      name  = "DATABASE_HOST",
      value = var.rds_cluster.this.endpoint
    },
    {
      name  = "DATABASE_PORT",
      value = tostring(var.rds_cluster.this.port)
    },
    {
      name  = "DB_POOL",
      value = tostring(var.db_pool)
    },
    {
      name  = "RAILS_LOG_TO_STDOUT",
      value = "true"
    },
    {
      name  = "RAILS_SERVE_STATIC_FILES",
      value = "true"
    },
    {
      name  = "UPLOADS_BUCKET",
      value = aws_s3_bucket.uploads.id
    },
    {
      name  = "AUDIO_BUCKET",
      value = aws_s3_bucket.audio.id
    }
  ]

  worker_container_definitions = [
    {
      name  = "worker",
      image = "${var.app_image}:latest",
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.worker.name,
          awslogs-region        = var.region.aws_region,
          awslogs-stream-prefix = var.app_environment
        }
      },
      command      = ["bundle", "exec", "shoryuken", "-R", "-C", "config/shoryuken.yml"],
      startTimeout = 120,
      essential    = true,
      healthCheck  = local.shared_container_healthcheck,
      environment  = local.shared_container_environment,
      secrets      = local.shared_container_secrets
    }
  ]
}

resource "aws_ecs_cluster" "this" {
  name = var.app_identifier

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# Capacity Provider
resource "aws_ecs_capacity_provider" "this" {
  name = var.app_identifier

  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.container_instances.autoscaling_group.arn
    managed_termination_protection = "ENABLED"
    managed_draining               = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [
    aws_ecs_capacity_provider.this.name,
    "FARGATE"
  ]
}

resource "aws_ecs_task_definition" "webserver" {
  family                   = "${var.app_identifier}-webserver"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name  = "nginx"
      image = "${var.nginx_image}:latest"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.nginx.name,
          awslogs-region        = var.region.aws_region,
          awslogs-stream-prefix = var.app_environment
        }
      },
      essential = true,
      portMappings = [
        {
          containerPort = 80
        }
      ],
      dependsOn = [
        {
          containerName = "app",
          condition     = "HEALTHY"
        }
      ]
    },
    {
      name  = "app",
      image = "${var.app_image}:latest",
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name,
          awslogs-region        = var.region.aws_region,
          awslogs-stream-prefix = var.app_environment
        }
      },
      startTimeout = 120,
      healthCheck  = local.shared_container_healthcheck,
      essential    = true,
      portMappings = [
        {
          containerPort = 3000
        }
      ],
      secrets     = local.shared_container_secrets,
      environment = local.shared_container_environment
    }
  ])

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  memory             = module.container_instances.ec2_instance_type.memory_size - 512
}

resource "aws_ecs_service" "webserver" {
  name            = aws_ecs_task_definition.webserver.family
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.webserver.arn
  desired_count   = var.webserver_min_tasks

  network_configuration {
    subnets = var.region.vpc.private_subnets
    security_groups = [
      aws_security_group.webserver.id,
      var.rds_cluster.security_group.id
    ]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
  }

  placement_constraints {
    type = "distinctInstance"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.webserver.arn
    container_name   = "nginx"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.internal_webserver.arn
    container_name   = "nginx"
    container_port   = 80
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_iam_role.task_execution_role
  ]
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.app_identifier}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions    = jsonencode(local.worker_container_definitions)
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = module.container_instances.ec2_instance_type.memory_size - 512
}

resource "aws_ecs_task_definition" "worker_fargate" {
  family                   = "${var.app_identifier}-worker-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode(local.worker_container_definitions)
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = 1024
  cpu                      = 512

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "worker" {
  name            = aws_ecs_task_definition.worker.family
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_min_tasks

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
  }

  network_configuration {
    subnets = var.region.vpc.private_subnets
    security_groups = [
      aws_security_group.worker.id,
      var.rds_cluster.security_group.id
    ]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  placement_constraints {
    type = "distinctInstance"
  }

  depends_on = [
    aws_iam_role.task_execution_role
  ]

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
