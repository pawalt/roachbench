%{ for region, hosts_list in workers ~}
[${region}]
%{ for host in hosts_list ~}
${host}
%{ endfor ~}

%{ endfor ~}

[workers:children]
%{ for region, _ in workers ~}
${region}
%{ endfor ~}

[observers]
%{ for host in observers ~}
${host}
%{ endfor ~}
