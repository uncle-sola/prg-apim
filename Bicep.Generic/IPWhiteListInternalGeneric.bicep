param IPWhiteListAdditions array?

var IpList = [
  {
    name: 'CWH1'
    ip: '212.241.233.78'
  }
  {
    name: 'CWH2'
    ip: '212.241.134.60'
  }
  {
    name: 'VPN - DCA'
    ip: '213.86.220.156'
  }
  {
    name: 'VPN - DCB'
    ip: '213.86.220.195'
  }
  {
    name: 'LAV 1'
    ip: '213.86.220.155'
  }
  {
    name: 'DCA Network'
    ip: '80.169.4.130'
  }
  {
    name: 'DCB Network'
    ip: '80.169.4.138'
  }
]

var StorageRuleList = [for (rule,i) in concat(IpList, IPWhiteListAdditions ?? []): {
  value: rule.?ip
  action: 'Allow'
}]

var WebAppRuleList = [for (rule,i) in concat(IpList, IPWhiteListAdditions ?? []): {
  ipAddress: '${rule.?ip}/32'
  action: 'Allow'
  priority: 500 + i
  name: rule.?name
}]

output StorageRuleList array = StorageRuleList
output WebAppRuleList array = WebAppRuleList
