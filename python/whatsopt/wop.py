import click
from whatsopt.whatsopt_client import WhatsOpt

@click.group()
def cli():
	pass
	
@cli.command()
def url():
	""" WhatsOpt server url """
	print(WhatsOpt(login=False).url)

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
	""" List analyses """
	WhatsOpt().list_analyses()
	
@cli.command()
@click.option('--dry-run', is_flag=True, default=False, help='generate analysis push data without actually pushing')
@click.option('--name', help='find analysis with given name')
@click.argument('py_filename')
def push(dry_run, name, py_filename):
	""" Push analysis from within given PY_FILENAME """
	wop = WhatsOpt()
	options = {'--dry-run': dry_run, '--name': name}
	wop.execute(py_filename, wop.push_mda_cmd, options)
	# if not exited successfully in execute
	if name:
		print("Error: analysis %s not found" % name)
	else:
		print("Error: analysis not found")
	exit(-1)
	
@cli.command()
@click.option('--dry-run', is_flag=True, default=False, help='print analysis pull infos without actually pulling')
@click.option('--force', is_flag=True, default=False, help='overwrite existing files')
@click.argument('mda_id')
def pull(dry_run, force, mda_id):
	""" Pull analysis given its identifier """	
	options = {'--dry-run': dry_run, '--force': force}
	WhatsOpt().pull_mda(mda_id, options)
	
@cli.command()
def update():
	""" Update analysis connections """
	WhatsOpt().update_mda()
	
@cli.command()
@click.argument('sqlite_filename')
def upload(sqlite_filename):
	""" Upload data stored in given SQLITE_FILENAME """
	WhatsOpt().upload(sqlite_filename)
	
cli(prog_name='wop')
