job "example" {
  datacenters = ["dc1"]
  namespace = "prod"
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }

  migrate {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "cache" {
    network {
    port "db" { to= 6379}
   }
    count = 2
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "redis" {
      driver = "docker"
      config {
        image = "redis:3.2"
        ports = ["db"]
          
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }

      service {
        name = "redis-cache"
        tags = ["global", "cache"]
        port = "db"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

