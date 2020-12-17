# John Boero - jboero@hashicorp.com
# A job spec to install and run Vault with 'exec' driver - no Docker.
# Consul not used by default.  Add Consul to config template
# Artifact checksum is for linux-amd64 by default.
job "vault" {
  datacenters = ["dc1"]
  type = "service"
  group "vault" {
    count = 1

    task "vault" {
      driver = "exec"
      resources {
        cpu = 2000
        memory = 1024
      }

      artifact {
        source      = "https://releases.hashicorp.com/vault/1.6.0/vault_1.6.0_${attr.kernel.name}_${attr.cpu.arch}.zip"
        destination = "/tmp/"
        options {
          checksum = "sha256:83048e2d1ebfea212fead42e474e947c3a3bccc5056a5158ed33f530f8325e39"
        }
      }

      template {
        data        = <<EOF
        ui = true
        disable_mlock = true

        # Disable this if you switch to Consul.
        #storage "file" {
        #  path = "/opt/vault/data"
        #}

        # Switch to this for Consul
        storage "consul" {
          address = "127.0.0.1:8500"
          path    = "vault"
        }

        # Listen on all IPv4 and IPv6 interfaces.
        listener "tcp" {
          address = ":8200"
          tls_disable = 1
        }
        EOF
        destination = "/etc/vault.d/vault.hcl"
      }
      config {
        command = "/tmp/vault"
        args = ["server", "-config=/etc/vault.d/vault.hcl"]
      }
    }
  }
}

