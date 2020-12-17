job "docs" {
  datacenters = ["dc1"]

  group "example" {
    task "server" {
      driver = "exec"

      config {
        command = "/usr/local/bin/http-echo"
        args = [
          "-listen",
          ":5678",
          "-text",
          "hello world",
        ]
      }
    }
    network {
       port "http" {
         static = "5678"
        }
      }
    }
}

