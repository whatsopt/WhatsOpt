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
@click.option('--dry-run', is_flag=True, default=False, help='generate analysis data without actually pushing')
@click.option('--name', help='find analysis with given name')
@click.argument('py_filename')
def push(dry_run, name, py_filename):
	""" Push multi disciplinary analysis specified within given PY_FILENAME """
	wop = WhatsOpt()
	options = {'--dry-run': dry_run, '--name': name}
	wop.execute(py_filename, wop.push_mda_cmd, options)
	# if not exited successfully in execute
	if name:
		print("Error: analysis %s not found" % name)
	else:
		print("Error: analysis not found")
	exit(-1)
	
cli(prog_name='wop')
