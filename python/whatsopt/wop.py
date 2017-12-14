import click
from whatsopt.whatsopt_client import WhatsOpt

@click.group()
def cli():
	pass

@cli.command()
@click.argument('py_filename')
def push(py_filename):
	""" Push given MDA specified within given PY_FILENAME """
	wop = WhatsOpt()
	wop.execute(py_filename, wop.push_mda)
	
cli(prog_name='wop')