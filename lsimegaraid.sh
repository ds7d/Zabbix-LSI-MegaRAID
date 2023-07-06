#!/bin/bash

# initial src: https://wiki.enchtex.info/howto/zabbix/zabbix_megaraid_monitoring

MEGACLI="sudo /usr/sbin/megacli"

case "$1" in
  "lsi.pd.discovery")
  ${MEGACLI} -PDlist -aAll -NoLog | \
    awk '/Adapter/{print "\nAdapter "$2"|"}; /Enclosure Device ID/{printf "Enclosure "$4" "}; /Slot Number/{printf "Slot "$3"+"}' | \
    sed 's/#//g' | sed ':a;N;$!ba;s/|\n/ | /g' | sed 's/ | /+/g' | \
    awk '{split($0,a,"+"); for (i=2;i<length(a);++i) print a[1]" "a[i]}' | \
    awk 'BEGIN { print "{\"data\":["; } { if (NR > 1) print ","; print "{\"{#ADENCSLOT}\":\"" $0 "\"}"; } END {print "]}"}'
  ;;
  "lsi.vd.discovery")
  ${MEGACLI} -LDInfo -Lall -aALL -NoLog | \
    awk '/Adapter/{print "\nAdapter "$2"|"}; /Virtual Drive:/{printf "VirtualDrive "$3"+"}' | \
    sed ':a;N;$!ba;s/|\n/ | /g' | sed 's/ | /+/g' | \
    awk '{split($0,a,"+"); for (i=2;i<length(a);++i) print a[1]" "a[i]}' | \
    awk 'BEGIN { print "{\"data\":["; } { if (NR > 1) print ","; print "{\"{#ADVD}\":\"" $0 "\"}"; } END {print "]}"}'
  ;;
  "pd")
    ADAPTER=`echo "$2" | cut -f2 -d" "`
  ENCLOSURE=`echo "$2" | cut -f4 -d" "`
       SLOT=`echo "$2" | cut -f6 -d" "`
  DATACACHE=`${MEGACLI} -PDInfo -PhysDrv[${ENCLOSURE}:${SLOT}] -a${ADAPTER} -NoLog | awk -F':' '
        function ltrim(s) { sub(/^[ \t]+/, "", s); return s }
        function rtrim(s) { sub(/[ \t]+$/, "", s); return s }
        function trim(s)  { return rtrim(ltrim(s)); }
        /Slot Number/              {slotcounter+=1; slot[slotcounter]=trim($2)}
        /Inquiry Data/             {inquiry[slotcounter]=trim($2)}
        /Firmware state/           {state[slotcounter]=trim($2)}
        /Drive Temperature/        {temperature[slotcounter]=trim($2)}
        /S.M.A.R.T/                {smart[slotcounter]=trim($2)}
        /Media Error Count/        {mediaerror[slotcounter]=trim($2)}
        /Other Error Count/        {othererror[slotcounter]=trim($2)}
        /Predictive Failure Count/ {failurecount[slotcounter]=trim($2)}
        END {
          for (i=1; i<=slotcounter; i+=1) {
            printf ( "DriveSlot%d \"inquiry\":\"%s\",\n",slot[i], inquiry[i]);
            printf ( "DriveSlot%d \"state\":\"%s\",\n", slot[i], state[i]);
            printf ( "DriveSlot%d \"temperature\":\"%d\",\n", slot[i], temperature[i]);
            printf ( "DriveSlot%d \"smart\":\"%s\",\n", slot[i], smart[i]);
            printf ( "DriveSlot%d \"mediaerror\":\"%d\",\n", slot[i], mediaerror[i]);
            printf ( "DriveSlot%d \"othererror\":\"%d\",\n", slot[i], othererror[i]);
            printf ( "DriveSlot%d \"failurecount\":\"%d\"\n", slot[i], failurecount[i]);
          }
        }'`
  echo "${DATACACHE}" | grep "DriveSlot${SLOT} " | \
    awk '{$1="";$0 = substr($0,2); print $0}' | awk 'BEGIN{print "{"} {print} END{print "}"}'
  ;;
  "vd")
  ADAPTER=`echo "$2" | cut -f2 -d" "`
  VD=`echo "$2" | cut -f4 -d" "`
  DATACACHE=`${MEGACLI} -LDInfo -L${VD} -a${ADAPTER} -NoLog | awk -F':' '
        function ltrim(s) { sub(/^[ \t]+/, "", s); return s }
        function rtrim(s) { sub(/[ \t]+$/, "", s); return s }
        function trim(s)  { return rtrim(ltrim(s)); }
        /Virtual Drive:/ {drivecounter+=1; slot[drivecounter]=trim($2);}
        /State/          {state[drivecounter]=trim($2)}
        /Bad Blocks/     {badblock[drivecounter]=trim($2)}
        END {
          for (i=1; i<=drivecounter; i+=1) {
            printf ( "VirtualDrive%d \"state\":\"%s\",\n", slot[i], state[i]);
            printf ( "VirtualDrive%d \"badblock\":\"%s\"\n", slot[i], badblock[i]);
          }
        }'`
  echo "${DATACACHE}" | grep "VirtualDrive${VD} " | \
    awk '{$1="";$0 = substr($0,2); print $0}' | awk 'BEGIN{print "{"} {print} END{print "}"}'
  ;;
  "battery_missing")
	 ${MEGACLI} -AdpBbuCmd -GetBbuStatus -aALL | /bin/grep -cE '(Battery Pack Missing.*es|Battery State.*Missing|The required hardware component is not present)'
  ;;
  "battery_state")
	  ${MEGACLI} -AdpBbuCmd -GetBbuStatus -aALL | /usr/bin/awk 'BEGIN { s = 1; } /^Battery State: *(Optimal|Operational)/ { s = 0; } /^Battery State: *(Learning|Charging|Discharging)/ { s = 2; } /Battery Replacement required.*es/ { s = 3; }  END { print s; }'
  ;;
esac
