output "connect_addr_use1" {
  value = module.roachcluster-use1.connect_addr
}

output "connect_addr_euw2" {
  value = module.roachcluster-euw2.connect_addr
}

output "connect_addr_an1" {
  value = module.roachcluster-an1.connect_addr
}

output "observer_addr_use1" {
  value = module.roachcluster-use1.observer_addr
}

output "observer_addr_euw2" {
  value = module.roachcluster-euw2.observer_addr
}

output "observer_addr_an1" {
  value = module.roachcluster-an1.observer_addr
}
