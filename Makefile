all: advanced-aggregates date-time

advanced-aggregates:
	pg_prove -U  postgres -d sql_test advanced-aggregates.sql

date-time:
	pg_prove -U  postgres -d sql_test date-time.sql 
