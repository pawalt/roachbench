output "connect_addr" {
  value = google_compute_instance.test_vm[0].network_interface.0.access_config.0.nat_ip
}

output "hosts" {
  value = tolist([
    for instance in google_compute_instance.test_vm :
      instance.network_interface.0.access_config.0.nat_ip
  ])
}

output "observer_addr" {
  value = google_compute_instance.observer.network_interface.0.access_config.0.nat_ip
}