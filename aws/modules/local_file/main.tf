resource "local_file" "local_file" {
  filename = var.file_name
  content  = var.content
}
