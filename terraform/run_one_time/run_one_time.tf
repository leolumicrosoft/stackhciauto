
resource "null_resource" "PowerShellScriptRunFirstTimeOnly" {
    provisioner "local-exec" {
        command = "[the power shell script to execute]"
        
        interpreter = ["PowerShell", "-Command"]
    }
}