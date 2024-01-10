resource "aws_dynamodb_table" "codes" {
  name = "broker_codes"
  attribute {
    name = "code"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
  hash_key       = "code"
  read_capacity  = 1
  write_capacity = 1
  lifecycle {
    ignore_changes = [read_capacity, write_capacity]
  }
}


resource "aws_appautoscaling_target" "codes_read_target" {
  max_capacity       = 1000
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.codes.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "codes_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.codes_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.codes_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.codes_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.codes_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70
  }
}


resource "aws_appautoscaling_target" "codes_write_target" {
  max_capacity       = 1000
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.codes.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "codes_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.codes_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.codes_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.codes_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.codes_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70
  }
}
