all: date-time

date-time:
	pg_prove -U  postgres -d postgresql_test date-time.sql 
