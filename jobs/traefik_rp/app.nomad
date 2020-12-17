job "demo-webapp" {
  datacenters = ["dc1"]

  group "demo" {
    count = 1 
    network {
       port "http" {}
    }
    task "server" {

      driver = "docker"

      config {
        image = "hashicorp/demo-webapp-lb-guide"
        ports = ["http"]
      }

     }


      service {
        name = "demo-webapp"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.http.rule=Path(`/myapp`)",
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
}


