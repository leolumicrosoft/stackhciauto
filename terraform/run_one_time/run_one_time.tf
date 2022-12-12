
resource "null_resource" "PowerShellScriptRunFirstTimeOnly" {
    provisioner "local-exec" {
        command = "helpers\\get_processes.ps1 -First 10"
        
        interpreter = ["PowerShell", "-Command"]
    }
}