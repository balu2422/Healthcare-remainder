resource "aws_dynamodb_table" "patient_records" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "patient_id"
  range_key      = "record_type"

  attribute {
    name = "patient_id"
    type = "S"
  }

  attribute {
    name = "record_type"
    type = "S"
  }
}
