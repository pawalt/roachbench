resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tpl",
    {
      workers = var.workers
      observers = var.observers
    }
  )
  filename = "../ansible/inventory/hosts.cfg"
}
