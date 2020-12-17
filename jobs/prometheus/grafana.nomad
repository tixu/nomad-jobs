job "grafana" {
  datacenters = ["dc1"]
  type = "service"

  group "monitoring" {
   network {
      port "grafana_ui" {
         static = 3000
      }
   }
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 300
    }
  task "graphana" {
    driver = "docker"
    config {
     image = "grafana/grafana:6.6.2"
     ports=["grafana_ui"]
      }
    }
     service {
        name = "grafan"
        tags = ["urlprefix-/"]
        port = "grafana_ui"
        check {
          name     = "grafana_ui port alive"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }


