output "vm_ids" {
    value = aws_instance.ec2[*].id
}

output "bucket_names" {
    value = aws_s3_bucket.bucket[*].bucket
}