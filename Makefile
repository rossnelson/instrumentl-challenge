# run all default target services in parallel: make -j
target: run_services run_api tail_logs

run_services:
	cd ./support && docker compose -p "safebite" up

run_api:
	cd ./app && bundle && rails s

tail_logs:
	touch ./app/log/active_job.log && tail -f ./app/log/active_job.log

ingest:
	cd ./app && bundle exec rake ingest:files

test:
	./support/test.sh
