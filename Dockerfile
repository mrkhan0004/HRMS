# Yeh Frappe ka official base image hai
FROM frappe/frappe-worker:latest

# Aapka custom HRMS code yahan copy hoga
COPY . /home/frappe/frappe-bench/apps/hrms_app

# Bench ko batana hai ki naya app aa gaya hai
RUN bench setup app --skip-assets hrms_app