data "google_client_config" "current" {
}

resource "google_compute_instance" "test_vm" {
  count = 3

  name         = "vm-${count.index}"
  machine_type = "n1-standard-4"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = <<EOF
      roachadmin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDISjep4jUbOva1XvUrMoyTJ2XLnroypaOq/my06B7idX0Y3YD51uyJmCj51g62805k8HzW65Mo1jTPfM5ezeZE7qhqMA1OJyOg1dCTiyrzgLG/BV/M42eumz9Q3bO+1BXVVO6Ai/K3fnU/g7y48mfx/1rc3IDeiD6G+Dwm7zaEYESq62rrHV44uaat3Hb3sQ22IgjQ7wqcpxT28hVSqL7PWzf8nnYGg2fJgqiky52QwLPMoGItNKnFlzp7ucIGo5qJjh1TCMlRTIzmpYgFUsf4d3gHLKpFDCuoF+F2JLLTMx8AC1ti5rrmf5oslidQtIdPfRQdC7D8dBJkeoq0UdCZ pawalt@hey.com
      root:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDISjep4jUbOva1XvUrMoyTJ2XLnroypaOq/my06B7idX0Y3YD51uyJmCj51g62805k8HzW65Mo1jTPfM5ezeZE7qhqMA1OJyOg1dCTiyrzgLG/BV/M42eumz9Q3bO+1BXVVO6Ai/K3fnU/g7y48mfx/1rc3IDeiD6G+Dwm7zaEYESq62rrHV44uaat3Hb3sQ22IgjQ7wqcpxT28hVSqL7PWzf8nnYGg2fJgqiky52QwLPMoGItNKnFlzp7ucIGo5qJjh1TCMlRTIzmpYgFUsf4d3gHLKpFDCuoF+F2JLLTMx8AC1ti5rrmf5oslidQtIdPfRQdC7D8dBJkeoq0UdCZ pawalt@hey.com
    EOF
  }
}

resource "google_compute_instance" "observer" {
  name         = "observer"
  machine_type = "n1-standard-4"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = <<EOF
      roachadmin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDISjep4jUbOva1XvUrMoyTJ2XLnroypaOq/my06B7idX0Y3YD51uyJmCj51g62805k8HzW65Mo1jTPfM5ezeZE7qhqMA1OJyOg1dCTiyrzgLG/BV/M42eumz9Q3bO+1BXVVO6Ai/K3fnU/g7y48mfx/1rc3IDeiD6G+Dwm7zaEYESq62rrHV44uaat3Hb3sQ22IgjQ7wqcpxT28hVSqL7PWzf8nnYGg2fJgqiky52QwLPMoGItNKnFlzp7ucIGo5qJjh1TCMlRTIzmpYgFUsf4d3gHLKpFDCuoF+F2JLLTMx8AC1ti5rrmf5oslidQtIdPfRQdC7D8dBJkeoq0UdCZ pawalt@hey.com
      root:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDISjep4jUbOva1XvUrMoyTJ2XLnroypaOq/my06B7idX0Y3YD51uyJmCj51g62805k8HzW65Mo1jTPfM5ezeZE7qhqMA1OJyOg1dCTiyrzgLG/BV/M42eumz9Q3bO+1BXVVO6Ai/K3fnU/g7y48mfx/1rc3IDeiD6G+Dwm7zaEYESq62rrHV44uaat3Hb3sQ22IgjQ7wqcpxT28hVSqL7PWzf8nnYGg2fJgqiky52QwLPMoGItNKnFlzp7ucIGo5qJjh1TCMlRTIzmpYgFUsf4d3gHLKpFDCuoF+F2JLLTMx8AC1ti5rrmf5oslidQtIdPfRQdC7D8dBJkeoq0UdCZ pawalt@hey.com
    EOF
  }

  connection {
      type     = "ssh"
      user     = "roachadmin"
      host = self.network_interface.0.access_config.0.nat_ip
  } 
}
