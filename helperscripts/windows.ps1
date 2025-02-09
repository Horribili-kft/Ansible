$securePassword = ConvertTo-SecureString -String "Password123" -AsPlainText -Force
New-LocalUser -Name Ansible -Password $securePassword -PasswordNeverExpires -AccountNeverExpires
Add-LocalGroupMember -Group Administrators -Member Ansible

# https://github.com/ansible/ansible-documentation/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1
# https://www.youtube.com/watch?v=SqO2HkKep90  ~19:30
# Look into how to harden this command
.\ConfigureRemotingForAnsible.ps1
