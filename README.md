# Zabbix: LSI MegaRAID monitoring
Captures disks in **all** adapters and enclosures.

#### Features:
1. LLD;
2. dependent items.

Template exported from zabbix 4.0 but worked on zabbix 3.4.

#### Installation

Adjust sudoers rules:

    cp zabbix_megacli /etc/sudoers.d/zabbix_megacli

Install zabbix userparameter:

    cp userparameter_lsimegaraid.conf <zabbix_include_dir>/userparameter_lsimegaraid.conf
    service zabbix-agent restart

Import template to zabbix.

#### Examples of MegaCli output:

Info about **logical** disks

    $ megacli -LDInfo -LAll -a0 -NoLog
    
    Adapter 0 -- Virtual Drive Information:
    Virtual Drive: 0 (Target Id: 0)
    Name                :
    RAID Level          : Primary-6, Secondary-0, RAID Level Qualifier-3
    Size                : 3.271 TB
    Parity Size         : 1.089 TB
    State               : Optimal
    Strip Size          : 256 KB
    Number Of Drives    : 8
    Span Depth          : 1
    Default Cache Policy: WriteThrough, ReadAhead, Direct, No Write Cache if Bad BBU
    Current Cache Policy: WriteThrough, ReadAhead, Direct, No Write Cache if Bad BBU
    Default Access Policy: Read/Write
    Current Access Policy: Read/Write
    Disk Cache Policy   : Disk's Default
    Encryption Type     : None
    Bad Blocks Exist: No
    Is VD Cached: No

    Exit Code: 0x00

Info about **phisical** disks

    $ megacli -PDlist -a0 -NoLog

    Adapter #0

    Enclosure Device ID: 252
    Slot Number: 0
    Drive's postion: DiskGroup: 0, Span: 0, Arm: 0
    Enclosure position: 0
    Device Id: 8
    WWN: 5000CCA041887C5B
    Sequence Number: 2
    Media Error Count: 0
    Other Error Count: 0
    Predictive Failure Count: 0
    Last Predictive Failure Event Seq Number: 0
    PD Type: SAS
    Raw Size: 558.911 GB [0x45dd2fb0 Sectors]
    Non Coerced Size: 558.411 GB [0x45cd2fb0 Sectors]
    Coerced Size: 558.406 GB [0x45cd0000 Sectors]
    Firmware state: Online, Spun Up
    Is Commissioned Spare : NO
    Device Firmware Level: A760
    Shield Counter: 0
    Successful diagnostics completion on :  N/A
    SAS Address(0): 0x5000cca041887c59
    SAS Address(1): 0x0
    Connected Port Number: 3(path0) 
    Inquiry Data: HITACHI HUS156060VLS600 A760CZXE1XXN            
    FDE Enable: Disable
    Secured: Unsecured
    Locked: Unlocked
    Needs EKM Attention: No
    Foreign State: None 
    Device Speed: 6.0Gb/s 
    Link Speed: 6.0Gb/s 
    Media Type: Hard Disk Device
    Drive Temperature :43C (109.40 F)
    PI Eligibility:  No 
    Drive is formatted for PI information:  No
    PI: No PI
    Drive's write cache : Disabled
    Port-0 :
    Port status: Active
    Port's Linkspeed: 6.0Gb/s 
    Port-1 :
    Port status: Active
    Port's Linkspeed: Unknown 
    Drive has flagged a S.M.A.R.T alert : No

---  
Inspired by code https://wiki.enchtex.info/howto/zabbix/zabbix_megaraid_monitoring<br>
(limited to only a0 adapter: option -a0).
