FROM apache/airflow:2.7.1

COPY requirements.txt /requirements.txt
COPY entrypoint.sh /opt/airflow/entrypoint.sh

RUN pip install --user --upgrade pip
RUN pip install --no-cache-dir --user -r /requirements.txt

# Switch to root user to create the airflow user and group if they do not exist
USER root
RUN if ! getent group airflow; then addgroup --system airflow; fi
RUN if ! id -u airflow > /dev/null 2>&1; then adduser --system --ingroup airflow airflow; fi
RUN chown airflow:airflow /opt/airflow/entrypoint.sh
RUN chmod +x /opt/airflow/entrypoint.sh

# Switch back to airflow user
USER airflow

# Use the custom entrypoint script
ENTRYPOINT ["/opt/airflow/entrypoint.sh"]
