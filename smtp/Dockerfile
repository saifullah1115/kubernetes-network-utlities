FROM internal-registry.tkg.mobilink.net.pk/wso2-prod/tools/crontab:1.0

# Update package list and install msmtp and mailutils
RUN apt-get update && \
    apt-get install -y msmtp mailutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure msmtp
RUN echo "defaults" > /etc/msmtprc && \
    echo "auth           off" >> /etc/msmtprc && \
    echo "tls            off" >> /etc/msmtprc && \
    echo "host           lhe-excas-01.mobilink.net.pk" >> /etc/msmtprc && \
    echo "port           25" >> /etc/msmtprc && \
    echo "logfile        /var/log/msmtp.log" >> /etc/msmtprc && \
    echo "account        default" >> /etc/msmtprc && \
    echo "host           lhe-excas-01.mobilink.net.pk" >> /etc/msmtprc && \
    echo "port           25" >> /etc/msmtprc

# Force create a symlink to use msmtp as sendmail
RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# Set the default command to keep the container running
CMD tail -f /dev/null
