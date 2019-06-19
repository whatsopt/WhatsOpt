PY_SERVER_DIR = whatsopt/surrogate_server
RB_CLIENT_DIR = ../app/lib/whats_opt/surrogate_server

PY_SERVER_FILE = ${PY_SERVER_DIR}/Surrogate.py
RB_CLIENT_FILE = ${RB_CLIENT_DIR}/surrogate.rb

# Generate python for server
${PY_SERVER_FILE}: surrogate.thrift
	thrift -gen py -out . surrogate.thrift

# Generate ruby for client
${RB_CLIENT_FILE}: surrogate.thrift
	mkdir -p ${RB_CLIENT_DIR}
	thrift -gen rb -out ${RB_CLIENT_DIR} surrogate.thrift

all: ${PY_SERVER_FILE} ${RB_CLIENT_FILE}

clean: 
	rm -rf ${PY_SERVER_DIR} ${RB_CLIENT_DIR}