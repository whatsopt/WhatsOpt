import click
from whatsopt.whatsopt_client import WhatsOpt

@click.group()
def cli():
	pass
	
@cli.command()
def login():
	""" Authenticate and store api key """
	WhatsOpt().login(echo=True)
	
@cli.command()
def logout():
	""" Remove api key """
	WhatsOpt(login=False).logout() 
	
@cli.command()
def list():
	""" List multi disciplinary analyses """
	WhatsOpt().list_analyses()
	
@cli.command()
@click.argument('py_filename')
def push(py_filename):
	""" Push multi disciplinary analyses specified within given PY_FILENAME """
	wop = WhatsOpt()
	wop.execute(py_filename, wop.push_mda_cmd)
	
cli(prog_name='wop')