output "name" {
  description = "Storage container name that will hold the state file(s)."
  value       = module.s3_bucket.s3_bucket_id
}