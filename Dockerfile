FROM python:3.12-alpine

# Install required packages
RUN apk add --no-cache git bash nginx

# Copy and set default repository list (can be overridden at runtime)
COPY repos.txt /repos.txt

# Create necessary directories
RUN mkdir -p /docs /repos /run/nginx

# Install pdoc for documentation generation
RUN pip install --no-cache-dir pydoctor

# Copy entrypoint script
COPY update_docs.sh /update_docs.sh
RUN chmod +x /update_docs.sh

COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set up cron to run update_docs.sh periodically
RUN echo "*/30 * * * * /update_docs.sh" | crontab -

# Copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Start nginx and cron in the foreground
CMD ["/start.sh"]
