build/%:
	sudo docker compose -f docker-compose-common.yml -f docker-compose-$*.yml up --build

up/%:
	sudo docker compose -f docker-compose-common.yml -f docker-compose-$*.yml up

down/%:
	sudo docker compose -f docker-compose-common.yml -f docker-compose-$*.yml down --volumes

down-all/%:
	sudo docker compose -f docker-compose-common.yml -f docker-compose-$*.yml down --volumes --rmi local

top/%:
	sudo docker compose -f docker-compose-common.yml -f docker-compose-$*.yml top

