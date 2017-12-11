import click
from whatsopt.whatsopt_client import WhatsOpt

@click.group()
def cli():
	pass

@cli.command()
@click.argument('py_filename')
def push(py_filename):
	""" Push given MDA specified within given PY_FILENAME """
	wazo = WhatsOpt()
	pb = wazo.get_openmdao_problem(py_filename)
	wazo.push_mda(pb)
	
cli(prog_name='wop')