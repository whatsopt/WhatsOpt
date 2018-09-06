from setuptools import setup
from whatsopt import __version__

CLASSIFIERS = """
Intended Audience :: Developers
License :: OSI Approved :: Apache Software License
Programming Language :: Python
Topic :: Software Development
Topic :: Scientific/Engineering
"""

metadata = dict(
    name='wop',
    version=__version__,
    description='Command line interface for WhatsOpt web application',
    author='Remi Lafage',
    author_email='remi.lafage@onera.fr',
    license='Apache 2.0',
    classifiers=[_f for _f in CLASSIFIERS.split('\n') if _f],
    packages=['whatsopt'],
    install_requires=[
        'openmdao>=2.2', 'Click>=6.7', 'tabulate>=0.8.2'
    ],
    entry_points="""
        [console_scripts]
        wop=whatsopt.wop:cli
    """
)

setup(**metadata)
