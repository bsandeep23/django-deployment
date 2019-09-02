FROM python:3.6
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
EXPOSE 8000
COPY src/ ./
#RUN python manage.py makemigrations
#RUN python manage.py migrate
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
CMD ["gunicorn", "mysite.wsgi", "-b", "127.0.0.1:8000", "--settings", "mysite.prd_settings"]
