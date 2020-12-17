job "db-stacks" {
  datacenters = ["dc1"]
  type        = "service"
  group "console"{
      count = 1

      constraint {
          attribute  = "${meta.role}"
          value     = "worker"
      }

      network {
 	 mode = "host"
         port "ui" {
            static=8080
	 }
         

      }
      task "db-workbench" {
       driver = "docker"
       config {
            image = "adminer"
            ports =["ui"]
	    network_mode="host"
	    dns_servers = ["127.0.0.53"]
	    dns_search_domains=["consul"]
       }

      }
      service {
        tags = ["dbview","traefik.enable=true","traefik.http.routers.myr.rule=Host(`dbviewer.tixu.be`)"]
        port = "ui"
        check {
	    name = "workbench view"
	    type = "http"
	    path     = "/"
            port = "ui"
            interval = "5s"
            timeout  = "2s"
       }
     }
    }
  group "db-server" {
    count = 1
    network {
     port "db" {
         static = 3306
     }
    }
    volume "mariadb" {
      type      = "host"
      read_only = false
      source    = "db"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "mariadb-server" {
      driver = "docker"

      volume_mount {
        volume      = "mariadb"
        destination = "/var/lib/mysql"
        read_only   = false
      }

      env  {
        MYSQL_ROOT_PASSWORD = "password"
      }

      config {
        image = "mariadb:latest"
        ports =["db"]
        
      }

      }
      service {
        name = "mysql-server"
        port = "db"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
}

