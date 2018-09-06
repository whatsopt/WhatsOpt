import click
from whatsopt import __version__
from .whatsopt_client import WhatsOpt

@click.group()
@click.version_option(__version__)
@click.option('--credentials', help='specify authentication information (API key)')
@click.option('--url', help='specify WhatsOpt application server URL (default: {})'.format(WhatsOpt(login=False).default_url))
@click.pass_context
def cli(ctx, credentials, url):
	ctx.obj['api_key']=credentials
	ctx.obj['url']=url
	
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
@click.pass_context
def list(ctx):
	""" List analyses """
	WhatsOpt(api_key=ctx.obj['api_key']).list_analyses()
	
@cli.command()
@click.option('--dry-run', is_flag=True, default=False, help='generate analysis push data without actually pushing')
@click.option('--name', help='find analysis with given name')
@click.argument('py_filename')
@click.pass_context
def push(ctx, dry_run, name, py_filename):
	""" Push analysis from within given PY_FILENAME """
	wop = WhatsOpt(api_key=ctx.obj['api_key'])
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
@click.argument('analysis_id')
@click.pass_context
def pull(ctx, dry_run, force, analysis_id):
	""" Pull analysis given its identifier """	
	options = {'--dry-run': dry_run, '--force': force}
	WhatsOpt(api_key=ctx.obj['api_key']).pull_mda(analysis_id, options)
	
@cli.command()
@click.option('--analysis-id', help='specify the analysis to update from (otherwise guessed from current files)')
@click.pass_context
def update(ctx, analysis_id):
	""" Update analysis connections """
	WhatsOpt(api_key=ctx.obj['api_key']).update_mda(analysis_id)
	
@cli.command()
@click.argument('sqlite_filename')
@click.option('--analysis-id', help='specify the analysis to create a new operation otherwise use default analysis')
@click.option('--operation-id', help='specify the operation to be updated with new cases')
@click.option('--cleanup', is_flag=True, default=False, help='[DANGER] delete given sqlite file after uploading it')
@click.pass_context
def upload(ctx, sqlite_filename, analysis_id, operation_id, cleanup):
	""" Upload data stored in given SQLITE_FILENAME """
	WhatsOpt(api_key=ctx.obj['api_key']).upload(sqlite_filename, analysis_id, operation_id, cleanup)

@cli.command()
@click.pass_context
def version(ctx):
	""" Show versions of WhatsOpt app and recommended wop command line """
	WhatsOpt(api_key=ctx.obj['api_key']).check_versions()
	
@cli.command()
def serve():
	""" Launch analysis server """
	WhatsOpt(login=False).serve()
		
cli(prog_name='wop', obj={})
