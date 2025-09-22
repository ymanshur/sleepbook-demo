DATABASE_NAME?=sleepbook_demo_development

clear:
	clear

psql: clear
	docker exec -it postgres14 psql -d ${DATABASE_NAME}

psql_d: clear
	docker exec postgres14 psql -d ${DATABASE_NAME} \
		-c "\d ${table}"

psql_rc: clear
	docker exec postgres14 psql -d ${DATABASE_NAME} \
		-c "SELECT schemaname AS table_schema, relname AS table_name, n_live_tup AS estimated_row_count FROM pg_stat_user_tables ORDER BY n_live_tup DESC;"

psql_e: clear
	docker exec postgres14 psql -d ${DATABASE_NAME} -t -A \
		-c "EXPLAIN (ANALYZE) ${query};"

psql_e_json: clear
	docker exec postgres14 psql -d ${DATABASE_NAME} -t -A \
		-c "EXPLAIN (ANALYZE, FORMAT JSON) ${query};" > output.json
