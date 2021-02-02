# output public_instance_ids {
#     description = "IDs of EC2 instances"
#     value       = aws_instance.Brownie_web_server-01.*.public_ip
# }


# output private_instance_ids {
#     description = "IDs of EC2 instances"
#     value       = aws_instance.Brownie_Private_server-01.*.public_ip
# }
