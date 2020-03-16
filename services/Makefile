PY_SERVER_DIR = whatsopt/services
RB_CLIENT_DIR = ../app/lib/whats_opt/services

PY_SERVER_FILE = ${PY_SERVER_DIR}/Surrogate.py
RB_CLIENT_FILE = ${RB_CLIENT_DIR}/surrogate.rb

# Generate python for server
${PY_SERVER_FILE}: whatsopt_services.thrift
	thrift -gen py -out . whatsopt_services.thrift

# Generate ruby for client
${RB_CLIENT_FILE}: whatsopt_services.thrift
	mkdir -p ${RB_CLIENT_DIR}
	thrift -gen rb -out ${RB_CLIENT_DIR} whatsopt_services.thrift

all: ${PY_SERVER_FILE} ${RB_CLIENT_FILE}

clean: 
	rm -rf ${PY_SERVER_DIR} ${RB_CLIENT_DIR}