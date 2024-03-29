.PHONY: clean init purge start-prod up-core up-ckan test

clean:
	sudo rm -rf solr/mycores/ckan/data/

init:
	./scripts/setup.sh init

purge:
	./scripts/setup.sh purge

start-prod:
	# sudo chown -R 8983:8983 solr
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

down:
	docker-compose down

up-core:
	# sudo chown -R 8983:8983 solr
	docker-compose up postgres redis solr

up-ckan:
	docker-compose up datapusher ckan

test:
	pycodestyle --count --ignore=E501,E731 ./src/extensions/ckanext-biskit/ckanext/biskit
