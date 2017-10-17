#!/bin/sh

# Description: check whois for domains of interest.

MYDOMAINS="recipy.org"
MYEMAIL="robin@rtwilson.com"
MYWORKDIR=/home/robintw/whois-checker

DIFF=/usr/bin/diff
EGREP=/bin/egrep
WHOIS=/usr/bin/whois

for domain in ${MYDOMAINS}; do

OLDFILE=${MYWORKDIR}/${domain}.whois.old.txt
NEWFILE=${MYWORKDIR}/${domain}.whois.new.txt

# If the working directory does not exist, create it or exit.
if [ ! -d ${MYWORKDIR} ]; then
mkdir ${MYWORKDIR} || (echo "Could not create ${MYWORKDIR}"; exit 1;)
fi

# If baseline files don't exist, create them.
if [ ! -f ${OLDFILE} ]; then
touch ${OLDFILE}
echo "Created baseline file for ${domain}."
continue
fi

# Fetch WHOIS record for the domain, ignoring 4-digit years.
# This is somewhat fragile, as WHOIS output formats can change.
${WHOIS} ${domain} \
| ${EGREP} -vi '.*whois.*[ \-]20[0-9][0-9][ ,-]' \
> ${NEWFILE}

# Check to see if the WHOIS record has changed.
#
# We manually email because some OSes (most notably Solaris) do not
# put unique information in subject lines created from cron.

${DIFF} -u \
${OLDFILE} \
${NEWFILE} >/dev/null

if [ $? != 0 ]; then
${DIFF} -u \
${OLDFILE} \
${NEWFILE} \
 | mail -s "whois check: ${domain}" ${MYEMAIL}
fi

# Save the new WHOIS information as the baseline.
mv ${MYWORKDIR}/${domain}.whois.new.txt \
${MYWORKDIR}/${domain}.whois.old.txt

done
